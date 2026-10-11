# The API for producers and handlers

Everything a producer needs is on `expQueue`; everything a handler needs is its `expQueueJob` and `expQueueContext`.
Producers may run anywhere (a module view, Velocity, a cron part, another job); handlers run only in workers.

## Producers

### `expQueue::enqueue( $type, array $payload = array(), array $options = array() ) : expQueueJob`

| Option | Meaning | Default |
|---|---|---|
| `class` | priority class | the type's `Class=`, a matching rule, else `DefaultClass` |
| `priority` | 0..100 within the class | the type's `Priority=`, else the class's `DefaultPriority` |
| `group` | an `expQueueGroup`, its id or uuid | none |
| `idempotency_key` | unique per type among active jobs and done jobs younger than `IdempotencyWindow` (longer keys are hashed) | none |
| `resource` | concurrency key, e.g. `anthropic:standard`, `imaging` | the type's `Resource=` |
| `not_before` | a timestamp, or seconds from now when below 10^9 | now |
| `max_attempts` | attempts before the dead letter | type, class, `DefaultMaxAttempts` |
| `timeout` | seconds a run may take before its lease expires | type, `DefaultTimeout` |
| `depends_on` | a job (object, id, uuid) that must be done first; if it ends dead or cancelled, this one is cancelled | none |
| `user_id` | the user the job runs as | the current user |
| `site` | for the per-site quotas | `[QueueSettings] SiteName`, else site.ini SiteName |
| `deadline`, `lane`, `cost_estimate_micros`, `external_ref` | stored for producers that use them | |
| `tags` | strings the rules can match (`Tag=`) | |

Throws `expQueueException` for an unknown type or class, a payload the handler's `validate()` refuses, or a full quota.
With an idempotency key that is taken, it returns the existing job and sets `$job->duplicate = true`.

The payload is JSON: **never put a secret in it** (the admin pages show payloads; keys that look like secrets are
masked, but that is the second line of defence). Pass ids and let the handler read credentials from its settings.

Many jobs at once: wrap the loop in `expQueue::withLock()` so the dispatcher lock is taken once:

```php
$group = expQueue::createGroup( 'Translate the news subtree into German', 'translate.subtree' );
expQueue::withLock( function () use ( $nodeIDs, $group )
{
    foreach ( $nodeIDs as $id )
        expQueue::enqueue( 'mysite.translate', array( 'node_id' => $id, 'language' => 'ger-DE' ), array(
            'class' => 'translation_full', 'group' => $group, 'idempotency_key' => "translate:$id:ger-DE",
            'resource' => 'anthropic:batch' ) );
} );
```

### Other calls

| Call | Does |
|---|---|
| `expQueue::createGroup( $label, $type = '', $options )` | a group (`user_id`, `site`, `budget_micros`) |
| `expQueue::fetch( $uuidOrId )` | the job, or null |
| `expQueue::resolveGroup( $uuidOrId )` | the group, or null |
| `$job->resultArray()`, `$job->attribute( 'state' )`, `$job->progressPercent()` | the outcome |
| `$group->progress()` | done, dead, cancelled, running, active, total, percent |
| `expQueue::cancel( $job, $reason )` | `cancelled`, `running` (a request: the handler stops at its next check), or null when it had ended |
| `expQueue::cancelGroup( $group, $reason )` | every job of the group that has not ended |
| `expQueue::retry( $job )` / `retryDead( $type = '' )` | back into the queue with the attempts reset (dead, cancelled, held, retry) |
| `expQueue::pause( $scope, $name )` / `resume()` | scope `queue`, `class`, `resource`, `group` |
| `expQueue::countBy( $field, $where )`, `count( $where )`, `listJobs( $filter, $offset, $limit )` | queries |
| `expQueueResource::observe( $key, $hints )` | rate-limit hints from outside a job |

## Handlers

Register the type:

```ini
# extension/mysite/settings/expqueue.ini.append.php
[JobType_mysite.translate]
Handler=mySiteTranslateHandler
Class=translation_full
Resource=anthropic:batch
MaxAttempts=4
Timeout=600
RetryBase=60
MaxBackoff=3600
Description=Translates one object into one language
```

Implement `expQueueHandler::run( expQueueJob $job, expQueueContext $context )`, or extend `expQueueHandlerBase`,
which adds `validate( array $payload )` (called at enqueue: return an error text or null) and
`describe( expQueueJob $job )` (the one-line summary the admin shows).

`run()` returns nothing or an array (done; the array is the result), or an `expQueueResult`:
`done( $data )`, `retry( $message, $retryAfter )`, `fail( $message )` (dead letter now), `defer( $seconds )`
(later, without using up an attempt), `hold( $message )` (held until requeued or its group resumed),
`cancelled()`. It may throw `expQueueRetryableException( $message, $retryAfter, $errorClass )`,
`expQueuePermanentException( $message, $errorClass )` or `expQueueCancelledException`; any other exception counts as
retryable.

