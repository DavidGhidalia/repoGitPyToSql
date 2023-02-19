CREATE TABLE if not exists public.logs (
    id integer NOT NULL DEFAULT nextval('public.logs_id_seq'::regclass),
    query text,
    method character varying(10),
    url character varying(255),
    status_code integer,
    execution_time numeric,
    rows integer,
    call_name character varying(50),
    session_id integer,
    created_at timestamp with time zone,
    CONSTRAINT logs_pkey PRIMARY KEY (id)
);


