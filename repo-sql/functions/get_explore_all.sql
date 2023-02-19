-- FUNCTION: public.get_explore_all(text, integer, lang, integer, integer)

DROP FUNCTION IF EXISTS public.get_explore_all(text, integer, lang, integer, integer);

CREATE OR REPLACE FUNCTION public.get_explore_all(
	_query text,
  _user integer,
  _lang lang default 'fr',
	_limit integer default 100,
  _offset integer default 0)
    RETURNS TABLE(id integer, name character varying, label character varying, results json) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
cids integer[];
BEGIN
RETURN QUERY

SELECT q.id, q.name, q.label, json_agg(q.result) AS results
FROM (
SELECT tr.id, tr.name, tr.label, row_to_json(u.*) AS result
FROM v_explores_tr tr
JOIN get_explore_users(_query, _user, _limit, _offset) u ON u.explore_id = tr.id
WHERE tr.lang = _lang AND tr.active

UNION ALL

SELECT tr.id, tr.name, tr.label, row_to_json(c.*) AS result
FROM v_explores_tr tr
JOIN get_explore_clusters(_query, _user, _lang, _limit, _offset) c ON c.explore_id = tr.id
WHERE tr.lang = _lang AND tr.active

UNION ALL

SELECT tr.id, tr.name, tr.label, row_to_json(m.*) AS result
FROM v_explores_tr tr
JOIN get_explore_matches(_query, _lang, _limit, _offset) m ON m.explore_id = tr.id
WHERE tr.lang = _lang AND tr.active

UNION ALL 

SELECT tr.id, tr.name, tr.label, row_to_json(s.*) AS result
FROM v_explores_tr tr
JOIN get_explore_scores(_query, _lang, _limit, _offset) s ON s.explore_id = tr.id
WHERE tr.lang = _lang AND tr.active
) q
GROUP BY q.id, q.name, q.label;

END
$BODY$;