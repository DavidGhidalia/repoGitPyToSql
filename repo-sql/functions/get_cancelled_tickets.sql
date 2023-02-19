-- FUNCTION: public.get_cancelled_tickets(integer)
DROP FUNCTION IF EXISTS public.get_cancelled_tickets(integer);

CREATE OR REPLACE FUNCTION public.get_cancelled_tickets(_match integer) 
RETURNS TABLE(ticket json, prognosis json) LANGUAGE 'sql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
SELECT row_to_json(bt.*) AS ticket, COALESCE(json_agg(bp.*) 
FILTER (WHERE bp.id IS NOT NULL), '[]') 
AS prognosis
FROM (
  SELECT btk.id
  FROM beegames b
  JOIN beegames_types bt ON bt.id = b.type_id
  JOIN beegames_tickets btk ON btk.beegame_id = b.id
  JOIN beegames_prognosis bp ON bp.ticket_id = btk.id AND bp.match_id = _match 
  AND (bp.content->>'odd')::double precision = 1
  WHERE bt.slug = 'topday'
) q
LEFT JOIN beegames_prognosis bp ON bp.ticket_id = q.id AND (bp.content->>'odd')::double precision > 1
LEFT JOIN beegames_tickets bt ON bt.id = q.id
GROUP BY bt.id;
$BODY$;