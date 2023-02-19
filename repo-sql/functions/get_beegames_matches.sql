-- FUNCTION: public.get_beegames_matches(integer, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_beegames_matches(integer) CASCADE;

CREATE OR REPLACE FUNCTION public.get_beegames_matches(
  _beegame integer
  ) RETURNS TABLE(
    id integer,
    date timestamptz,
    result jsonb,
    status match_status,
    match_status match_match_status,
    sport json,
    teams json,
    tournament json,
    category json
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY
 
SELECT  m.id, 
        m.date, 
        m.result,
        m.status,
        m.match_status,
        row_to_json(s.*) 
        AS sport,
        json_agg(t.* 
        ORDER BY (CASE WHEN t.id = m.home_team THEN 0 ELSE 1 END)) 
        AS teams,
        row_to_json(tr.*) AS tournament,
        row_to_json(c.*) AS category
FROM beegames b
INNER JOIN matches m ON m.date BETWEEN b.date_start AND b.date_end AND CASE 
WHEN b.matches <> '{}' 
THEN m.id = any(b.matches) 
ELSE 1=1 
END 
AND CASE WHEN b.tournaments <> '{}' 
THEN m.tournament = any(b.tournaments) ELSE 1=1 
END 
AND CASE WHEN b.sport_id IS NOT NULL 
THEN m.sport = b.sport_id 
ELSE 1=1 
END
INNER JOIN teams t ON t.id = any(m.teams)
INNER JOIN tournaments tr ON tr.id = m.tournament
INNER JOIN categories c ON c.id = m.category
INNER JOIN sports s ON s.id = m.sport
WHERE b.id = _beegame
GROUP BY m.id, s.id, tr.id, c.id;

END $BODY$;