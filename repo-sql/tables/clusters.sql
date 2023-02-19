CREATE TABLE IF NOT EXISTS public.clusters (
    id integer NOT NULL DEFAULT nextval('public.clusters_id_seq'::regclass),
    owner integer NOT NULL DEFAULT nextval('public.clusters_owner_seq'::regclass),
    text character varying(1024) DEFAULT NULL::character varying,
    private boolean DEFAULT false,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    content json,
    win boolean,
    hash text,
    roi numeric,
    odds_value numeric,
    stake integer,
    content_temp json,
    bookmaker_id integer,
    bookmaker json,
    bookmaker_id integer,
    content_start json,
    best_odd double precision,
    status cluster_status,
    text_search tsvector,
    beecoins_bet numeric,
    beecoins_win numeric,
    beecoins_claimed boolean default 'false',
    beecoins_claimed_at timestamp with time zone,
    transactions integer[] default '{}'::integer[],
    blockers integer[] default '{}'::integer[],
    CONSTRAINT clusters_pkey PRIMARY KEY (id),
    CONSTRAINT clusters_owner_fkey FOREIGN KEY (owner) 
                REFERENCES users (id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE,
    CONSTRAINT clusters_bookmaker_id_fkey FOREIGN KEY (bookmaker_id) 
                REFERENCES bookmakers (id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE
);




-- drop column bookmaker (not used)
ALTER TABLE clusters
DROP COLUMN IF EXISTS bookmaker;

