-- FUNCTION: public.get_perfects_played(integer, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_perfects_played(integer, integer, integer) cascade;

CREATE OR REPLACE FUNCTION public.get_perfects_played(
  _match integer,
  _beegame integer default null,
  _user integer default null
  ) RETURNS TABLE(
    id integer,
    played boolean
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY
 
  SELECT _match, CASE WHEN _beegame IS NOT NULL AND _user IS NOT NULL THEN EXISTS(
    SELECT bp.id 
    FROM beegames_tickets bt 
    JOIN beegames_prognosis bp ON bp.ticket_id = bt.id AND bp.match_id = _match 
    WHERE bt.beegame_id = _beegame AND bt.user_id = _user
  ) ELSE false 
  END;

END $BODY$;