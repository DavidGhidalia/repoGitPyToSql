-- Table: public.reports

-- DROP TABLE public.reports;

CREATE TABLE IF NOT EXISTS public.reports (
    id integer DEFAULT nextval('public.reports_id_seq'::regclass) NOT NULL,
    id_reference integer NOT NULL,
    type_reference character varying NOT NULL,
    id_owner integer NOT NULL,
    id_reported_user integer NOT NULL,
    created_at timestamp(0) with time zone,
    number integer,
    reason character varying,
    reason_type character varying,
    CONSTRAINT reports_pkey PRIMARY KEY (id)
);


ALTER TABLE public.reports
    ALTER  COLUMN if exists "number" DROP NOT NULL;