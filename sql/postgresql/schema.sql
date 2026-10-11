-- expqueue (the Exponential job queue): the tables expqueue_job, expqueue_group, expqueue_event, expqueue_resource, expqueue_class, expqueue_mutex, expqueue_worker (postgresql).
-- Generated from expQueueSchema::definition() by bin/php/install-schema.php --write-files with the kernel's
-- schema handler; ./console ext:expqueue:install-schema creates the same tables in a running installation.

CREATE SEQUENCE IF NOT EXISTS expqueue_job_id_seq
  START 1
  INCREMENT 1
  MAXVALUE 9223372036854775807
  MINVALUE 1
  CACHE 1;
CREATE TABLE IF NOT EXISTS expqueue_job (
  attempts integer DEFAULT 0 NOT NULL,
  cancel_requested integer DEFAULT 0 NOT NULL,
  "checkpoint" text,
  "class" character varying(40) DEFAULT 'bulk'::character varying NOT NULL,
  cost_actual_micros integer DEFAULT 0 NOT NULL,
  cost_estimate_micros integer DEFAULT 0 NOT NULL,
  cost_reserved_micros integer DEFAULT 0 NOT NULL,
  created integer DEFAULT 0 NOT NULL,
  deadline integer DEFAULT 0 NOT NULL,
  error_class character varying(60) DEFAULT ''::character varying NOT NULL,
  external_ref character varying(120) DEFAULT ''::character varying NOT NULL,
  finished integer DEFAULT 0 NOT NULL,
  group_id integer DEFAULT 0 NOT NULL,
  id integer DEFAULT nextval('expqueue_job_id_seq'::text) NOT NULL,
  idempotency_key character varying(64) DEFAULT ''::character varying NOT NULL,
  lane character varying(16) DEFAULT ''::character varying NOT NULL,
  last_error character varying(255) DEFAULT ''::character varying NOT NULL,
  lease_owner character varying(80) DEFAULT ''::character varying NOT NULL,
  lease_until integer DEFAULT 0 NOT NULL,
  max_attempts integer DEFAULT 0 NOT NULL,
  modified integer DEFAULT 0 NOT NULL,
  parent_id integer DEFAULT 0 NOT NULL,
  payload text,
  priority integer DEFAULT 50 NOT NULL,
  progress_done integer DEFAULT 0 NOT NULL,
  progress_message character varying(255) DEFAULT ''::character varying NOT NULL,
  progress_total integer DEFAULT 0 NOT NULL,
  ready_since integer DEFAULT 0 NOT NULL,
  resource_key character varying(80) DEFAULT ''::character varying NOT NULL,
  result text,
  run_after integer DEFAULT 0 NOT NULL,
  site character varying(60) DEFAULT ''::character varying NOT NULL,
  started integer DEFAULT 0 NOT NULL,
  state character varying(16) DEFAULT 'ready'::character varying NOT NULL,
  timeout integer DEFAULT 0 NOT NULL,
  "type" character varying(60) DEFAULT ''::character varying NOT NULL,
  user_id integer DEFAULT 0 NOT NULL,
  uuid character varying(36) DEFAULT ''::character varying NOT NULL
);

CREATE UNIQUE INDEX expqueue_job_uuid ON expqueue_job USING btree ( uuid );
CREATE INDEX expqueue_job_sched ON expqueue_job USING btree ( state, "class", run_after );
CREATE INDEX expqueue_job_group ON expqueue_job USING btree ( group_id, state );
CREATE INDEX expqueue_job_res ON expqueue_job USING btree ( resource_key, state );
CREATE INDEX expqueue_job_user ON expqueue_job USING btree ( user_id, state );
CREATE INDEX expqueue_job_idem ON expqueue_job USING btree ( "type", idempotency_key );
CREATE INDEX expqueue_job_parent ON expqueue_job USING btree ( parent_id );
CREATE INDEX expqueue_job_finished ON expqueue_job USING btree ( state, finished );
ALTER TABLE ONLY expqueue_job ADD CONSTRAINT expqueue_job_pkey PRIMARY KEY ( id );
CREATE SEQUENCE IF NOT EXISTS expqueue_group_id_seq
  START 1
  INCREMENT 1
  MAXVALUE 9223372036854775807
  MINVALUE 1
  CACHE 1;
CREATE TABLE IF NOT EXISTS expqueue_group (
  budget_micros integer DEFAULT 0 NOT NULL,
  created integer DEFAULT 0 NOT NULL,
  id integer DEFAULT nextval('expqueue_group_id_seq'::text) NOT NULL,
  label character varying(255) DEFAULT ''::character varying NOT NULL,
  modified integer DEFAULT 0 NOT NULL,
  site character varying(60) DEFAULT ''::character varying NOT NULL,
  spent_micros integer DEFAULT 0 NOT NULL,
  state character varying(16) DEFAULT 'active'::character varying NOT NULL,
  total integer DEFAULT 0 NOT NULL,
  "type" character varying(60) DEFAULT ''::character varying NOT NULL,
  user_id integer DEFAULT 0 NOT NULL,
  uuid character varying(36) DEFAULT ''::character varying NOT NULL
);

