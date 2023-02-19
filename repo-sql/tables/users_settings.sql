CREATE TABLE  IF NOT EXISTS users_settings (
  type varchar(64) NOT NULL,
  ranking varchar(64) NOT NULL,
  position integer NOT NULL,
  CONSTRAINT users_settings_pkey PRIMARY KEY (type, ranking)
);