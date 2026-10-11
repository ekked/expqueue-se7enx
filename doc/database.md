# Database

Seven tables, defined once in `expQueueSchema::definition()` (the kernel's generic schema format) and created with
the kernel's schema handler of the database. Names stay within Oracle's 30 characters; no column is a reserved word
of any engine (hence `resource_key`, `stride_pass`, `origin`, `expires`).

| Table | Rows | Key columns |
|---|---|---|
| `expqueue_job` | one per job | id, uuid (unique), type, class, priority, state, group_id, parent_id, resource_key, site, user_id, idempotency_key, attempts, max_attempts, timeout, run_after, ready_since, deadline, lease_owner, lease_until, cancel_requested, progress_*, cost_*_micros, payload, checkpoint, result (JSON), error_class, last_error, created, modified, started, finished |
| `expqueue_group` | one per group | id, uuid (unique), label, type, user_id, site, state, total, budget_micros, spent_micros |
| `expqueue_event` | the history | id, job_id, group_id, ts, kind, attempt, worker, message, data (JSON) |
| `expqueue_resource` | limiter state | resource_key (PK), paused, max_concurrent (current limit), cooldown_until, remaining_requests, remaining_tokens, reset_at, success_streak, last_status |
| `expqueue_class` | class state | name (PK; `*` = the queue), paused, stride_pass |
| `expqueue_mutex` | named locks and stamps | name (PK: `dispatch`, `cron`, `purge`), owner, expires |
| `expqueue_worker` | workers | worker_id (PK), host, pid, os_user, origin, started, heartbeat, jobs_done, jobs_failed, current_job, state, filter |

Indexes of `expqueue_job`: (state, class, run_after), (group_id, state), (resource_key, state), (user_id, state),
(type, idempotency_key), (parent_id), (state, finished), unique (uuid).

## Per engine

| Engine | File | Notes |
|---|---|---|
| MySQL / MariaDB | `sql/mysql/schema.sql` | InnoDB |
| PostgreSQL | `sql/postgresql/schema.sql` | sequences for the ids |
| SQLite | `sql/sqlite/schema.sql` | one writer at a time: every statement of the queue is short |
| Oracle | `sql/oracle/schema.sql` | sequences `se_expqueue_*` and triggers; empty strings are NULL (the code never compares with '') |
| MongoDB | `sql/mongodb/schema.json` | collections with the same fields and indexes; counts are made in PHP (no GROUP BY) |

`share/db_schema.dba` is the generic schema for package installers.

## Install and upgrade

```bash
./console ext:expqueue:install-schema           # creates missing tables, columns and indexes (idempotent)
./console ext:expqueue:install-schema --check   # lists what is missing
./console ext:expqueue:install-schema --print=oracle
./console ext:expqueue:install-schema --write-files   # regenerates share/ and sql/ from the definition
```

A later version that adds a column or an index is installed by the same command (ALTER TABLE ADD / CREATE INDEX from
the same handler).

## Verified (2026-10-11)

Install, a second idempotent install, enqueue, idempotent duplicate, compare-and-set claim (a second claim loses),
run to done with UTF-8 in the result, the dead letter, cancel, counts per state, the dashboard report, purge and
dropping the tables again passed on SQLite, MariaDB, PostgreSQL and Oracle (throwaway databases). MongoDB: the schema
description is generated, not run (no throwaway MongoDB database was available).

## Size

A job with its ~3 events is about 1 KB on SQLite. The cron part purges done jobs after `KeepDays` (30) and dead ones
after `KeepDeadDays` (90).
