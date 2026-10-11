# Configuration (expqueue.ini)

Override in `settings/override/expqueue.ini.append.php` (or a siteaccess, or another extension's
`settings/expqueue.ini.append.php` for job types). Every setting falls back to the default below when it is missing.

## [QueueSettings]

| Setting | Default | Meaning |
|---|---|---|
| `Paused` | disabled | enabled: no worker starts a new job (the admin's "Pause queue" does the same in the database) |
| `Classes[]` | interactive, editorial, chain, translation_patch, translation_full, bulk, system | the priority classes, in display order |
| `DefaultClass` | bulk | class of jobs that name none |
| `StarvationSeconds` | 1800 | a class / job ready longer than this is served first |
| `AgingStep` | 120 | +1 effective priority per this many seconds of waiting |
| `AgingMax` | 40 | at most this much aging |
| `MinShareWindow` | 600 | seconds over which MinShare is measured |
| `CandidateLimit` | 50 | candidates read per class and order in a dispatch round |
| `DefaultTimeout` | 300 | seconds a run may take (lease = timeout + LeaseMargin) |
| `DefaultMaxAttempts` | 5 | attempts before the dead letter |
| `LeaseMargin` | 60 | seconds a lease lasts beyond the timeout |
| `RetryBase` | 30 | backoff base (seconds) |
| `MaxBackoff` | 3600 | backoff cap (seconds) |
| `IdempotencyWindow` | 86400 | a done job's idempotency key stays taken this long |
| `KeepDays` | 30 | purge done and cancelled jobs older than this |
| `KeepDeadDays` | 90 | purge dead jobs older than this |
| `DatabaseMutex` | auto | dispatcher lock in the database too: enabled, disabled, auto (all engines but SQLite) |
| `DispatchLockSeconds` | 30 | expiry of the database lock |
| `MaintenanceInterval` | 5 | seconds between two maintenance rounds of a worker |
| `SiteName` | (empty) | the site for quotas; empty = site.ini SiteName |

## [QueueClass_<name>]

`Weight`, `MaxRunning` (0 = none), `MinShare` (0..1), `DefaultPriority` (0..100), `Reserved` (enabled/disabled),
`MaxAttempts` (0 = DefaultMaxAttempts). Defaults: see [scheduling.md](scheduling.md).

## [QueueQuotas]

`MaxQueuedPerUser`, `MaxRunningPerUser`, `MaxQueuedPerSite`, `MaxRunningPerSite` (0 = none; default 0).

## [QueueRules] and [QueueRule_<name>]

`Rules[]` names the rules in order. A rule matches on `Type` (pattern), `MatchResource` (pattern), `Site`, `Tag` and
sets `Class`, `Priority`, `Resource`, `MaxAttempts`.

## [ResourceSettings] and [QueueResource_<key>]

| Setting | Default | Meaning |
|---|---|---|
| `MaxConcurrent` | 4 | jobs of the resource at once (the ceiling of the adaptive limit) |
| `MinConcurrent` | 1 | floor of the adaptive limit |
| `Adaptive` | enabled | follow rate-limit hints |
| `IncreaseAfter` | 10 | successes in a row before the limit grows by one |
| `LowWater` | 2 | remaining requests at which the limit drops to MinConcurrent |
| `DefaultCooldown` | 30 | seconds of cooldown after a 429 without retry-after |

## [WorkerSettings]

| Setting | Default | Meaning |
|---|---|---|
| `MaxJobs` | 500 | a worker run leaves after this many jobs (0 = none) |
| `MaxSeconds` | 3600 | ... after this many seconds (0 = none) |
| `MemoryLimit` | 256M | ... when its memory reaches this |
| `PollInterval` | 1 | seconds between empty rounds (grows up to IdlePollMax) |
| `IdlePollMax` | 5 | |
| `Heartbeat` | 10 | seconds between heartbeats of a worker |
| `StaleSeconds` | 90 | a worker without a heartbeat this long counts as lost |
| `CronMaxSeconds` | 50 | length of the cron part's worker slice |
| `CronSkipWhenWorkerAlive` | enabled | the cron part runs no slice while another worker is alive |
| `PhpBinary` | (empty) | PHP for the slice a root cron starts (empty = the running one) |

## [ServiceSettings]

| Setting | Default | Meaning |
|---|---|---|
| `UnitName` | auto | `expqueue-<installation directory>` |
| `UnitDirectory` | /etc/systemd/system | |
| `Instances` | 1 | worker processes |
| `Nice` | 10 | |
| `CPUWeight` | 30 | |
| `MemoryMax` | 512M | |
| `TasksMax` | 64 | |
| `PhpBinary` | (empty) | PHP for the unit (empty = the one running the command) |

## [AdminSettings]

`ListLimit` (50): jobs per page of the list.

## [JobType_<type>]

| Setting | Meaning |
|---|---|
| `Handler` | the class implementing `expQueueHandler` (required) |
| `Class`, `Priority`, `MaxAttempts`, `Timeout`, `Resource` | defaults of its jobs |
| `RetryBase`, `MaxBackoff` | its backoff |
| `Description` | shown in the documentation of the type |

Built-in: `expqueue.noop` (class system, timeout 30), `expqueue.sleep` (timeout 120), `expqueue.fail` (3 attempts,
RetryBase 2, MaxBackoff 60, timeout 30).

## Other settings files of the extension

`module.ini` (the module), `design.ini` (templates), `menu.ini` (Setup > Job queue), `cronjob.ini` (the part
`expqueue`), `audit.ini` (the branch `system.queue.*`), `site.ini` (translations).
