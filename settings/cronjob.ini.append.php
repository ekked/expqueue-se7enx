<?php /* #?ini charset="utf-8"?

# The cron part "expqueue" (run it every minute):
#   * * * * * cd <installation> && php runcronjobs.php -q expqueue
# Each run does the maintenance (promote, reap expired leases, lost workers), purges old jobs once an hour and,
# when no other worker is alive, runs a worker slice of [WorkerSettings] CronMaxSeconds seconds that stops as soon
# as nothing is ready. It is the default worker and the safety net next to a systemd service.
[CronjobSettings]
ExtensionDirectories[]=expqueue

[CronjobPart-expqueue]
Scripts[]=expqueue.php

*/ ?>
