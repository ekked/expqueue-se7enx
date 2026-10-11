# Workers: the CLI, cron and systemd

A worker leases one job at a time, runs it, ends it and takes the next, until a limit is reached. Several workers
(on one host or several) share the work through the dispatcher lock and the compare-and-set leases. Jobs never run
in a web request or in a Velocity worker: `expQueueWorker` refuses to start there.

## The worker command

```bash
./console ext:expqueue:work                       # until [WorkerSettings] MaxJobs / MaxSeconds / MemoryLimit
./console ext:expqueue:work --once                # at most one job
./console ext:expqueue:work --until-empty         # until nothing is ready
./console ext:expqueue:work --class=interactive,editorial --resource=imaging --max-seconds=600 --max-jobs=100
```

- Started as root it becomes the site user (the owner of `var/`) before it reads a setting or opens the database.
- Between jobs it clears the kernel's in-memory caches; memory stays flat. It leaves at the limits on purpose, so a
  supervisor (systemd, cron) starts a fresh process.
- SIGTERM / SIGINT: it finishes the job it runs, then leaves (with pcntl). A job longer than the stop timeout is
  killed with the process; its lease expires and it runs again.
- Its row in `expqueue_worker` (heartbeat every `Heartbeat` seconds) is what the dashboard and the cron part read.

## The cron part (the default)

```cron
* * * * * cd /path/to/installation && php runcronjobs.php -q expqueue >> var/log/cronjob-expqueue.log 2>&1
```

as the site user. Each run:

1. maintenance: retry and not-before jobs that are due become ready, queued children of done parents become ready,
   expired leases are reaped (the job runs again, or goes to the dead letter when no attempt is left), workers
   without a heartbeat are marked lost;
2. once an hour the purge (`KeepDays`, `KeepDeadDays`);
3. unless another worker is alive (`CronSkipWhenWorkerAlive`), a worker slice of `CronMaxSeconds` seconds that
   stops as soon as nothing is ready. A cron of root starts the slice as a separate process that becomes the site
   user.

So a job waits at most about a minute without any other worker, and a systemd worker makes the cron part a pure
safety net (maintenance, purge, and a slice if the service stopped).

## The systemd service

```bash
./console ext:expqueue:service install --dry-run   # anyone: shows the unit and the commands
./console ext:expqueue:service install             # root: writes <UnitName>@.service, daemon-reload, enable --now @1..@N
./console ext:expqueue:service status              # anyone: systemctl is-active and the workers' heartbeats
./console ext:expqueue:service stop | start
./console ext:expqueue:service uninstall           # root: disable --now, remove the unit, daemon-reload
./console ext:expqueue:service install --instances=2
```

The unit (`share/systemd/expqueue-worker@.service.in`, filled from the installation and `[ServiceSettings]`):

- `User=`/`Group=` the site user (the owner of `var/`); it refuses to install when the installation belongs to root;
- `ExecStart=<php> extension/expqueue/bin/php/work.php --origin=systemd --max-seconds=<MaxSeconds> --max-jobs=<MaxJobs>`;
- `Restart=always`, `RestartSec=10`: the worker leaves on purpose at its limits with exit code 0, which
  `Restart=on-failure` would not restart; `StartLimitBurst=20` per 300 s stops a crash loop;
- `Nice=10`, `CPUWeight=30`, `IOSchedulingClass=best-effort`/`7`, `MemoryMax=512M`, `TasksMax=64`, `UMask=0007`,
  `NoNewPrivileges`, `PrivateTmp`, `ProtectSystem=full`;
- `TimeoutStopSec` = `DefaultTimeout + LeaseMargin`, so a stop lets the running job finish.

What the command did last is kept in `var/<vardir>/jobs/expqueue/service.json` for the dashboard (a web request does
not ask systemd).

## Several hosts

Point every host at the same database, run a worker (or the cron part) on each, and set
`[QueueSettings] DatabaseMutex=enabled` (the default `auto` already enables it on every engine but SQLite).

## In Velocity and the web

Pages only queue. After queueing interactive work a page can tell the user that the job is queued and link to
`/expqueue/job/<uuid>`; a worker picks it up within the cron interval (or at once with the service).
