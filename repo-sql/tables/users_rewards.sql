CREATE TABLE IF NOT EXISTS users_rewards (
  id serial primary key,
  user_id integer not null references users(id) on update cascade on delete cascade,
  reward_id integer not null references rewards(id) on update cascade on delete cascade,
  date date not null,
  beecoins_win numeric not null,
  beecoins_claimed boolean default false,
  beecoins_claimed_at timestamp with time zone, 
  transactions integer[] default '{}'::integer[],
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  unique (user_id, date)
);