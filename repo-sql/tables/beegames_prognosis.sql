CREATE TABLE IF NOT EXISTS public.beegames_prognosis (
    id integer NOT NULL DEFAULT nextval('public.beegames_prognosis_id_seq'::regclass),
    ticket_id integer,
    sport_id integer,
    match_id integer,
    type_id integer,
    content jsonb,
    win boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    match_date timestamp with time zone,
    status prognosis_status,
    joker integer default 1,
    odd_start numeric,
    points integer,
    weight integer,
    perfect boolean default 'false',
    manual boolean default 'false',
	bonuses integer[] default '{}'::integer[],
    CONSTRAINT beegames_prognosis_pkey PRIMARY KEY (id),
    CONSTRAINT beegames_prognosis_ticket_id_fkey FOREIGN KEY (ticket_id) 
            REFERENCES beegames_tickets (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE,
    CONSTRAINT beegames_prognosis_sport_id_fkey FOREIGN KEY (sport_id) 
            REFERENCES sports (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE,
    CONSTRAINT beegames_prognosis_match_id_fkey FOREIGN KEY (match_id) 
            REFERENCES matches (id)     
            ON UPDATE CASCADE 
            ON DELETE CASCADE,
    CONSTRAINT beegames_prognosis_type_id_fkey FOREIGN KEY (type_id) 
            REFERENCES odds_type (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE

);


ALTER TABLE beegames_prognosis
DROP COLUMN IF EXISTS joker;