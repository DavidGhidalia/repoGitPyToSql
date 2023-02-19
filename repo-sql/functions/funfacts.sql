 DROP FUNCTION IF EXISTS public.get_funfacts(integer);


CREATE OR REPLACE FUNCTION public.get_funfacts(IN id integer,OUT url character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    VOLATILE
    PARALLEL UNSAFE
    COST 100
AS $BODY$
begin
    url = 'https://api.sportradar.us/soccer/production/v4/fr/sport_events/sr:sport_event:' || cast(id as varchar) || '/fun_facts.json?api_key=awnb42cebsaykc6n9qeykkry';
end;
$BODY$;
