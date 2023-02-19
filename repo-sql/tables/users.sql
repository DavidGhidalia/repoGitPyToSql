CREATE TABLE IF NOT EXISTS public.users (
    id integer NOT NULL DEFAULT nextval('public.users_id_seq'::regclass),
    email character varying(256) NOT NULL,
    nickname character varying(128) NOT NULL,
    firstname character varying(128) DEFAULT NULL::character varying,
    lastname character varying(128) DEFAULT NULL::character varying,
    password character varying(1024) DEFAULT NULL::character varying,
    gender character varying(128) DEFAULT NULL::character varying,
    phone character varying(128) DEFAULT NULL::character varying,
    following integer[] DEFAULT '{}'::integer[],
    followers integer[] DEFAULT '{}'::integer[],
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    logged_at timestamp with time zone,
    token character varying(1024) DEFAULT NULL::character varying,
    avatar character varying(1024) DEFAULT NULL::character varying,
    facebook character varying(128),
    roi numeric DEFAULT 0,
    notifications boolean DEFAULT true,
    country character varying,
    roi_monthly numeric DEFAULT 0,
    subscribers integer[] DEFAULT '{}'::integer[] NOT NULL,
    subscriptions integer[] DEFAULT '{}'::integer[] NOT NULL,
    apple text,
    bet_count integer DEFAULT 0 NOT NULL,
    bet_count_monthly integer DEFAULT 0 NOT NULL,
    tickets_available integer DEFAULT 1 NOT NULL,
    is_email_verified boolean,
    tutorial_intro boolean DEFAULT false NOT NULL,
    tutorial_beegame boolean DEFAULT false NOT NULL,
    indicator_beegame boolean DEFAULT false NOT NULL,
    release_modal boolean DEFAULT true NOT NULL,
    firebase_uid character varying(128),
    admin boolean DEFAULT false,
    tickets_available integer not null default 1,
    firebase_uid varchar(128),
    admin boolean default false,
    cart_date timestamp with time zone,
    beegame_date timestamp with time zone,
    favorite_bookmakers json NULL,
    with_blank boolean default false,
    biography text NULL,
    location text NULL,
    lang lang default 'fr',
    top_player_active boolean default false,
    vip boolean default false,
    verified boolean default false,
    notification_ids integer[],
    birthdate date,
    reset_date timestamp with time zone,
    reset_history varchar[], -- to avoid login errors on timestamp array
    reset_days integer default 60,
    deep_link varchar(128),
    sponsor_link varchar(128),
    sponsor_code char(5) unique,
    sponsor_id integer,
    biography_search tsvector,
    phone_indicator varchar(16),
    phone_session varchar(256),
    phone_verified boolean default false,
    phone_uid varchar(128),
    beecoins numeric not null default 0,
    reward_id integer not null default 1 references rewards(id) on update cascade,
    sponsor_id_old integer,
    transactions integer[] default '{}'::integer[],
    version varchar(16),
    blockers integer[] default '{}'::integer[],
    firebase_provider varchar(128),
    CONSTRAINT tickets_min CHECK ((tickets_available >= 0)),
    CONSTRAINT users_pkey PRIMARY KEY (id),
    CONSTRAINT tickets_min check (tickets_available >= 0),
    CONSTRAINT beecoins_min check (beecoins >= 0),
     CONSTRAINT users_sponsor_id_fkey FOREIGN KEY (sponsor_id)
            REFERENCES users (id)
            ON UPDATE CASCADE 
            ON DELETE CASCADE
);



-- drop column bet_count
ALTER TABLE users
DROP COLUMN IF EXISTS bet_count CASCADE;

-- drop column bet_count_monthly
ALTER TABLE users
DROP COLUMN IF EXISTS bet_count_monthly CASCADE;

--mailjet_prop n'existe pas
--ALTER TABLE users
--DROP COLUMN IF EXISTS mailjet_prop boolean not null default true;