CREATE TABLE IF NOT EXISTS gifts_types (
  id serial primary key not null,
  name varchar(128) not null,
  active boolean default 'false',
  value integer
);

