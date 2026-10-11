-- expqueue (the Exponential job queue): the tables expqueue_job, expqueue_group, expqueue_event, expqueue_resource, expqueue_class, expqueue_mutex, expqueue_worker (sqlite).
-- Generated from expQueueSchema::definition() by bin/php/install-schema.php --write-files with the kernel's
-- schema handler; ./console ext:expqueue:install-schema creates the same tables in a running installation.

CREATE TABLE expqueue_job (
  attempts INTEGER(11) NOT NULL DEFAULT '0',
  cancel_requested INTEGER(11) NOT NULL DEFAULT '0',
  checkpoint longtext,
  class varchar(40) NOT NULL DEFAULT 'bulk',
  cost_actual_micros INTEGER(11) NOT NULL DEFAULT '0',
  cost_estimate_micros INTEGER(11) NOT NULL DEFAULT '0',
  cost_reserved_micros INTEGER(11) NOT NULL DEFAULT '0',
  created INTEGER(11) NOT NULL DEFAULT '0',
  deadline INTEGER(11) NOT NULL DEFAULT '0',
  error_class varchar(60) NOT NULL DEFAULT '',
  external_ref varchar(120) NOT NULL DEFAULT '',
  finished INTEGER(11) NOT NULL DEFAULT '0',
  group_id INTEGER(11) NOT NULL DEFAULT '0',
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  idempotency_key varchar(64) NOT NULL DEFAULT '',
  lane varchar(16) NOT NULL DEFAULT '',
  last_error varchar(255) NOT NULL DEFAULT '',
  lease_owner varchar(80) NOT NULL DEFAULT '',
  lease_until INTEGER(11) NOT NULL DEFAULT '0',
  max_attempts INTEGER(11) NOT NULL DEFAULT '0',
  modified INTEGER(11) NOT NULL DEFAULT '0',
  parent_id INTEGER(11) NOT NULL DEFAULT '0',
  payload longtext,
  priority INTEGER(11) NOT NULL DEFAULT '50',
  progress_done INTEGER(11) NOT NULL DEFAULT '0',
  progress_message varchar(255) NOT NULL DEFAULT '',
  progress_total INTEGER(11) NOT NULL DEFAULT '0',
  ready_since INTEGER(11) NOT NULL DEFAULT '0',
  resource_key varchar(80) NOT NULL DEFAULT '',
  result longtext,
  run_after INTEGER(11) NOT NULL DEFAULT '0',
  site varchar(60) NOT NULL DEFAULT '',
  started INTEGER(11) NOT NULL DEFAULT '0',
  state varchar(16) NOT NULL DEFAULT 'ready',
  timeout INTEGER(11) NOT NULL DEFAULT '0',
  type varchar(60) NOT NULL DEFAULT '',
  user_id INTEGER(11) NOT NULL DEFAULT '0',
  uuid varchar(36) NOT NULL DEFAULT ''
);

CREATE  INDEX expqueue_job_finished ON expqueue_job  ( state, finished );
CREATE  INDEX expqueue_job_group ON expqueue_job  ( group_id, state );
CREATE  INDEX expqueue_job_idem ON expqueue_job  ( type, idempotency_key );
CREATE  INDEX expqueue_job_parent ON expqueue_job  ( parent_id );
CREATE  INDEX expqueue_job_res ON expqueue_job  ( resource_key, state );
CREATE  INDEX expqueue_job_sched ON expqueue_job  ( state, class, run_after );
CREATE  INDEX expqueue_job_user ON expqueue_job  ( user_id, state );
CREATE  UNIQUE INDEX expqueue_job_uuid ON expqueue_job  ( uuid );
CREATE TABLE expqueue_group (
  budget_micros INTEGER(11) NOT NULL DEFAULT '0',
  created INTEGER(11) NOT NULL DEFAULT '0',
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  label varchar(255) NOT NULL DEFAULT '',
  modified INTEGER(11) NOT NULL DEFAULT '0',
  site varchar(60) NOT NULL DEFAULT '',
  spent_micros INTEGER(11) NOT NULL DEFAULT '0',
  state varchar(16) NOT NULL DEFAULT 'active',
  total INTEGER(11) NOT NULL DEFAULT '0',
  type varchar(60) NOT NULL DEFAULT '',
  user_id INTEGER(11) NOT NULL DEFAULT '0',
  uuid varchar(36) NOT NULL DEFAULT ''
);

