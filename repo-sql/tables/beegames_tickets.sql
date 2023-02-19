CREATE TABLE IF NOT EXISTS public.beegames_tickets (
    id integer NOT NULL DEFAULT nextval('public.beegames_tickets_id_seq'::regclass),
    beegame_id integer,
    user_id integer,
    bookmaker_id integer,
    odds_value numeric,
    win boolean,
    win_beegame boolean,
    hash text,
    num_ticket bigint,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    status cluster_status,
    odds_value_start numeric,
    beecoins_bet numeric,
    transactions integer[] default '{}'::integer[],
    bookmaker_id_old integer,
    CONSTRAINT beegames_tickets_num_ticket_key UNIQUE (num_ticket),
    CONSTRAINT beegames_tickets_beegame_id_fkey FOREIGN KEY (beegame_id) 
            REFERENCES beegames (id) 
            ON UPDATE CASCADE
            ON DELETE CASCADE,
    CONSTRAINT beegames_tickets_user_id_fkey FOREIGN KEY (user_id) 
            REFERENCES users (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE,
CONSTRAINT beegames_tickets_bookmaker_id_fkey FOREIGN KEY (bookmaker_id) 
            REFERENCES bookmakers (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE
);

