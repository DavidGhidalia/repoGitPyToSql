CREATE TABLE IF NOT EXISTS public.sports (
    id integer NOT NULL DEFAULT nextval('public.sports_id_seq'::regclass),
    name character varying(128) NOT NULL,
    slug character varying(128) NOT NULL,
    active boolean DEFAULT false,
    sr_id character varying(32),
    market character varying,
    sportradar boolean,
    label_point character varying,
    ball_icon_url varchar(1024),
    CONSTRAINT sports_pkey PRIMARY KEY (id),
    short_name varchar(16),
    market_id integer,
    emoji text
     );


