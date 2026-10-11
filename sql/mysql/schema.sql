-- expqueue (the Exponential job queue): the tables expqueue_job, expqueue_group, expqueue_event, expqueue_resource, expqueue_class, expqueue_mutex, expqueue_worker (mysql).
-- Generated from expQueueSchema::definition() by bin/php/install-schema.php --write-files with the kernel's
-- schema handler; ./console ext:expqueue:install-schema creates the same tables in a running installation.

CREATE TABLE expqueue_job (
  attempts int(11) NOT NULL DEFAULT '0',
  cancel_requested int(11) NOT NULL DEFAULT '0',
  checkpoint longtext,
  class varchar(40) NOT NULL DEFAULT 'bulk',
  cost_actual_micros int(11) NOT NULL DEFAULT '0',
  cost_estimate_micros int(11) NOT NULL DEFAULT '0',
  cost_reserved_micros int(11) NOT NULL DEFAULT '0',
  created int(11) NOT NULL DEFAULT '0',
  deadline int(11) NOT NULL DEFAULT '0',
  error_class varchar(60) NOT NULL DEFAULT '',
  external_ref varchar(120) NOT NULL DEFAULT '',
  finished int(11) NOT NULL DEFAULT '0',
  group_id int(11) NOT NULL DEFAULT '0',
  id int(11) NOT NULL AUTO_INCREMENT,
  idempotency_key varchar(64) NOT NULL DEFAULT '',
  lane varchar(16) NOT NULL DEFAULT '',
  last_error varchar(255) NOT NULL DEFAULT '',
  lease_owner varchar(80) NOT NULL DEFAULT '',
  lease_until int(11) NOT NULL DEFAULT '0',
  max_attempts int(11) NOT NULL DEFAULT '0',
  modified int(11) NOT NULL DEFAULT '0',
  parent_id int(11) NOT NULL DEFAULT '0',
  payload longtext,
  priority int(11) NOT NULL DEFAULT '50',
  progress_done int(11) NOT NULL DEFAULT '0',
  progress_message varchar(255) NOT NULL DEFAULT '',
  progress_total int(11) NOT NULL DEFAULT '0',
  ready_since int(11) NOT NULL DEFAULT '0',
  resource_key varchar(80) NOT NULL DEFAULT '',
  result longtext,
  run_after int(11) NOT NULL DEFAULT '0',
  site varchar(60) NOT NULL DEFAULT '',
  started int(11) NOT NULL DEFAULT '0',
  state varchar(16) NOT NULL DEFAULT 'ready',
  timeout int(11) NOT NULL DEFAULT '0',
  type varchar(60) NOT NULL DEFAULT '',
  user_id int(11) NOT NULL DEFAULT '0',
  uuid varchar(36) NOT NULL DEFAULT '',
  PRIMARY KEY ( id ),
  UNIQUE KEY expqueue_job_uuid ( uuid ),
  KEY expqueue_job_sched ( state, class, run_after ),
  KEY expqueue_job_group ( group_id, state ),
  KEY expqueue_job_res ( resource_key, state ),
  KEY expqueue_job_user ( user_id, state ),
  KEY expqueue_job_idem ( type, idempotency_key ),
  KEY expqueue_job_parent ( parent_id ),
  KEY expqueue_job_finished ( state, finished )
) ENGINE=InnoDB;

CREATE TABLE expqueue_group (
  budget_micros int(11) NOT NULL DEFAULT '0',
  created int(11) NOT NULL DEFAULT '0',
  id int(11) NOT NULL AUTO_INCREMENT,
  label varchar(255) NOT NULL DEFAULT '',
  modified int(11) NOT NULL DEFAULT '0',
  site varchar(60) NOT NULL DEFAULT '',
  spent_micros int(11) NOT NULL DEFAULT '0',
  state varchar(16) NOT NULL DEFAULT 'active',
  total int(11) NOT NULL DEFAULT '0',
  type varchar(60) NOT NULL DEFAULT '',
  user_id int(11) NOT NULL DEFAULT '0',
  uuid varchar(36) NOT NULL DEFAULT '',
  PRIMARY KEY ( id ),
  UNIQUE KEY expqueue_group_uuid ( uuid ),
  KEY expqueue_group_state ( state, modified )
) ENGINE=InnoDB;

CREATE TABLE expqueue_event (
  attempt int(11) NOT NULL DEFAULT '0',
  data longtext,
  group_id int(11) NOT NULL DEFAULT '0',
  id int(11) NOT NULL AUTO_INCREMENT,
  job_id int(11) NOT NULL DEFAULT '0',
  kind varchar(16) NOT NULL DEFAULT '',
  message varchar(255) NOT NULL DEFAULT '',
  ts int(11) NOT NULL DEFAULT '0',
  worker varchar(80) NOT NULL DEFAULT '',
  PRIMARY KEY ( id ),
  KEY expqueue_event_job ( job_id, id ),
  KEY expqueue_event_kind ( kind, ts )
) ENGINE=InnoDB;

CREATE TABLE expqueue_resource (
  cooldown_until int(11) NOT NULL DEFAULT '0',
  last_status varchar(60) NOT NULL DEFAULT '',
  max_concurrent int(11) NOT NULL DEFAULT '0',
  modified int(11) NOT NULL DEFAULT '0',
  paused int(11) NOT NULL DEFAULT '0',
  remaining_requests int(11) NOT NULL DEFAULT '-1',
  remaining_tokens int(11) NOT NULL DEFAULT '-1',
  reset_at int(11) NOT NULL DEFAULT '0',
  resource_key varchar(80) NOT NULL DEFAULT '',
  success_streak int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY ( resource_key )
) ENGINE=InnoDB;

CREATE TABLE expqueue_class (
  modified int(11) NOT NULL DEFAULT '0',
  name varchar(40) NOT NULL DEFAULT '',
  paused int(11) NOT NULL DEFAULT '0',
  stride_pass int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY ( name )
) ENGINE=InnoDB;

CREATE TABLE expqueue_mutex (
  expires int(11) NOT NULL DEFAULT '0',
  modified int(11) NOT NULL DEFAULT '0',
  name varchar(40) NOT NULL DEFAULT '',
  owner varchar(80) NOT NULL DEFAULT '',
  PRIMARY KEY ( name )
) ENGINE=InnoDB;

CREATE TABLE expqueue_worker (
  current_job int(11) NOT NULL DEFAULT '0',
  filter varchar(255) NOT NULL DEFAULT '',
  heartbeat int(11) NOT NULL DEFAULT '0',
  host varchar(60) NOT NULL DEFAULT '',
  jobs_done int(11) NOT NULL DEFAULT '0',
  jobs_failed int(11) NOT NULL DEFAULT '0',
  modified int(11) NOT NULL DEFAULT '0',
  origin varchar(16) NOT NULL DEFAULT '',
  os_user varchar(40) NOT NULL DEFAULT '',
  pid int(11) NOT NULL DEFAULT '0',
  started int(11) NOT NULL DEFAULT '0',
  state varchar(16) NOT NULL DEFAULT 'running',
  worker_id varchar(80) NOT NULL DEFAULT '',
  PRIMARY KEY ( worker_id ),
  KEY expqueue_worker_beat ( state, heartbeat )
) ENGINE=InnoDB;

