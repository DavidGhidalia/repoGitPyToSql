-- View: public.v_typeodds

DROP VIEW IF EXISTS public.v_typeodds;

CREATE OR REPLACE VIEW public.v_typeodds
 AS
 SELECT ot.id,
    ot.name,
    ot.field_name,
    ot.value,
    o.details,
    o.bookmaker,
    o.match
   FROM odds o
   INNER JOIN matches m ON m.id = o.match
   INNER JOIN odds_type ot ON ot.id = ANY (o.odds_type_ids)
   WHERE m.sport IN (2,5)
  GROUP BY o.match, o.details, o.bookmaker, ot.name, ot.id

UNION ALL

SELECT 
  id_best_odds AS id,
  bo.details->>'type' AS name,
  bo.details->'Outcome'->0->>'name' AS field_name,
  (bo.details #>> '{typekey}')::numeric AS value,
  o.details,
  o.bookmaker,
  o.match
FROM odds o
INNER JOIN best_odds bo ON bo.match = o.match AND  bo.id = o.id_best_odds
INNER JOIN matches m ON m.id = o.match
WHERE m.sport = 1
 GROUP BY o.match, o.details, o.bookmaker, bo.details->>'type', id_best_odds

