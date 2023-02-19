DROP FUNCTION IF EXISTS public.get_url(integer, character varying)

CREATE FUNCTION public.get_url(id integer, mode character varying, OUT url character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

begin
    url = 'https://img-cdn001.akamaized.net/ls/crest/'|| mode || '/' || cast(id as varchar) || '.png';
end;
$$;