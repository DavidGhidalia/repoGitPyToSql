CREATE TABLE IF NOT EXISTS public.odds_type (
    id integer NOT NULL DEFAULT nextval('public.odds_type_id_seq'::regclass),
    field_id integer NOT NULL,
    name  varchar(255),
    field_name varchar(255),
    value double precision,
    label varchar(255),
    field_label varchar(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
    
);




