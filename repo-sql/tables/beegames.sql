CREATE TABLE IF NOT EXISTS public.beegames (
    id integer NOT NULL DEFAULT nextval('public.beegames_id_seq'::regclass),
    name character varying(128),
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    prize integer,
    sponsor character varying(128),
    description character varying(128),
    logo character varying(128),
    winner_id integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    pending_results boolean default 'false',
    notified_users integer[] default '{}',
    tournaments integer[] default '{}',
    type_id integer,
    contest_id integer,
    tutorial_description integer[] default '{}',
    tutorial_results integer[] default '{}',
     room_id integer,
     match_id integer,
     beecoins_fee numeric default 0,
     beecoins_prize numeric default 0,
     sport_id integer,
     round integer,
     tournament_round varchar(64),
     background_url varchar(256),
     transactions integer[] default '{}'::integer[],
    users integer[] DEFAULT '{}'::integer[],
     tournament_name varchar(128),
     owner integer,
     subtitle varchar(128),
     code char(5) unique,
     private boolean default 'false',
     priority integer,
     deep_link varchar(128),
     background_url_top varchar(256),
     bonuses integer[] default '{}'::integer[],
     matches integer[] default '{}'::integer[],
     mix boolean default 'false',
     major boolean default 'false',
     top boolean default 'false',
     status beegame_status,
     visible boolean default true,
     CONSTRAINT beegames_pkey PRIMARY KEY (id),
     CONSTRAINT beegames_winner_id_fkey FOREIGN KEY (winner_id)
                 REFERENCES users (id) 
                 ON UPDATE CASCADE,
     CONSTRAINT beegames_type_id_fkey FOREIGN KEY (type_id) 
                 REFERENCES beegames_types (id) 
                 ON UPDATE CASCADE 
                 ON DELETE CASCADE,
     CONSTRAINT beegames_contest_id_fkey FOREIGN KEY (contest_id) 
                 REFERENCES contest (id) 
                 ON UPDATE CASCADE 
                 ON DELETE CASCADE,
     CONSTRAINT beegames_room_id_fkey FOREIGN KEY (room_id) 
                 REFERENCES rooms (id) 
                 ON UPDATE CASCADE 
                 ON DELETE CASCADE,
     CONSTRAINT beegames_match_id_fkey FOREIGN KEY (match_id) 
                 REFERENCES matches (id) 
                 ON UPDATE CASCADE 
                 ON DELETE CASCADE,
     CONSTRAINT beegames_sport_id_fkey FOREIGN KEY (sport_id) 
                 REFERENCES sports (id) 
                 ON UPDATE CASCADE 
                 ON DELETE CASCADE,
     CONSTRAINT beegames_owner_fkey FOREIGN KEY (owner)
                 REFERENCES users (id) 
                 ON UPDATE CASCADE 
                 ON DELETE CASCADE,
     CONSTRAINT beegames_parent_id_fkey FOREIGN KEY (parent_id) 
                 REFERENCES beegames (id) 
                 ON UPDATE CASCADE 
                 ON DELETE CASCADE
);



-- a voir plus tard
--SELECT SETVAL(pg_get_serial_sequence('beegames', 'id'), (SELECT MAX(id) FROM beegames));

ALTER TABLE beegames
DROP  CONSTRAINT IF EXISTS beegames_winner_id_fkey;
