-- expqueue (the Exponential job queue): the tables expqueue_job, expqueue_group, expqueue_event, expqueue_resource, expqueue_class, expqueue_mutex, expqueue_worker (oracle).
-- Generated from expQueueSchema::definition() by bin/php/install-schema.php --write-files with the kernel's
-- schema handler; ./console ext:expqueue:install-schema creates the same tables in a running installation.

BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE se_expqueue_job';
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE != -955 THEN RAISE; END IF;
END;
/
CREATE TABLE expqueue_job (
  attempts INTEGER DEFAULT 0 NOT NULL,
  cancel_requested INTEGER DEFAULT 0 NOT NULL,
  checkpoint CLOB,
  class VARCHAR2(40) DEFAULT 'bulk',
  cost_actual_micros INTEGER DEFAULT 0 NOT NULL,
  cost_estimate_micros INTEGER DEFAULT 0 NOT NULL,
  cost_reserved_micros INTEGER DEFAULT 0 NOT NULL,
  created INTEGER DEFAULT 0 NOT NULL,
  deadline INTEGER DEFAULT 0 NOT NULL,
  error_class VARCHAR2(60),
  external_ref VARCHAR2(120),
  finished INTEGER DEFAULT 0 NOT NULL,
  group_id INTEGER DEFAULT 0 NOT NULL,
  id INTEGER NOT NULL,
  idempotency_key VARCHAR2(64),
  lane VARCHAR2(16),
  last_error VARCHAR2(255),
  lease_owner VARCHAR2(80),
  lease_until INTEGER DEFAULT 0 NOT NULL,
  max_attempts INTEGER DEFAULT 0 NOT NULL,
  modified INTEGER DEFAULT 0 NOT NULL,
  parent_id INTEGER DEFAULT 0 NOT NULL,
  payload CLOB,
  priority INTEGER DEFAULT 50 NOT NULL,
  progress_done INTEGER DEFAULT 0 NOT NULL,
  progress_message VARCHAR2(255),
  progress_total INTEGER DEFAULT 0 NOT NULL,
  ready_since INTEGER DEFAULT 0 NOT NULL,
  resource_key VARCHAR2(80),
  result CLOB,
  run_after INTEGER DEFAULT 0 NOT NULL,
  site VARCHAR2(60),
  started INTEGER DEFAULT 0 NOT NULL,
  state VARCHAR2(16) DEFAULT 'ready',
  timeout INTEGER DEFAULT 0 NOT NULL,
  type VARCHAR2(60),
  user_id INTEGER DEFAULT 0 NOT NULL,
  uuid VARCHAR2(36),
  PRIMARY KEY ( id )
);

CREATE OR REPLACE TRIGGER expqueue_job_id_tr
BEFORE INSERT ON expqueue_job FOR EACH ROW WHEN (new.id IS NULL)
BEGIN
  SELECT se_expqueue_job.nextval INTO :new.id FROM dual;
END;
/

CREATE INDEX expqueue_job_finished ON expqueue_job ( state, finished );
CREATE INDEX expqueue_job_group ON expqueue_job ( group_id, state );
CREATE INDEX expqueue_job_idem ON expqueue_job ( type, idempotency_key );
CREATE INDEX expqueue_job_parent ON expqueue_job ( parent_id );
CREATE INDEX expqueue_job_res ON expqueue_job ( resource_key, state );
CREATE INDEX expqueue_job_sched ON expqueue_job ( state, class, run_after );
CREATE INDEX expqueue_job_user ON expqueue_job ( user_id, state );
CREATE UNIQUE INDEX expqueue_job_uuid ON expqueue_job ( uuid );
BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE se_expqueue_group';
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE != -955 THEN RAISE; END IF;
END;
/
CREATE TABLE expqueue_group (
  budget_micros INTEGER DEFAULT 0 NOT NULL,
  created INTEGER DEFAULT 0 NOT NULL,
  id INTEGER NOT NULL,
  label VARCHAR2(255),
  modified INTEGER DEFAULT 0 NOT NULL,
  site VARCHAR2(60),
  spent_micros INTEGER DEFAULT 0 NOT NULL,
  state VARCHAR2(16) DEFAULT 'active',
  total INTEGER DEFAULT 0 NOT NULL,
  type VARCHAR2(60),
  user_id INTEGER DEFAULT 0 NOT NULL,
  uuid VARCHAR2(36),
  PRIMARY KEY ( id )
);

