CREATE TABLE IF NOT EXISTS public.shares (
    cluster integer NOT NULL DEFAULT nextval('public.shares_cluster_seq'::regclass),
    owner integer NOT NULL DEFAULT nextval('public.shares_owner_seq'::regclass),
    CONSTRAINT shares_cluster_fkey FOREIGN KEY (cluster) 
            REFERENCES clusters (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE,
    CONSTRAINT shares_owner_fkey FOREIGN KEY (owner) 
            REFERENCES users (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE
);
