CREATE TABLE IF NOT EXISTS beegames_points (
  type_id integer REFERENCES beegames_types(id) 
          ON UPDATE CASCADE 
          ON DELETE CASCADE,
  match_id integer REFERENCES matches(id) 
          ON UPDATE CASCADE 
          ON DELETE CASCADE,
  market_id integer not null,
  field_id integer not null,
  odds_type_id integer not null,
  points_ winner integer,
  points_perfect integer,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  weight integer,
  CONSTRAINT beegames_points_pkey PRIMARY KEY (type_id, match_id, market_id, field_id, odds_type_id),
  CONSTRAINT beegames_points_odds_type_id_fkey FOREIGN KEY (odds_type_id)
         REFERENCES odds_type (id) 
         ON UPDATE CASCADE 
         ON DELETE CASCADE;
);

