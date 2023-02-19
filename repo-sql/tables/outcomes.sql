
DROP TABLE IF EXISTS public.outcomes CASCADE;

CREATE TABLE IF NOT EXISTS public.outcomes (
    market_id integer,
    name character varying(20),
    field_name character varying(256),
    type_label character varying(100),
    priority integer,
    visible boolean,
    sr_field_name varchar(256),
    id SERIAL PRIMARY KEY
);
