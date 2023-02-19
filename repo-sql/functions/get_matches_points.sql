
DROP FUNCTION IF EXISTS public.get_explore_clusters(integer);

CREATE OR REPLACE FUNCTION get_matches_points(_match integer) 
  RETURNS TABLE(
    id integer,
    type_id integer,
    score text,
    points_winner integer,
    points_perfect integer,
    weight integer
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN
RETURN QUERY

SELECT 	s.id,
        ot.id,
        s.score,
        bp.points_winner,
		    bp.points_perfect,
        bp.weight
FROM (
  SELECT 	r.*, case when r.score_home > r.score_away then 'home' when r.score_home < r.score_away then 'away' else 'draw' end as score_fn
  FROM (
    SELECT q.id, s.market, q.score, split_part(q.score, '-', 1) as score_home, split_part(q.score, '-', 2) as score_away
    FROM (
      SELECT m.id, m.sport, replace(s->>'value', ':', '-') as score
      FROM matches m
      INNER JOIN jsonb_array_elements(m.result->'Score') s on s->>'type' = 'NT' and s->>'value' <> '' and (s->>'retired')::boolean = false and (s->>'canceled')::boolean = false and (s->>'walkover')::boolean = false and (s->>'postponed')::boolean = false
      WHERE m.id = _match and m.result is not null

      UNION

      SELECT m.id, m.sport, replace(s->>'value', ':', '-') as score
      FROM matches m
      INNER JOIN jsonb_array_elements(m.result_live->'Score') s on s->>'type' = 'NT' and s->>'value' <> '' and (s->>'retired')::boolean = false and (s->>'canceled')::boolean = false and (s->>'walkover')::boolean = false and (s->>'postponed')::boolean = false
      WHERE m.id = _match and m.result_live is not null
    ) q
    INNER JOIN sports s on s.id = q.sport
  ) r
) s
INNER JOIN odds_type ot on lower(ot.name) = lower(s.market) and lower(ot.field_name) = lower(s.score_fn)
INNER JOIN beegames_points bp on bp.match_id = s.id and bp.odds_type_id = ot.id;

END $BODY$;