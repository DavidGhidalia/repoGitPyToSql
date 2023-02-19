CREATE TABLE IF NOT EXISTS public.bookmakers (
    id integer NOT NULL DEFAULT nextval('public.bookmakers_id_seq'::regclass),
    name character varying(128) NOT NULL,
    slug character varying(256) DEFAULT NULL::character varying,
    url character varying(1024) DEFAULT NULL::character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    country character varying,
    top integer,
    bonus integer,
    currency character varying(3) DEFAULT NULL::character varying,
    interest integer,
    odds_interest integer,
    infos character varying(1024) DEFAULT NULL::character varying,
    active boolean DEFAULT 'false',
    parent_id integer, 
    comparator boolean default 'false',
    beegame boolean default 'false',
    CONSTRAINT bookmakers_pkey PRIMARY KEY (id),
    CONSTRAINT bookmakers_parent_id_fkey FOREIGN KEY (parent_id) 
                REFERENCES bookmakers (id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE;
);



