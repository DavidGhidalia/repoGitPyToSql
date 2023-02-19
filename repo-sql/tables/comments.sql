CREATE TABLE IF NOT EXISTS public.comments (
    id integer NOT NULL DEFAULT nextval('public.comments_id_seq'::regclass),
    owner integer NOT NULL  DEFAULT nextval('public.comments_owner_seq'::regclass),
    cluster integer NOT NULL DEFAULT nextval('public.comments_cluster_seq'::regclass),
    text character varying(1024) DEFAULT NULL::character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    visible boolean default 'true',
    parent_id integer,
    text_search tsvector,
    blockers integer[] default '{}'::integer[],
    CONSTRAINT comments_pkey PRIMARY KEY (id),
    CONSTRAINT comments_owner_fkey FOREIGN KEY (owner) 
                REFERENCES users (id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE,
    CONSTRAINT comments_cluster_fkey FOREIGN KEY (cluster) 
                REFERENCES clusters (id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE,
    CONSTRAINT comments_parent_id_fkey FOREIGN KEY (parent_id) 
                REFERENCES comments (id) 
                ON UPDATE CASCADE 
                ON DELETE CASCADE
);







