DROP FUNCTION IF EXISTS public.get_funfacts(integer, lang);


CREATE FUNCTION public.get_funfacts(id integer, lang lang default 'fr', OUT url character varying) 
RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    url = 'https://api.sportradar.us/soccer/production/v4/' || lang || '/sport_events/sr:sport_event:' 
    || cast(id AS varchar) || '/fun_facts.json?api_key=awnb42cebsaykc6n9qeykkry';
END;
$$;