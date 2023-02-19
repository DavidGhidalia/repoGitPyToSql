CREATE TABLE IF NOT EXISTS rewards (
  id serial primary key,
  next_id integer not null references rewards(id) on update cascade on delete cascade,
  beecoins_min numeric not null,
  beecoins_max numeric not null,
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);