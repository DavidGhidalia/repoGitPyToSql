CREATE TABLE IF NOT EXISTS explores (
  id serial primary key not null,
  name varchar(64) not null,
  "limit" integer not null,
  active boolean default 'false'
);

