# Using expqueue

## Queue a job (PHP)

```php
$job = expQueue::enqueue( 'mysite.report', array( 'month' => '2026-10' ), array(
    'class' => 'bulk',                      // a priority class of [QueueSettings] Classes[]
    'priority' => 60,                       // 0..100 within the class
    'idempotency_key' => 'report:2026-10',  // queueing it again returns the same job
    'resource' => 'reporting-api',          // at most [QueueResource_reporting-api] MaxConcurrent at once
    'not_before' => 600,                    // seconds from now (or a timestamp)
    'max_attempts' => 3,
    'timeout' => 900,
) );
```

Register the type and its handler:

```ini
# extension/mysite/settings/expqueue.ini.append.php
[JobType_mysite.report]
Handler=mySiteReportHandler
Class=bulk
```

The handler implements `expQueueHandler` (or extends `expQueueHandlerBase`): see [doc/api.md](doc/api.md).

## Watch and steer

- Setup > Job queue: the dashboard, the job list (filters by state, class, type, resource, group), a job's history.
- `./console ext:expqueue:status`, `list --state=dead`, `show <uuid>`.
- Pause: `./console ext:expqueue:pause class bulk` (or `queue`, `resource <key>`, `group <uuid>`); `resume` the same.
- Cancel: `./console ext:expqueue:cancel <uuid>` (a running job stops at its next check), `--group=<uuid>`.
- Dead letter: `./console ext:expqueue:retry --dead` puts every dead job back with its attempts reset.
- Old jobs: the cron part purges done and cancelled jobs after `KeepDays`, dead ones after `KeepDeadDays`;
  `./console ext:expqueue:purge --dry-run` shows what would go.

## Run jobs

- Cron (default): `php runcronjobs.php -q expqueue` every minute.
- A worker by hand: `./console ext:expqueue:work` (until `--max-jobs` / `--max-seconds`), `--once`, `--until-empty`,
  `--class=editorial,interactive`, `--resource=imaging`.
- A systemd service: `./console ext:expqueue:service install|start|stop|status|uninstall` (root).

Workers started as root become the site user first. Jobs never run inside a web request or a Velocity worker.
