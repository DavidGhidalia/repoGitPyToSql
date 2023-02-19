CREATE TABLE IF NOT EXISTS public.matches (
    id integer NOT NULL DEFAULT nextval('public.matches_id_seq'::regclass),
    date timestamp with time zone,
    round integer,
    teams integer[] DEFAULT '{}'::integer[],
    result jsonb,
    sport integer,
    category integer,
    tournament integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    home_team integer,
    lineups json,
    status match_status,
    season integer,
    match_status match_match_status,
    leagues integer[],
    notified_users integer[] default '{}',
    result_live jsonb,
    winner_id integer,
    tournament_round tournament_round varchar(64),
    channel jsonb,
    CONSTRAINT matches_pkey PRIMARY KEY (id),
    CONSTRAINT matches_sport_fkey FOREIGN KEY (sport) 
            REFERENCES sports (id) 
            ON UPDATE CASCADE,
    CONSTRAINT matches_category_fkey FOREIGN KEY (category) 
            REFERENCES categories (id) 
            ON UPDATE CASCADE,
    CONSTRAINT matches_tournament_fkey FOREIGN KEY (tournament) 
            REFERENCES tournaments (id) 
            ON UPDATE CASCADE,
    CONSTRAINT matches_home_team_fkey FOREIGN KEY (home_team) 
            REFERENCES teams (id) 
            ON UPDATE CASCADE,
    CONSTRAINT matches_winner_id_fkey FOREIGN KEY (winner_id) 
            REFERENCES teams (id) 
            ON UPDATE CASCADE
    );






