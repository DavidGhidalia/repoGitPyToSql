-- FUNCTION: public.clusters_by_matches(json[])

 DROP FUNCTION IF EXISTS public.bookmakers_by_matches(json[]);

CREATE OR REPLACE FUNCTION public.clusters_by_matches(
	_matches json[])
    RETURNS TABLE(nb_clusters bigint)
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE 
q text;
BEGIN 

q := 'SELECT COUNT(DISTINCT q.id) FROM (SELECT c.id FROM clusters c ';

FOR i IN 1..coalesce(array_length(_matches, 1), 0) 
LOOP
q := q || ' JOIN prognosis p_' || i || ' ON p_' || i || '.cluster = c.id AND p_' ||
 i || '.match = ' || (_matches[i]->>'id')::integer || ' AND p_' || i || '.type_id = ' || 
 (_matches[i]->>'typeId')::integer;
END LOOP;

q := q || ' JOIN prognosis p ON p.cluster = c.id GROUP BY c.id HAVING COUNT(p.id) = array_length($1, 1)) q ';

RETURN QUERY
EXECUTE q USING _matches;

END
$BODY$;