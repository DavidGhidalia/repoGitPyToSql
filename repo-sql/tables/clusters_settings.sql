CREATE TABLE IF NOT EXISTS clusters_settings (
	name character varying(64) primary key not null,
	value integer,
  active boolean default false
);