# Troubleshooting

| Symptom | Check |
|---|---|
| Jobs stay `ready`, "Workers alive 0" | Is the cron part in the crontab (`php runcronjobs.php -q expqueue` every minute, as the site user)? The dashboard shows when it last ran. Run `./console ext:expqueue:work --once` by hand and read its output. |
| The page says the tables are missing | `./console ext:expqueue:install-schema` |
| Jobs of one class never start | Is the class paused (dashboard, `status`)? At `MaxRunning`? A worker started with `--class` that excludes it? |
| Jobs of one resource never start | Paused (a 401/403 pauses it: fix the credentials, then resume), cooling down after a 429, or at its limit (`status` shows running / limit). |
| A job is `running` but nothing happens | Its lease: `show <uuid>`. When the worker died, the maintenance gives the job back after `timeout + LeaseMargin`. A handler that works longer must call `progress()` or `heartbeat()`. |
| A job ran twice | After a lease expired (the worker was killed, or the handler ran past its timeout without a heartbeat). Make the handler idempotent and use the checkpoint. The history shows `reap` and two `claim` events. |
| Many jobs in the dead letter | `list --state=dead`, `show <uuid>` for the last error and error class; fix the cause, then `retry --dead [--type=...]`. |
| "quota reached" at enqueue | `[QueueQuotas] MaxQueuedPerUser` / `MaxQueuedPerSite`. |
| "unknown job type" | The `[JobType_<type>] Handler=` of the extension that queues it: is that extension active where the producer runs, and are the autoloads regenerated? |
| "the queue is busy" | The dispatcher lock could not be taken in 15 s: a stuck process holding `var/<vardir>/jobs/expqueue/dispatch.lock` (`fuser` it), or with `DatabaseMutex` a host that died within `DispatchLockSeconds`. |
| SQLite "database is locked" | Long transactions elsewhere; the queue's own statements are short. Fewer workers help on SQLite; MySQL or PostgreSQL scale further. |
| Root-owned files in `var/` | Every expqueue command drops to the site user; check that the installation's `var/` belongs to the site user (that is how it is found). |
| The systemd worker does not start | `./console ext:expqueue:service status`, `journalctl -u <unit>@1`; the unit runs `work.php` as the site user. |
| The admin controls do nothing | The policy `expqueue/manage` and the extension ezformtoken. |
