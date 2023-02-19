-- FUNCTION: public.get_contests_results(integer, integer)

DROP FUNCTION IF EXISTS public.get_contests_results(integer, integer);

CREATE OR REPLACE FUNCTION public.get_contests_results(
	_contest integer,
	_user integer)
    RETURNS TABLE(id integer, results jsonb, results_following jsonb) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY

SELECT c.id, c.results, jsonb_agg(r.* 
ORDER BY (r->>'rank')::integer) AS results_following
FROM contest c
LEFT JOIN users u ON u.id = _user
LEFT JOIN jsonb_array_elements(c.results) r ON (r->>'id')::integer = u.id 
OR (r->>'id')::integer = any(u.following)
WHERE c.id = _contest
GROUP BY c.id;
  
END
$BODY$;