CREATE OR REPLACE TRIGGER expqueue_group_id_tr
BEFORE INSERT ON expqueue_group FOR EACH ROW WHEN (new.id IS NULL)
BEGIN
  SELECT se_expqueue_group.nextval INTO :new.id FROM dual;
END;
/

CREATE INDEX expqueue_group_state ON expqueue_group ( state, modified );
CREATE UNIQUE INDEX expqueue_group_uuid ON expqueue_group ( uuid );
BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE se_expqueue_event';
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE != -955 THEN RAISE; END IF;
END;
/
CREATE TABLE expqueue_event (
  attempt INTEGER DEFAULT 0 NOT NULL,
  data CLOB,
  group_id INTEGER DEFAULT 0 NOT NULL,
  id INTEGER NOT NULL,
  job_id INTEGER DEFAULT 0 NOT NULL,
  kind VARCHAR2(16),
  message VARCHAR2(255),
  ts INTEGER DEFAULT 0 NOT NULL,
  worker VARCHAR2(80),
  PRIMARY KEY ( id )
);

CREATE OR REPLACE TRIGGER expqueue_event_id_tr
BEFORE INSERT ON expqueue_event FOR EACH ROW WHEN (new.id IS NULL)
BEGIN
  SELECT se_expqueue_event.nextval INTO :new.id FROM dual;
END;
/

CREATE INDEX expqueue_event_job ON expqueue_event ( job_id, id );
CREATE INDEX expqueue_event_kind ON expqueue_event ( kind, ts );
CREATE TABLE expqueue_resource (
  cooldown_until INTEGER DEFAULT 0 NOT NULL,
  last_status VARCHAR2(60),
  max_concurrent INTEGER DEFAULT 0 NOT NULL,
  modified INTEGER DEFAULT 0 NOT NULL,
  paused INTEGER DEFAULT 0 NOT NULL,
  remaining_requests INTEGER DEFAULT -1 NOT NULL,
  remaining_tokens INTEGER DEFAULT -1 NOT NULL,
  reset_at INTEGER DEFAULT 0 NOT NULL,
  resource_key VARCHAR2(80),
  success_streak INTEGER DEFAULT 0 NOT NULL,
  PRIMARY KEY ( resource_key )
);

CREATE TABLE expqueue_class (
  modified INTEGER DEFAULT 0 NOT NULL,
  name VARCHAR2(40),
  paused INTEGER DEFAULT 0 NOT NULL,
  stride_pass INTEGER DEFAULT 0 NOT NULL,
  PRIMARY KEY ( name )
);

CREATE TABLE expqueue_mutex (
  expires INTEGER DEFAULT 0 NOT NULL,
  modified INTEGER DEFAULT 0 NOT NULL,
  name VARCHAR2(40),
  owner VARCHAR2(80),
  PRIMARY KEY ( name )
);

CREATE TABLE expqueue_worker (
  current_job INTEGER DEFAULT 0 NOT NULL,
  filter VARCHAR2(255),
  heartbeat INTEGER DEFAULT 0 NOT NULL,
  host VARCHAR2(60),
  jobs_done INTEGER DEFAULT 0 NOT NULL,
  jobs_failed INTEGER DEFAULT 0 NOT NULL,
  modified INTEGER DEFAULT 0 NOT NULL,
  origin VARCHAR2(16),
  os_user VARCHAR2(40),
  pid INTEGER DEFAULT 0 NOT NULL,
  started INTEGER DEFAULT 0 NOT NULL,
  state VARCHAR2(16) DEFAULT 'running',
  worker_id VARCHAR2(80),
  PRIMARY KEY ( worker_id )
);

CREATE INDEX expqueue_worker_beat ON expqueue_worker ( state, heartbeat );