CREATE UNIQUE INDEX expqueue_group_uuid ON expqueue_group USING btree ( uuid );
CREATE INDEX expqueue_group_state ON expqueue_group USING btree ( state, modified );
ALTER TABLE ONLY expqueue_group ADD CONSTRAINT expqueue_group_pkey PRIMARY KEY ( id );
CREATE SEQUENCE IF NOT EXISTS expqueue_event_id_seq
  START 1
  INCREMENT 1
  MAXVALUE 9223372036854775807
  MINVALUE 1
  CACHE 1;
CREATE TABLE IF NOT EXISTS expqueue_event (
  attempt integer DEFAULT 0 NOT NULL,
  data text,
  group_id integer DEFAULT 0 NOT NULL,
  id integer DEFAULT nextval('expqueue_event_id_seq'::text) NOT NULL,
  job_id integer DEFAULT 0 NOT NULL,
  kind character varying(16) DEFAULT ''::character varying NOT NULL,
  message character varying(255) DEFAULT ''::character varying NOT NULL,
  ts integer DEFAULT 0 NOT NULL,
  worker character varying(80) DEFAULT ''::character varying NOT NULL
);

CREATE INDEX expqueue_event_job ON expqueue_event USING btree ( job_id, id );
CREATE INDEX expqueue_event_kind ON expqueue_event USING btree ( kind, ts );
ALTER TABLE ONLY expqueue_event ADD CONSTRAINT expqueue_event_pkey PRIMARY KEY ( id );
CREATE TABLE IF NOT EXISTS expqueue_resource (
  cooldown_until integer DEFAULT 0 NOT NULL,
  last_status character varying(60) DEFAULT ''::character varying NOT NULL,
  max_concurrent integer DEFAULT 0 NOT NULL,
  modified integer DEFAULT 0 NOT NULL,
  paused integer DEFAULT 0 NOT NULL,
  remaining_requests integer DEFAULT -1 NOT NULL,
  remaining_tokens integer DEFAULT -1 NOT NULL,
  reset_at integer DEFAULT 0 NOT NULL,
  resource_key character varying(80) DEFAULT ''::character varying NOT NULL,
  success_streak integer DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY expqueue_resource ADD CONSTRAINT expqueue_resource_pkey PRIMARY KEY ( resource_key );
CREATE TABLE IF NOT EXISTS expqueue_class (
  modified integer DEFAULT 0 NOT NULL,
  name character varying(40) DEFAULT ''::character varying NOT NULL,
  paused integer DEFAULT 0 NOT NULL,
  stride_pass integer DEFAULT 0 NOT NULL
);

ALTER TABLE ONLY expqueue_class ADD CONSTRAINT expqueue_class_pkey PRIMARY KEY ( name );
CREATE TABLE IF NOT EXISTS expqueue_mutex (
  expires integer DEFAULT 0 NOT NULL,
  modified integer DEFAULT 0 NOT NULL,
  name character varying(40) DEFAULT ''::character varying NOT NULL,
  "owner" character varying(80) DEFAULT ''::character varying NOT NULL
);

ALTER TABLE ONLY expqueue_mutex ADD CONSTRAINT expqueue_mutex_pkey PRIMARY KEY ( name );
CREATE TABLE IF NOT EXISTS expqueue_worker (
  current_job integer DEFAULT 0 NOT NULL,
  filter character varying(255) DEFAULT ''::character varying NOT NULL,
  heartbeat integer DEFAULT 0 NOT NULL,
  host character varying(60) DEFAULT ''::character varying NOT NULL,
  jobs_done integer DEFAULT 0 NOT NULL,
  jobs_failed integer DEFAULT 0 NOT NULL,
  modified integer DEFAULT 0 NOT NULL,
  origin character varying(16) DEFAULT ''::character varying NOT NULL,
  os_user character varying(40) DEFAULT ''::character varying NOT NULL,
  pid integer DEFAULT 0 NOT NULL,
  started integer DEFAULT 0 NOT NULL,
  state character varying(16) DEFAULT 'running'::character varying NOT NULL,
  worker_id character varying(80) DEFAULT ''::character varying NOT NULL
);

CREATE INDEX expqueue_worker_beat ON expqueue_worker USING btree ( state, heartbeat );
ALTER TABLE ONLY expqueue_worker ADD CONSTRAINT expqueue_worker_pkey PRIMARY KEY ( worker_id );
