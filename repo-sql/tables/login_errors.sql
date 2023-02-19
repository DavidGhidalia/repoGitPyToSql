-- public.login_errors definition

-- Drop table
-- DROP TABLE login_errors;

CREATE TABLE IF NOT EXISTS public.login_errors (
    id integer DEFAULT nextval('public.login_errors_id_seq'::regclass),
    user_id integer NOT NULL,
    username character varying(128),
    firebase_uid character varying(128),
    error character varying(1024),
    provider character varying(128),
    version character varying(10),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT login_errors_pkey PRIMARY KEY (id),
    CONSTRAINT login_errors_user_id_fkey FOREIGN KEY (user_id) 
            REFERENCES users (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE
);


ALTER TABLE login_errors
ALTER  COLUMN IF EXISTS user_id DROP NOT NULL;
