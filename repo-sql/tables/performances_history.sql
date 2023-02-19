CREATE TABLE IF NOT EXISTS public.performances_history (
    id integer NOT NULL  DEFAULT nextval('public.performances_history_id_seq'::regclass),
    user_id integer NOT NULL,
    general_rank integer,
    monthly_rank integer,
    success_rate numeric,
    prognosis_rate numeric,
    average_odds numeric,
    average_odds_won numeric,
    average_stake numeric,
    popularity integer,
    comments integer,
    roi numeric,
    monthly_roi numeric,
    roi_stake numeric,
    monthly_roi_stake numeric,
    roc numeric,
    monthly_roc numeric,
    month integer NOT NULL,
    year integer NOT NULL,
    bet_count integer,
    bet_count_monthly integer,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
     j30_rank integer,
     score_top numeric,
     score_monthly numeric,
     score_j30 numeric,
     roi_coins numeric,
     roi_coins_stake numeric,
     roc_coins numeric,
     roc_coins_stake numeric,
    CONSTRAINT performances_history_pkey PRIMARY KEY (id),
    CONSTRAINT user_history_monthly UNIQUE (user_id, month, year),
    CONSTRAINT performances_history_user_id_fkey FOREIGN KEY (user_id) 
            REFERENCES users (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE
);




-- drop column roi stake
ALTER TABLE performances_history 
DROP COLUMN IF EXISTS roi_stake CASCADE;

ALTER TABLE performances_history 
DROP COLUMN IF EXISTS monthly_roi_stake CASCADE;

