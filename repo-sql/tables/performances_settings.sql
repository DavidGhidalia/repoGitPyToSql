CREATE TABLE IF NOT EXISTS public.performances_settings (
  code character varying(64) primary key not null,
  description jsonb,
  active boolean default false
);