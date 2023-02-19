-- FUNCTION: public.bookmakers_by_matches(json[], character varying)

DROP FUNCTION IF EXISTS public.bookmakers_by_matches(integer, json[]);

CREATE OR REPLACE FUNCTION public.bookmakers_by_matches(
  _bookmaker integer,
	_matches json[])
    RETURNS TABLE(id integer, odd double precision) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE 
q text;
sq text;
i integer;
BEGIN 

q := ' SELECT q.bookmaker_id as id, mul(q.odd) FROM ( ';
sq := '';

FOR i IN 1..coalesce(array_length(_matches, 1), 0) 
LOOP
  IF i > 1 THEN 
    sq := sq || ' UNION ALL ';
  END IF;

  sq := sq || ' SELECT bookmaker_id, odd FROM v_odds WHERE match = ' || 
  (_matches[i]->>'id')::integer || ' AND type_id = ' || (_matches[i]->>'typeId')::integer ||
   ' AND bookmaker_id = ' || _bookmaker || ' ';  
END LOOP;

q := q || sq || ' ) q GROUP BY q.bookmaker_id ';

RETURN QUERY
EXECUTE q;

END
$BODY$;