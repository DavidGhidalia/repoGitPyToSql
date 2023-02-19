-- FUNCTION: public.get_perfects_prognosis(integer, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_perfects_prognosis(integer,text,text) cascade;

CREATE OR REPLACE FUNCTION public.get_perfects_prognosis(
  _match integer,
  _type text,
  _result text
  ) RETURNS TABLE(
    match_id integer,
    type_id integer,
    result text,
    draw boolean,
    points_winner integer,
    points_perfect integer,
    odd double precision
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY
 
SELECT q.id, ot.id as type_id, q.result, q.field_name = 'draw' as draw, bp.points_winner, bp.points_perfect, (oc->>'$t')::double precision as odd
FROM (
  SELECT m.id, home.score || '-' || away.score as result, case when home.score > away.score then 'home' else case when home.score < away.score then 'away' else 'draw' end end as field_name 
	FROM matches m, cast(split_part(_result, '-', 1) as integer) home(score), cast(split_part(_result, '-', 2) as integer) away(score)
	WHERE m.id = _match
) q
LEFT JOIN odds_type ot on ot.name = _type and lower(ot.field_name) = q.field_name
LEFT JOIN odds o on o.match = q.id and o.bookmaker = 9999 and ot.id = any(o.odds_type_ids)
LEFT JOIN jsonb_array_elements(o.details->'Outcome') oc on lower(oc->>'name') = q.field_name
LEFT JOIN beegames_points bp on bp.match_id = q.id and bp.odds_type_id = ot.id;

END $BODY$;