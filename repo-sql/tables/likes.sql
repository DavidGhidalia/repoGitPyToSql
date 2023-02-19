CREATE TABLE IF NOT EXISTS public.likes (
    id integer NOT NULL DEFAULT nextval('public.likes_id_seq'::regclass),
    owner integer NOT NULL DEFAULT nextval('public.likes_owner_seq'::regclass),
    cluster integer NOT NULL  DEFAULT nextval('public.likes_cluster_seq'::regclass),
    created_at timestamp with time zone,
    comment_id integer,
    CONSTRAINT likes_pkey PRIMARY KEY (id),
    CONSTRAINT likes_owner_fkey FOREIGN KEY (owner) 
            REFERENCES users (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE,
    CONSTRAINT likes_cluster_fkey FOREIGN KEY (cluster) 
            REFERENCES clusters (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE,
    CONSTRAINT likes_comment_id_fkey FOREIGN KEY (comment_id) 
            REFERENCES comments (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE
);



