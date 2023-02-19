-- FUNCTION: public.get_beegames_matches_status(integer, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_beegames_matches_status(integer) cascade;

CREATE OR REPLACE FUNCTION public.get_beegames_matches_status(
  _beegame integer
  ) RETURNS TABLE(
    id integer,
    status beegame_status,
    timer_status text,
    timer_date timestamptz,
    matches bigint,
    matches_next bigint,
    date_next timestamptz
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY

SELECT  q.id, 
        q.status, 
        CASE WHEN q.matches_next = q.matches 
        THEN 'first' 
        ELSE 
        CASE WHEN q.matches_next > 1 
        THEN 'next' 
        ELSE 
        CASE WHEN q.matches_next = 1 
        THEN 'last' 
        ELSE 'ended' END END END AS timer_status, 
        CASE WHEN q.matches_next > 0 
        THEN q.date_next 
        ELSE q.date_end END AS timer_date,
        q.matches,
        q.matches_next,
        q.date_next
FROM (
  SELECT  b.id,
	        b.date_start,
		      b.date_end,
          b.status, 
          min(bm.date) 
          FILTER (where bm.date > now()) AS date_next,
		      count(bm.id) AS matches,
		      count(bm.id) 
          FILTER (where bm.date > now()) AS matches_next
  FROM beegames b
  LEFT JOIN get_beegames_matches(b.id) bm ON bm.id IS NOT NULL
  WHERE b.id = _beegame
  GROUP BY b.id
) q;

END $BODY$;