# Commands

All are `./console ext:expqueue:<name>` (or `php extension/expqueue/bin/php/<name>.php`); `--help` lists the options.
Started as root, every command but `service` becomes the site user first. Exit codes: 0 success, 1 failure, 2
nothing to do, 3 unknown job or group.

| Command | Does |
|---|---|
| `work [--once] [--until-empty] [--max-jobs=N] [--max-seconds=N] [--class=a,b] [--resource=x,y] [--memory=256M] [--origin=cli]` | runs jobs (see [workers-cron-systemd.md](workers-cron-systemd.md)) |
| `status [--json]` | states, classes, resources, live workers, the cron part's last run, the service |
| `list [--state=..] [--class=..] [--type=..] [--resource=..] [--group=<uuid>] [--limit=50] [--offset=0] [--json]` | jobs, newest first |
| `show <uuid|id> [--events=50] [--json]` | one job, its payload (masked), result and history |
| `enqueue <type> [--payload='{json}'] [--class=] [--priority=] [--group=<uuid>] [--new-group=<label>] [--idempotency-key=] [--resource=] [--not-before=] [--max-attempts=] [--timeout=] [--depends-on=] [--count=N] [--json]` | queues jobs (tests: `expqueue.noop`, `expqueue.sleep`, `expqueue.fail`) |
| `cancel <uuid|id>... [--reason=]` / `cancel --group=<uuid>` | cancels |
| `pause queue` / `pause class <name>` / `pause resource <key>` / `pause group <uuid>` | pauses (a bare name: a class, a group uuid or a resource) |
| `resume ...` | resumes the same |
| `retry <uuid|id>...` / `retry --dead [--type=]` | requeues with the attempts reset |
| `purge [--days=N] [--dead-days=N] [--type=] [--dry-run]` | removes old done, cancelled and dead jobs with their events |
| `install-schema [--check] [--print=<engine>] [--write-files]` | creates or upgrades the tables (default), reports what is missing, prints the SQL, regenerates `share/` and `sql/` |
| `service install|start|stop|status|uninstall [--dry-run] [--instances=N]` | the systemd service (root, except status and --dry-run) |

Examples:

```bash
./console ext:expqueue:enqueue expqueue.sleep --payload='{"seconds":5}' --count=20 --new-group="load test"
./console ext:expqueue:list --state=dead
./console ext:expqueue:show 3f2c...
./console ext:expqueue:pause resource anthropic:batch
./console ext:expqueue:retry --dead --type=mysite.translate
./console ext:expqueue:purge --days=7 --dry-run
```
