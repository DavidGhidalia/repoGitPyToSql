CREATE TABLE IF NOT EXISTS public.notifications (
    id integer NOT NULL DEFAULT nextval('public.notifications_id_seq'::regclass),
    users integer[] NOT NULL,
    type integer NOT NULL,
    message character varying(512) DEFAULT NULL::character varying,
    payload character varying(128) DEFAULT NULL::character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    sender integer,
    opened integer[] DEFAULT '{}'::integer[],
    title varchar(64),
    is_push boolean DEFAULT false,
    is_treated boolean DEFAULT false,
    is_displayed boolean DEFAULT false,
    code varchar(16),
    notif_id integer,
    messages_tr jsonb,
    CONSTRAINT notifications_pkey PRIMARY KEY (id),
    CONSTRAINT notifications_notif_id_fkey FOREIGN KEY (notif_id) 
            REFERENCES notifications_settings (id)  
            ON UPDATE CASCADE 
            ON DELETE CASCADE
);


