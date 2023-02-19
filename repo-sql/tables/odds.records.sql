CREATE TABLE IF NOT EXISTS odds_records (
  id serial primary key not null,
  record json default '{}',
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);