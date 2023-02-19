CREATE TABLE IF NOT EXISTS rooms (
  id serial primary key not null,
  users integer[] default '{}',
  users_in integer[] default '{}',
  users_max integer,
  name varchar(128) not null,
  fee integer not null,
  tokens integer not null,
  prize integer not null,
  private boolean default false,
  active boolean default false,
  deep_link varchar(128),
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);