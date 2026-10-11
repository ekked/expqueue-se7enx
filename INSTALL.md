# Installing expqueue

Requirements: Exponential 6.0.14 or later, PHP 8.0 or later with json and mbstring; posix (workers started as root
become the site user) and pcntl (a worker finishes its job on SIGTERM) are recommended. The extension ezformtoken
protects the admin controls.

## 1. The files

With Composer: `composer require se7enxweb/expqueue` (the legacy installer puts it into `extension/expqueue`).
By hand: copy the directory to `extension/expqueue`, owned by the site user like the other extensions.

## 2. Activate it

Globally, so producers on every siteaccess and the workers see it, in `settings/override/site.ini.append.php`:

```ini
[ExtensionSettings]
ActiveExtensions[]=expqueue
```

## 3. The tables

```bash
./console ext:expqueue:install-schema           # creates what is missing (idempotent; also the upgrade)
./console ext:expqueue:install-schema --check   # only reports missing tables, columns and indexes
```

It uses the kernel's schema handler of the database (MySQL, PostgreSQL, SQLite, Oracle, MongoDB). The SQL per engine
is also in `sql/<engine>/schema.sql`, the MongoDB collections and indexes in `sql/mongodb/schema.json`, and the
generic schema in `share/db_schema.dba` (for package installers).

## 4. Autoloads, caches, the web servers

```bash
php bin/php/ezpgenerateautoloads.php -e
./console exp:velocity deploy --allow-root-user     # or clear the INI, template, template-override and translation
                                                    # caches and reload PHP-FPM by hand
```

Velocity workers keep the class map of their warm-up: restart Velocity after the first installation.

## 5. A worker

Cron is the default (at most one minute until a job starts). As the site user, every minute:

```cron
* * * * * cd /path/to/installation && php runcronjobs.php -q expqueue >> var/log/cronjob-expqueue.log 2>&1
```

Optionally a systemd service next to it, for shorter waits and longer jobs (cron stays the safety net):

```bash
./console ext:expqueue:service install --dry-run   # shows the unit it would write
./console ext:expqueue:service install             # as root: writes the unit for the site user, enables and starts it
```

## 6. Permissions

Give `expqueue/view` (the pages) and `expqueue/manage` (pause, resume, cancel, requeue, test job) to the roles that
need them. The Administrator role holds every policy already.

## 7. Check

```bash
./console ext:expqueue:enqueue expqueue.noop
./console ext:expqueue:work --once
./console ext:expqueue:status
```

or Setup > Job queue > "Send a test job".
