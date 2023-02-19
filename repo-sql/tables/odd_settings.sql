CREATE TABLE IF NOT EXISTS odds_settings (
  name varchar(64) PRIMARY KEY NOT NULL,
  active boolean default false
);