CREATE TABLE IF NOT EXISTS public.markets (
    id integer NOT NULL DEFAULT nextval('public.markets_id_seq'::regclass),
    market_id integer,
    group_name character varying(20),
    name character varying(20),
    label character varying(256),
    priority integer,
    visible boolean,
    sport integer,
    description jsonb,
    "limit" integer,
    sorted boolean,
    columns integer,
    with_label_point boolean,
    fixed boolean,
    sr_name varchar(16),
    CONSTRAINT markets_pkey PRIMARY KEY (id),
    CONSTRAINT markets_sport_fkey FOREIGN KEY (sport) 
            REFERENCES sports (id) 
            ON UPDATE CASCADE

);





