CREATE TABLE IF NOT EXISTS beecoins_settings (
  id serial primary key not null,
  name varchar(64) not null,
  options jsonb default '{}',
  value numeric,
  active boolean default false
);