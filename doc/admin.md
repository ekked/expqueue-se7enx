# Admin pages: Setup > Job queue

The module `expqueue` (admin siteaccesses; the entry is in Setup's left menu for users with `expqueue/view`). Pages
take view parameters only.

| Page | Shows |
|---|---|
| `expqueue/dashboard` | Key figures (ready, running, waiting or retrying, dead letter, done in the last hour, oldest ready job, workers alive); one chart: jobs that ended per hour over 24 hours (done and dead, with a table view); the priority classes (weight, ready, running / MaxRunning, waiting, dead, oldest, p95 wait and done in the last hour); resources (running / current limit, cooldown, last status); workers (cron part last run, systemd service, live workers); what runs now with progress; the newest dead jobs; the newest groups |
| `expqueue/list/(state)/<s>/(class)/<c>/(type)/<t>/(resource)/<r>/(group)/<uuid>/(offset)/<n>` | Jobs, newest first, with state and class chips (`(state)/active` = every state that has not ended) |
| `expqueue/job/<uuid>` | Type, class, priority, resource, attempts, times, lease, user, idempotency key, group, parent, last error, progress; the parameters (masked and shortened), the result, whether a checkpoint is stored; the history (every event with its attempt and worker) |
| `expqueue/group/<uuid>` | Progress, counts per state (links to the list), the jobs |

## Controls (policy `expqueue/manage`)

POST forms to `expqueue/action`, protected by ezformtoken: pause / resume the queue, a class, a resource or a group;
cancel a job (a running one stops at its next check) or a group; requeue a job or every dead job; "Send a test job"
(queues `expqueue.noop` and opens its page). Operator actions are written to the audit trail (`system.queue.*`).

## Policies

| Policy | Allows |
|---|---|
| `expqueue/view` | every page |
| `expqueue/manage` | the controls |

Neither has limitations in 0.1.0.

## Look

The pages use admin4's tokens (`--a4-*`) where they exist and fall back to their own values in the older admin
designs; the chart's two colours were checked for colour-vision deficiencies and contrast on the white card.
