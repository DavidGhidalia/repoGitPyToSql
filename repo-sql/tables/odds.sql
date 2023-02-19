CREATE TABLE IF NOT EXISTS  public.odds (
    match integer NOT NULL,
    bookmaker integer NOT NULL,
    details jsonb NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    odds_type_ids integer[],
    odds_type_ids integer[] not null,
    id_best_odds integer,
    position integer,
    validated integer[],
    disabled boolean default false,
    displayed boolean default true,
    details_live jsonb default '{}',
    CONSTRAINT odds_match_fkey FOREIGN KEY (match)
             REFERENCES matches (id) 
             ON UPDATE CASCADE 
             ON DELETE CASCADE,
    CONSTRAINT odds_bookmaker_fkey FOREIGN KEY (bookmaker) 
             REFERENCES bookmakers (id) 
             ON UPDATE CASCADE 
             ON DELETE CASCADE
);



