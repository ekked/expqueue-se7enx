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

The pages are built from the administration's shared components (`.a4-page`, `.a4-card`, `.a4-table`, `.a4-figures`,
`.a4-badge`, `.a4-tag`, `.a4-btn`, `.a4-notice`, `.a4-empty`, `.a4-meter` with `.a4-pct-*`) and take every colour,
radius and space from the `--a4-*` tokens, which have a light and a dark value, so they follow admin4's dark mode.
What the components cannot do (the hourly chart, the filter rows, the narrow-window rules) is in
`design/admin/stylesheets/expqueue.css` as `.a4-queue-*` classes, loaded through `design.ini [StylesheetSettings]
BackendCSSFileList`. No template carries a `<style>` block or a `style=""` attribute; a per-element amount (a bar's
height, a progress) is an `.a4-pct-<n>` class. The DB-less test `tests/unit/StylingRulesTest.php` (run `phpunit` in the
extension) fails on inline CSS, colour literals or a custom property of the extension's own. One template set serves
admin, admin4 and admin4l.

No template carries an inline script or an `on...=` event handler attribute either, so the pages run under a Content
Security Policy without `'unsafe-inline'`. A control that asks before it is sent (`$confirm` of
`expqueue/parts/button.tpl`) declares its question in `data-a4-confirm`: admin4 and admin4l ask it with their
`a4_actions.js`, the other administration designs with `design/admin/javascript/expqueue_confirm.js`, loaded through
`design.ini [JavaScriptSettings] BackendJavaScriptList`. `tests/unit/ScriptRulesTest.php` fails on an inline script or
handler.
