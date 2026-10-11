# Architecture

```
 producer (web request, CLI, cron, another job)            worker (CLI / cron part / systemd; never a web request)
   expQueue::enqueue( type, payload, options )               expQueueWorker::run()
        |  under the dispatcher lock: idempotency,              |  loop: maintenance, claim, run, finish
        |  quotas, rules, insert + event                        v
        v                                                    expQueueScheduler::claim()  (dispatcher lock)
   expqueue_job (state ready | queued)  <------------------    eligible classes -> order -> candidates -> CAS lease
                                                              handler->run( job, context )  (outside transactions)
                                                              finish: CAS on the lease, event, dependants, group
```

## Pieces

| Class | Role |
|---|---|
| `expQueue` | The facade: enqueue, groups, fetch, cancel, retry, pause/resume, purge, counts, audit |
| `expQueueJob`, `expQueueGroup`, `expQueueEvent` | Persistent objects of `expqueue_job`, `expqueue_group`, `expqueue_event` |
| `expQueueScheduler` | The dispatch round (claim) and the maintenance (promote, reap, lost workers) |
| `expQueueWorker` | The loop; runs a job as its user, ends it, backoff, signals, memory limits, heartbeat |
| `expQueueContext` | What a handler gets: heartbeat, cancel checks, progress, checkpoint, rate-limit hints, cost, log |
| `expQueueHandler`, `expQueueHandlerBase`, `expQueueResult` | The handler contract |
| `expQueueResource` | The concurrency limiter of a resource, adaptive to rate-limit hints |
| `expQueueLock` | The dispatcher lock (flock + optional database mutex), the queue directory, the site user, dropping privileges |
| `expQueueSchema` | The tables for every engine, install and upgrade |
| `expQueueStats` | The figures of the dashboard and `status` |
| `expQueueService` | The systemd unit |
| `expQueueCommand` | The CLI commands |
| `expQueueAdmin` | Helpers of the admin pages |
| `expQueueAuditBranch` | `system.queue.*` in the audit trail |

## States

```
 queued --(parent done / not-before passed)--> ready --(claim)--> running --(done)--------> done
   |                                             ^                   |--(retryable error)--> retry --(backoff)--> ready
   |                                             |                   |--(no attempt left / permanent)--> dead
   |                                             +--(lease expired)--|--(defer)--> retry (attempt not counted)
   |                                                                 |--(hold)---> held --(requeue / group resumed)--> ready
   +--(parent dead or cancelled)--> cancelled <----(cancel; running: at the next check)----+
 dead / cancelled / held / retry --(requeue: attempts reset)--> ready
```

Only `expQueue`, `expQueueScheduler` and `expQueueWorker` change a state, always with a compare-and-set update:
the expected state (and for a running job its lease owner) in the WHERE clause, then a read-back, because eZDB
reports no affected rows. The loser of a race sees that its values are not in the row and moves on. Each change
writes an event row (the job's history); operator actions and dead letters also go to the audit trail
(`system.queue.*`).

## Claiming and leases

A claim sets `state=running`, `lease_owner=<host:pid:random#n>`, `lease_until = now + timeout + LeaseMargin`,
`attempts+1`, where `state='ready' AND attempts=<read value>`. `$context->heartbeat()` (also called by `progress()`)
extends the lease while the job runs. The maintenance gives a job whose lease expired back to `ready` (the attempt
counts) or to the dead letter when no attempt is left. A run that ends after its lease was taken changes nothing
(its finish is a compare-and-set on its own lease owner) and records a `lost` event.

## Locks

The dispatcher lock serialises the short decisions (enqueue with idempotency and quotas, a dispatch round, the
maintenance), never the work:

- a local `flock` on `var/<vardir>/jobs/expqueue/dispatch.lock` (all processes of the host: Apache/FPM, Velocity,
  CLI workers);
- with `DatabaseMutex=enabled` (default `auto`: every engine but SQLite) also the row `dispatch` of `expqueue_mutex`,
  taken by compare-and-set with an expiry, for clusters of several hosts.

Transactions stay short: no handler runs inside one; a handler that leaves one open is rolled back.

## Root and the site user

Velocity runs as root, Apache/FPM as the site user. Web requests only queue jobs. Every expqueue command (but
`service`) becomes the site user before it reads a setting or opens the database (the content job worker's
`dropPrivileges()`), so neither the SQLite journal nor the lock files ever belong to root. The queue directory is
0770 with a deny-all `.htaccess`, and files root creates there are given to the site user. The cron part run as root
starts its worker slice as a separate process that drops privileges.

## What it is not

Not the kernel's content jobs (`expContentJob*`: one JSON file and one detached worker per large subtree operation).
expqueue is for many small jobs with priorities and limits; it reuses the content jobs' privilege dropping, file
ownership and cron safety net.