CREATE  INDEX expqueue_group_state ON expqueue_group  ( state, modified );
CREATE  UNIQUE INDEX expqueue_group_uuid ON expqueue_group  ( uuid );
CREATE TABLE expqueue_event (
  attempt INTEGER(11) NOT NULL DEFAULT '0',
  data longtext,
  group_id INTEGER(11) NOT NULL DEFAULT '0',
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  job_id INTEGER(11) NOT NULL DEFAULT '0',
  kind varchar(16) NOT NULL DEFAULT '',
  message varchar(255) NOT NULL DEFAULT '',
  ts INTEGER(11) NOT NULL DEFAULT '0',
  worker varchar(80) NOT NULL DEFAULT ''
);

CREATE  INDEX expqueue_event_job ON expqueue_event  ( job_id, id );
CREATE  INDEX expqueue_event_kind ON expqueue_event  ( kind, ts );
CREATE TABLE expqueue_resource (
  cooldown_until INTEGER(11) NOT NULL DEFAULT '0',
  last_status varchar(60) NOT NULL DEFAULT '',
  max_concurrent INTEGER(11) NOT NULL DEFAULT '0',
  modified INTEGER(11) NOT NULL DEFAULT '0',
  paused INTEGER(11) NOT NULL DEFAULT '0',
  remaining_requests INTEGER(11) NOT NULL DEFAULT '-1',
  remaining_tokens INTEGER(11) NOT NULL DEFAULT '-1',
  reset_at INTEGER(11) NOT NULL DEFAULT '0',
  resource_key varchar(80) NOT NULL DEFAULT '',
  success_streak INTEGER(11) NOT NULL DEFAULT '0',
  PRIMARY KEY ( resource_key )
);

CREATE TABLE expqueue_class (
  modified INTEGER(11) NOT NULL DEFAULT '0',
  name varchar(40) NOT NULL DEFAULT '',
  paused INTEGER(11) NOT NULL DEFAULT '0',
  stride_pass INTEGER(11) NOT NULL DEFAULT '0',
  PRIMARY KEY ( name )
);

CREATE TABLE expqueue_mutex (
  expires INTEGER(11) NOT NULL DEFAULT '0',
  modified INTEGER(11) NOT NULL DEFAULT '0',
  name varchar(40) NOT NULL DEFAULT '',
  owner varchar(80) NOT NULL DEFAULT '',
  PRIMARY KEY ( name )
);

CREATE TABLE expqueue_worker (
  current_job INTEGER(11) NOT NULL DEFAULT '0',
  filter varchar(255) NOT NULL DEFAULT '',
  heartbeat INTEGER(11) NOT NULL DEFAULT '0',
  host varchar(60) NOT NULL DEFAULT '',
  jobs_done INTEGER(11) NOT NULL DEFAULT '0',
  jobs_failed INTEGER(11) NOT NULL DEFAULT '0',
  modified INTEGER(11) NOT NULL DEFAULT '0',
  origin varchar(16) NOT NULL DEFAULT '',
  os_user varchar(40) NOT NULL DEFAULT '',
  pid INTEGER(11) NOT NULL DEFAULT '0',
  started INTEGER(11) NOT NULL DEFAULT '0',
  state varchar(16) NOT NULL DEFAULT 'running',
  worker_id varchar(80) NOT NULL DEFAULT '',
  PRIMARY KEY ( worker_id )
);

CREATE  INDEX expqueue_worker_beat ON expqueue_worker  ( state, heartbeat );
