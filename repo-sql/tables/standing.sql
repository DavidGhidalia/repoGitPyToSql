CREATE TABLE IF NOT EXISTS standings (
	type character varying(64) primary key not null,
  name character varying(64),
	active boolean default false
);