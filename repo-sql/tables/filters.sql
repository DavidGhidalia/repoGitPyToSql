drop  table if exists public.filters;

CREATE TABLE IF NOT EXISTS public.filters (
    id integer NOT NULL DEFAULT nextval('public.filters_id_seq'::regclass),
    key character varying(128) NOT NULL,
    value json,
    title character varying(128),
    active boolean,
    "limit" integer,
    "order" integer,
    CONSTRAINT filters_pkey PRIMARY KEY (id)
);


