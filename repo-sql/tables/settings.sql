CREATE TABLE IF NOT EXISTS public.settings (
    id integer NOT NULL DEFAULT nextval('public.settings_id_seq'::regclass),
    name character varying(128) NOT NULL,
    active boolean DEFAULT false,
    url character varying(1024) DEFAULT NULL::character varying,
    info character varying(1024) DEFAULT NULL::character varying,
    date timestamp(0) with time zone,
    number integer,
    CONSTRAINT settings_pk PRIMARY KEY (id)
);

