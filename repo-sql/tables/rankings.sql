-- Table: public.rankings

-- DROP TABLE public.rankings;

CREATE TABLE IF NOT EXISTS public.rankings
(
    type character varying(20) COLLATE pg_catalog."default" NOT NULL,
    days integer NOT NULL,
    bets integer NOT NULL,
    CONSTRAINT rankings_pkey PRIMARY KEY (type, days)
)