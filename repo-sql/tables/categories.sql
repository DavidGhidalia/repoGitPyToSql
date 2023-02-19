CREATE TABLE IF NOT EXISTS public.categories (
    id integer NOT NULL DEFAULT nextval('public.categories_id_seq'::regclass),
    name character varying(128) NOT NULL,
    sports integer[] DEFAULT '{}'::integer[],
    slug character varying(128) NOT NULL,
    name_search tsvector,
    country_code character varying,
    CONSTRAINT categories_pkey PRIMARY KEY (id)
);




