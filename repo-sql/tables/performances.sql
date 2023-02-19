CREATE TABLE IF NOT EXISTS public.performances (
    id integer NOT NULL DEFAULT nextval('public.performances_id_seq'::regclass),
    user_id integer,
    general_rank integer,
    monthly_rank integer,
    success_rate numeric,
    prognosis_rate numeric,
    average_odds numeric,
    average_odds_won numeric,
    average_stake numeric,
    popularity integer,
    comments integer,
    roi numeric default 0,
    monthly_roi numeric,
    roi_stake numeric,
    monthly_roi_stake numeric,
    roc numeric,
    monthly_roc numeric,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    bet_count integer,
    bet_count_monthly integer,
    bet_count_weekly integer,
    roi_30 numeric,
    roc_30 numeric,
    score_top numeric,
     score_monthly numeric,
     score_j30 numeric,
     roi_coins numeric,
     roi_coins_stake numeric,
     roc_coins numeric,
     roc_coins_stake numeric,
    win_streak integer,
    CONSTRAINT performances_pkey PRIMARY KEY (id),
    CONSTRAINT fk_user_id FOREIGN KEY (user_id) 
            REFERENCES public.users(id),
    CONSTRAINT performances_user_id_key UNIQUE (user_id)
);



-- drop column roi stake
ALTER TABLE performances 
DROP COLUMN IF EXISTS roi_stake CASCADE;

ALTER TABLE performances
DROP COLUMN IF EXISTS monthly_roi_stake CASCADE;

