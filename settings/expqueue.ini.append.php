<?php /* #?ini charset="utf-8"?

# expqueue: the generic job queue of Exponential. Every setting is described in doc/configuration.md.
# Override in settings/override/expqueue.ini.append.php (or a siteaccess); never edit this file on a site.

[QueueSettings]
# enabled stops every worker from starting new jobs (jobs that run finish); the admin's "Pause queue" does the
# same per installation without a settings change
Paused=disabled
# The priority classes, in the order the admin shows them. Each has a group [QueueClass_<name>] below.
Classes[]
Classes[]=interactive
Classes[]=editorial
Classes[]=chain
Classes[]=translation_patch
Classes[]=translation_full
Classes[]=bulk
Classes[]=system
# The class of jobs whose type and producer name none
DefaultClass=bulk
# Starvation guard: a class whose oldest ready job waited longer than this is served first
StarvationSeconds=1800
# Aging: the effective priority of a waiting job grows by 1 per AgingStep seconds, up to AgingMax
AgingStep=120
AgingMax=40
# The window (seconds) in which MinShare is measured
MinShareWindow=600
# Candidates tried per class in a dispatch round
CandidateLimit=50
# Defaults of a job that its type and producer leave open
DefaultTimeout=300
DefaultMaxAttempts=5
# Seconds a lease lasts beyond the job's timeout
LeaseMargin=60
# Backoff of retries: max( retry_after, min( MaxBackoff, RetryBase * 2^(attempt-1) ) * random(0.5..1) )
RetryBase=30
MaxBackoff=3600
# An idempotency key is unique per type among active jobs and done jobs younger than this
IdempotencyWindow=86400
# The cron part and ./console ext:expqueue:purge remove done and cancelled jobs older than KeepDays and dead jobs
# older than KeepDeadDays (with their events)
KeepDays=30
KeepDeadDays=90
# The dispatcher lock across hosts (a row of expqueue_mutex): enabled, disabled, or auto (every engine but SQLite)
DatabaseMutex=auto
DispatchLockSeconds=30
# Seconds between two maintenance rounds of a worker (promote, reap, lost workers)
MaintenanceInterval=5
# The site jobs are counted against for the per-site quotas; empty = site.ini [SiteSettings] SiteName
SiteName=

# Weight: share of the starts while several classes have ready jobs (stride scheduling)
# MaxRunning: jobs of the class that run at once across all workers (0 = no limit)
# MinShare: guaranteed fraction of the starts while the class has ready jobs (0..1)
# DefaultPriority: 0..100 when the producer names none
# Reserved: enabled = served before every other class (system work: polling, pruning); not part of the fair share
[QueueClass_interactive]
Weight=50
MaxRunning=4
MinShare=0
DefaultPriority=50

[QueueClass_editorial]
Weight=30
MaxRunning=4
MinShare=0.10
DefaultPriority=50

[QueueClass_chain]
Weight=15
MaxRunning=3
MinShare=0.05
DefaultPriority=50

[QueueClass_translation_patch]
Weight=10
MaxRunning=3
MinShare=0.05
DefaultPriority=50

[QueueClass_translation_full]
Weight=5
MaxRunning=3
MinShare=0.05
DefaultPriority=50

[QueueClass_bulk]
Weight=4
MaxRunning=2
MinShare=0.05
DefaultPriority=50

[QueueClass_system]
Weight=10
MaxRunning=1
Reserved=enabled
DefaultPriority=50

# Quotas (0 = none)
[QueueQuotas]
MaxQueuedPerUser=0
MaxRunningPerUser=0
MaxQueuedPerSite=0
MaxRunningPerSite=0

# Rules: the first that matches sets class, priority, resource or max attempts at enqueue time (what the producer
# passes explicitly still wins). Match on Type (a pattern with *), MatchResource (a pattern), Site and Tag.
[QueueRules]
Rules[]
#Rules[]=news_translations_fast
#[QueueRule_news_translations_fast]
#Type=ai.translate.*
#Tag=section:news
#Class=editorial
#Priority=70

# The defaults of every resource; [QueueResource_<key>] overrides them for one key (e.g. [QueueResource_imaging]).
# MaxConcurrent: jobs of the resource at once; MinConcurrent: the floor of the adaptive limit; Adaptive: halve the
# limit on 429 / retry-after, grow it by one after IncreaseAfter successes in a row; LowWater: remaining requests at
# which the limit drops to MinConcurrent; DefaultCooldown: seconds a 429 without retry-after pauses the resource
[ResourceSettings]
MaxConcurrent=4
MinConcurrent=1
Adaptive=enabled
IncreaseAfter=10
LowWater=2
DefaultCooldown=30

[WorkerSettings]
# Limits of one worker run; a systemd worker is restarted after it leaves at a limit
MaxJobs=500
MaxSeconds=3600
MemoryLimit=256M
# Seconds between two empty dispatch rounds (it backs off up to IdlePollMax)
PollInterval=1
IdlePollMax=5
# Seconds between two heartbeats of a worker, and after which a worker without one counts as lost
Heartbeat=10
StaleSeconds=90
# The cron part: the seconds of its worker slice, and whether it skips the slice while another worker is alive
CronMaxSeconds=50
CronSkipWhenWorkerAlive=enabled
# The PHP command line binary for workers the cron part starts as root (empty: the one running)
PhpBinary=

# ./console ext:expqueue:service install (a systemd unit for the site user; root only)
[ServiceSettings]
# The unit's name; auto = expqueue-<installation directory name>
UnitName=auto
UnitDirectory=/etc/systemd/system
# Worker processes (instances of the unit template)
Instances=1
Nice=10
CPUWeight=30
MemoryMax=512M
TasksMax=64
# The PHP binary for the unit (empty: the one running the command)
PhpBinary=

[AdminSettings]
# Jobs per page of expqueue/list
ListLimit=50

# The job types: [JobType_<type>] Handler=<class implementing expQueueHandler>, optional Class, Priority,
# MaxAttempts, Timeout, Resource, RetryBase, MaxBackoff, Description.
[JobType_expqueue.noop]
Handler=expQueueNoopHandler
Class=system
Timeout=30
Description=Does nothing (checks that a worker runs)

[JobType_expqueue.sleep]
Handler=expQueueSleepHandler
Timeout=120
Description=Waits in steps (load and fairness tests)

[JobType_expqueue.fail]
Handler=expQueueFailHandler
MaxAttempts=3
RetryBase=2
MaxBackoff=60
Timeout=30
Description=Fails on purpose (retries, backoff, dead letter)

*/ ?>
