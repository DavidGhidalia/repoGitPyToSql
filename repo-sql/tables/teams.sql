CREATE TABLE IF NOT EXISTS public.teams (
    id integer NOT NULL DEFAULT nextval('public.teams_id_seq'::regclass),
    gender character varying(3) DEFAULT NULL::character varying,
    name character varying(512) NOT NULL,
    sport integer,
    country character varying(10) DEFAULT NULL::character varying,
    tournaments integer[] DEFAULT '{}'::integer[],
    slug character varying(512) NOT NULL,
    ranking integer,
    base_url_big character varying(512),
    base_url_medium character varying(512),
    name_search tsvector,
    rankings jsonb,
    CONSTRAINT teams_pkey PRIMARY KEY (id),
    CONSTRAINT teams_sport_fkey FOREIGN KEY (sport) 
            REFERENCES sports (id) 
            ON UPDATE CASCADE
);
