CREATE TABLE IF NOT EXISTS sponsors (
  id serial primary key not null,
  level integer not null,
  unlocked_at integer not null,
  beecoins_win numeric not null,
  transactions integer[] default '{}'::integer[],
  active boolean default false,
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);