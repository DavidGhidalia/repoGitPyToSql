CREATE TABLE IF NOT EXISTS public.tokens (
    id integer NOT NULL DEFAULT nextval('public.tokens_id_seq'::regclass),
    owner integer,
    token character varying(2048) DEFAULT NULL::character varying,
    type public.tokentype,
    created_at timestamp without time zone DEFAULT now(),
    CONSTRAINT tokens_pkey PRIMARY KEY (id),
    CONSTRAINT tokens_owner_fkey FOREIGN KEY (owner) 
            REFERENCES users (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE
);
