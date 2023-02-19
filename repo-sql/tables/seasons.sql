DROP TABLE IF EXISTS seasons;

CREATE TABLE IF NOT EXISTS seasons(
	id integer,
  league integer,
	name varchar(128) not null,
	start_date date,
	end_date date,
	year varchar(16),
	tournament integer,
  standings json,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  primary key (id, league),
  winner_id integer,
  CONSTRAINT seasons_tournament_fkey FOREIGN KEY (tournament) 
        REFERENCES tournaments (id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
  CONSTRAINT seasons_winner_id_fkey FOREIGN KEY (winner_id) 
        REFERENCES teams (id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);

