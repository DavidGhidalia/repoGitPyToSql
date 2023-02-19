CREATE TABLE IF NOT EXISTS beegames_bonuses_sports (
  type_id integer references beegames_types(id) on update cascade on delete cascade,
  sport_id integer references sports(id) on update cascade on delete cascade,
  bonuses integer[] default '{}',
  CONSTRAINT beegames_bonuses_sports_pkey PRIMARY KEY (type_id, sport_id)
);