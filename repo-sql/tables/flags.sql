CREATE TABLE IF NOT EXISTS public.flags (
    comment integer NOT NULL DEFAULT nextval('public.flags_comment_seq'::regclass),
    owner integer NOT NULL DEFAULT nextval('public.flags_owner_seq'::regclass),
    CONSTRAINT flags_pkey PRIMARY KEY (comment, owner),
    CONSTRAINT flags_comment_fkey FOREIGN KEY (comment) 
            REFERENCES comments (id) 
            ON UPDATE CASCADE O
            ON DELETE CASCADE,
    CONSTRAINT flags_owner_fkey FOREIGN KEY (owner) 
            REFERENCES users (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE
);



