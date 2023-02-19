CREATE TABLE IF NOT EXISTS contest_rewards (
  contest_id integer references contest(id) on update cascade on delete cascade,
  rank bigint not null,
  reward integer,
  beecoins numeric default 0,
  constraint contest_rewards_pkey primary key (contest_id, rank)
);

