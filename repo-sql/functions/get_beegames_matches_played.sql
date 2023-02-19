-- FUNCTION: public.get_beegames_played(integer, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_beegames_matches_played(integer, integer, integer[]) cascade;

CREATE OR REPLACE FUNCTION public.get_beegames_matches_played(
  _beegame integer,
  _user integer,
  _matches integer[]
  ) RETURNS TABLE(
    id integer,
    user_id integer,
    match_id integer,
    played boolean
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY
 
SELECT b.id, u.id, m, EXISTS(
  SELECT 1 
  FROM beegames_tickets bt 
  JOIN beegames_prognosis bp ON bp.ticket_id = bt.id AND bp.match_id = m 
  WHERE bt.beegame_id = b.id AND bt.user_id = u.id)
FROM beegames b
JOIN users u ON u.id = _user
CROSS JOIN unnest(_matches) m
WHERE b.id = _beegame;

END $BODY$;