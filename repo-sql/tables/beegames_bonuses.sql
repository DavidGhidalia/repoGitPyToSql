CREATE TABLE IF NOT EXISTS beegames_bonuses (
  id serial primary key,
  name varchar(128) not null,
  slug varchar(64) not null,
  logo varchar(256),
  description text,
  weight integer,
  active boolean default false
);