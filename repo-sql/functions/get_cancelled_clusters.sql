-- FUNCTION: public.get_cancelled_clusters(integer)
DROP FUNCTION IF EXISTS public.get_cancelled_clusters(integer);

CREATE OR REPLACE FUNCTION public.get_cancelled_clusters(_match integer) 
RETURNS TABLE(cluster json, prognosis json) LANGUAGE 'sql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
SELECT row_to_json(c.*) AS cluster, COALESCE(json_agg(p.*) 
FILTER (WHERE p.id IS NOT NULL), '[]') AS prognosis
FROM (
  SELECT p.cluster
  FROM prognosis p 
  WHERE p.match = _match
  AND (p.content->>'odd')::double precision = 1
) q
LEFT JOIN prognosis p ON p.cluster = q.cluster AND (p.content->>'odd')::double precision > 1
LEFT JOIN clusters c ON c.id = q.cluster
GROUP BY c.id;
$BODY$;
