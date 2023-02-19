-- FUNCTION: public.bookmakers_by_matches_json(json[], character varying)

DROP FUNCTION IF EXISTS public.bookmakers_by_matches_json(integer, json);

CREATE OR REPLACE FUNCTION public.bookmakers_by_matches_json(
  _bookmaker integer,
	_matches json)
    RETURNS TABLE(id integer, odd double precision) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE 
q text;
sq text;
temprow record;
BEGIN 

q := ' SELECT q.bookmaker_id as id, mul(q.odd) FROM ( ';
sq := '';

FOR temprow IN SELECT * FROM json_array_elements(_matches) with ordinality
LOOP
  IF temprow.ordinality > 1 THEN 
    sq := sq || ' UNION ALL ';
  END IF;

  sq := sq || ' SELECT bookmaker_id, odd FROM v_odds WHERE match = ' || 
  (temprow.value->>'id')::integer || ' AND type_id = ' || (temprow.value->>'typeId')::integer || 
  ' AND bookmaker_id = ' || _bookmaker || ' ';  
END LOOP;

q := q || sq || ' ) q GROUP BY q.bookmaker_id ';

RETURN QUERY
EXECUTE q;

END
$BODY$;