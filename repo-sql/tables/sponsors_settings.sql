CREATE TABLE IF NOT EXISTS sponsors_settings (
  id serial primary key not null,
  name varchar(128) not null,
  logo varchar(256),
  active boolean default false,
  toast boolean default false
);