CREATE TABLE IF NOT EXISTS public.pending_users (
    id integer NOT NULL DEFAULT nextval('public.pending_users_id_seq'::regclass),
    email character varying(256),
    password character varying(1024),
    nickname character varying(128),
    country character varying(16),
    state character varying(16),
    route character varying(256),
    verified boolean,
    uid character varying(256),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    platforms platform[],
    state_desc varchar(256),
    CONSTRAINT pending_users_email_key UNIQUE (email),
    CONSTRAINT pending_users_nickname_key UNIQUE (nickname),
    CONSTRAINT pending_users_pkey PRIMARY KEY (id)
);

