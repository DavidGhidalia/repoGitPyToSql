-- FUNCTION: public.get_owners(integer[])
DROP FUNCTION IF EXISTS public.get_owners(integer[]);

CREATE OR REPLACE FUNCTION public.get_owners(_matches integer []) 
RETURNS TABLE(match integer, owners integer []) LANGUAGE 'sql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
SELECT r.match,
  array_remove(array_agg(DISTINCT r.owner), NULL) as owners
FROM (
    SELECT distinct q.match,
      q.owner
    FROM (
        SELECT distinct p.match as match,
          c.owner as owner
        FROM prognosis p
          LEFT JOIN clusters c on c.id = p.cluster
        WHERE p.match = ANY(_matches)
        UNION
        SELECT distinct bp.match_id as match,
          bt.user_id as owner
        FROM beegames_prognosis bp
          LEFT JOIN beegames_tickets bt on bt.id = bp.ticket_id
        WHERE bp.match_id = ANY(_matches)
      ) q
  ) r
GROUP BY r.match 
$BODY$;