The context:

| Call | Does |
|---|---|
| `heartbeat( $seconds = null )` | extends the lease (timeout + LeaseMargin, or `$seconds`); returns false when cancelled or the lease is lost |
| `isCancelled()`, `throwIfCancelled()` | cooperative cancellation (looked up at most every 5 seconds) |
| `progress( $done, $total = null, $message = '' )` | progress bar on the admin pages; extends the lease |
| `checkpoint()`, `saveCheckpoint( array $data )` | the result checkpoint: save an outcome before applying it; a rerun reads it |
| `rateLimit( array $hints, $resource = null )` | `status`, `retry_after`, `remaining_requests`, `remaining_tokens`, `reset_at`/`reset_in` |
| `cost( $micros )` | the actual cost of the job |
| `log( $message, $data )` | a line in the job's history |
| `attempt()`, `payload()`, `job()`, `owner()` | |

Rules for handlers:

- Run idempotently: a job can run again after a crash (the reaper) or a retry. Use the checkpoint for anything that
  costs money or cannot be repeated, and make the apply step find what an earlier attempt already wrote.
- Never hold a database transaction around a slow call. Open short ones for your own writes.
- Call `progress()` or `heartbeat()` at least every timeout / 2 seconds in long work.
- The job runs as the user who queued it (`user_id`); check permissions with that user, as a web request would.

## A worked example

A handler that calls an external translation API for one object, stores the answer before it applies it, reports
the API's rate limits, and writes a draft:

```php
<?php
class mySiteTranslateHandler extends expQueueHandlerBase
{
    public function validate( array $payload )
    {
        if ( empty( $payload['node_id'] ) || empty( $payload['language'] ) )
            return 'node_id and language are required';
        return null;
    }

    public function describe( expQueueJob $job )
    {
        $p = $job->payloadArray();
        return 'Translate node ' . $p['node_id'] . ' into ' . $p['language'];
    }

    public function run( expQueueJob $job, expQueueContext $context )
    {
        $p = $job->payloadArray();
        $node = eZContentObjectTreeNode::fetch( (int) $p['node_id'] );
        if ( !$node )
            throw new expQueuePermanentException( 'the node is gone', 'not_found' );

        // 1. the answer of an earlier attempt, if it got that far: never pay twice
        $answer = $context->checkpoint();
        if ( $answer === null )
        {
            $response = mySiteApi::translate( $node->attribute( 'object' ), $p['language'] );   // your HTTP client
            $context->rateLimit( array( 'status' => $response->status,
                                        'retry_after' => (int) $response->header( 'retry-after' ),
                                        'remaining_requests' => (int) $response->header( 'x-ratelimit-remaining-requests' ) ) );
            if ( $response->status === 429 || $response->status >= 500 )
                throw new expQueueRetryableException( 'the API answered ' . $response->status,
                                                      (int) $response->header( 'retry-after' ), 'http_' . $response->status );
            if ( $response->status !== 200 )
                throw new expQueuePermanentException( 'the API refused: ' . $response->status, 'http_' . $response->status );
            $answer = $response->json();
            $context->saveCheckpoint( $answer );
            $context->cost( (int) $answer['cost_micros'] );
        }

        // 2. apply, idempotently: one draft per job
        $context->throwIfCancelled();
        $draft = mySiteDrafts::findOrCreateForJob( $job->attribute( 'uuid' ), $node, $p['language'] );
        foreach ( $answer['fields'] as $i => $field )
        {
            mySiteDrafts::setField( $draft, $field['identifier'], $field['text'] );
            $context->progress( $i + 1, count( $answer['fields'] ) );
        }
        return array( 'draft_version' => $draft->attribute( 'version' ), 'fields' => count( $answer['fields'] ) );
    }
}
```

And the producer, from a module view:

```php
$job = expQueue::enqueue( 'mysite.translate', array( 'node_id' => $nodeID, 'language' => 'ger-DE' ),
                          array( 'idempotency_key' => "translate:$nodeID:ger-DE:" . $object->attribute( 'current_version' ) ) );
return $Module->redirectTo( '/expqueue/job/' . $job->attribute( 'uuid' ) );
```

## The built-in test types

| Type | Payload | Use |
|---|---|---|
| `expqueue.noop` | `echo` | checks that a worker runs ("Send a test job") |
| `expqueue.sleep` | `seconds`, `steps`, `fail_rate`, `checkpoint` | load, fairness, cancel, reaper tests |
| `expqueue.fail` | `mode` (retryable, permanent, exception, rate_limit), `retry_after`, `succeed_on` | retries, backoff, dead letter, rate limits |
