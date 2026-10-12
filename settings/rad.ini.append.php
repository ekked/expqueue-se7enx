<?php /* #?ini charset="utf-8"?

# The registries of the job queue, counted and checked by the extension point survey
# (Setup > RAD tools > Extension point survey, setup/radsurvey/(show)/registries). What a block holds is
# described in settings/rad.ini of the kernel; doc/architecture.md "Registries in the extension point survey".

[RegistrySettings]
Registries[]=expqueue_job_types
Registries[]=expqueue_job_type_classes
Registries[]=expqueue_classes
Registries[]=expqueue_resources
Registries[]=expqueue_commands

[Registry_expqueue_job_types]
Title=Queue job types
Description=The kinds of job a worker runs (expqueue.ini [JobType_<type>] Handler=, implementing expQueueHandler), the queue's own and every extension's.
Doc=extension/expqueue/doc/api.md
TranslationContext=extension/expqueue/rad
Ini=expqueue.ini
Section=JobType_*
Entries[Handler]=expQueueHandler

[Registry_expqueue_job_type_classes]
Title=Queue job type priority classes
Description=The priority class each job type runs in (expqueue.ini [JobType_<type>] Class=, a [QueueClass_<class>] block); refers to the job types, so not added again.
Doc=extension/expqueue/doc/scheduling.md
TranslationContext=extension/expqueue/rad
Ini=expqueue.ini
Section=JobType_*
Entries[Class]=section:QueueClass_
InTotal=disabled

[Registry_expqueue_classes]
Title=Queue priority classes
Description=The lanes the scheduler shares the workers between (expqueue.ini [QueueSettings] Classes[], each with its [QueueClass_<class>]).
Doc=extension/expqueue/doc/scheduling.md
TranslationContext=extension/expqueue/rad
Ini=expqueue.ini
Section=QueueSettings
Entries[Classes]=section:QueueClass_

[Registry_expqueue_resources]
Title=Queue resources
Description=The resources whose concurrency the queue limits (expqueue.ini [QueueResource_<resource>]).
Doc=extension/expqueue/doc/scheduling.md
TranslationContext=extension/expqueue/rad
Ini=expqueue.ini
Section=QueueResource_*
Entries[MaxConcurrent]=name

[Registry_expqueue_commands]
Title=Queue commands
Description=The commands ./console ext:expqueue:<name> (expQueueCommand::COMMANDS).
Doc=extension/expqueue/doc/cli.md
TranslationContext=extension/expqueue/rad
List=expQueueCommand::COMMANDS

*/ ?>
