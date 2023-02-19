CREATE TABLE IF NOT EXISTS beegames_weights (
  type_id integer references beegames_types(id) 
       ON UPDATE CASCADE 
       ON DELETE CASCADE,
  tournament_round tournament_round TYPE varchar(64),
  weight_winner integer,
  weight_perfect integer,
  constraint beegames_weights_pkey primary key (type_id, tournament_round)
);

