-- FUNCTION: public.format_month(timestamp with time zone)

 DROP FUNCTION IF EXISTS public.format_month(timestamp with time zone);

CREATE OR REPLACE FUNCTION public.format_month(
	_month timestamp with time zone)
    RETURNS text
    LANGUAGE 'sql'
    COST 100
    STABLE PARALLEL UNSAFE
AS $BODY$
SELECT set_config('lc_time', 'fr_FR.utf8', true);
  SELECT to_char(_month, 'TMMonth YYYY');
$BODY$;