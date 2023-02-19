CREATE TABLE IF NOT EXISTS public.events (
    id integer NOT NULL DEFAULT nextval('public.events_id_seq'::regclass),
    slug character varying(128) NOT NULL,
    action character varying(512) NOT NULL,
    active boolean DEFAULT 'false',
    onload boolean DEFAULT 'false',
    start_at timestamp with time zone,
    end_at timestamp with time zone,
    CONSTRAINT events_pkey PRIMARY KEY (id)
);

