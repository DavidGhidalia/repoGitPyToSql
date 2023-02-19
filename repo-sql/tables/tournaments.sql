CREATE TABLE IF NOT EXISTS public.tournaments (
    id integer NOT NULL DEFAULT nextval('public.tournaments_id_seq'::regclass),
    unique_id integer NOT NULL DEFAULT nextval('public.tournaments_unique_id_seq'::regclass),
    name character varying(128) NOT NULL,
    level varchar(16),
    sport integer,
    category integer,
    slug character varying(128) NOT NULL,
    major boolean,
    "order" integer,
    ground_type character varying(32),
    info character varying(128),
    name_search tsvector,
    CONSTRAINT tournaments_pkey PRIMARY KEY (id),
    CONSTRAINT tournaments_sport_fkey FOREIGN KEY (sport) 
            REFERENCES sports (id) 
            ON UPDATE CASCADE,
    CONSTRAINT tournaments_category_fkey FOREIGN KEY (category) 
            REFERENCES categories (id) 
            ON UPDATE CASCADE
);
