CREATE TABLE IF NOT EXISTS public.prognosis (
    id integer NOT NULL DEFAULT nextval('public.prognosis_id_seq'::regclass),
    sport integer NOT NULL DEFAULT  nextval('public.prognosis_sport_seq'::regclass),
    content jsonb,
    match integer NOT NULL DEFAULT nextval('public.prognosis_match_seq'::regclass),
    cluster integer NOT NULL DEFAULT nextval('public.prognosis_cluster_seq'::regclass),
    win boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    type_id integer,
    match_date timestamp with time zone,
    status prognosis_status,
    odd_start numeric,
    type_id integer,
    top_player boolean default false,
    manual boolean default false,
    CONSTRAINT prognosis_pkey PRIMARY KEY (id),
    CONSTRAINT prognosis_sport_fkey FOREIGN KEY (sport) 
            REFERENCES sports (id) 
            ON UPDATE CASCADE,
    CONSTRAINT prognosis_match_fkey FOREIGN KEY (match) 
            REFERENCES matches (id) 
            ON UPDATE CASCADE,
    CONSTRAINT prognosis_cluster_fkey FOREIGN KEY (cluster) 
            REFERENCES clusters (id) 
            ON UPDATE CASCADE 
            ON DELETE CASCADE,
    CONSTRAINT prognosis_type_id_fkey FOREIGN KEY (type_id) 
            REFERENCES odds_type (id)   
            ON UPDATE CASCADE
);


