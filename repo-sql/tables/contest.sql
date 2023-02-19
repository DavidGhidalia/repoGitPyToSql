-- public.contest definition

-- Drop table

-- DROP TABLE contest;

CREATE TABLE IF NOT EXISTS public.contest (
    id integer NOT NULL,
    bookmaker_id integer,
    active boolean DEFAULT false,
    "name" character varying(128),
    description character varying(1024),
    "period" character varying(128),
    price character varying(128),
    conditions character varying(1024),
    "url" character varying(1024),
    url_label character varying(128),
    footnote character varying(1024),
    color character varying(128) DEFAULT '#BB993E',
    start_message character varying(128) DEFAULT 'Sauras-tu te hisser dans le classement ?',
    end_message character varying(128) DEFAULT 'Concours Terminé !',
    created_at timestamp with time zone DEFAULT now(),
    results jsonb,
    infos varchar(256),
    rewards varchar[],
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    min_betcount integer NULL DEFAULT 10,
    pending_message varchar(256),
    updated_at timestamp with time zone,
    notified_users integer[] default '{}',
    CONSTRAINT contest_pk PRIMARY KEY (id),
    CONSTRAINT contest_bookmaker_id_fkey FOREIGN KEY (bookmaker_id) 
                REFERENCES bookmakers (id) 
                ON UPDATE CASCADE
);


-- remove unused column rewards
ALTER TABLE contest
DROP COLUMN IF EXISTS rewards cascade;

