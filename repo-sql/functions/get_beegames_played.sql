-- FUNCTION: public.get_beegames_played(integer, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_beegames_played(integer, integer, integer, integer) CASCADE;

CREATE OR REPLACE FUNCTION public.get_beegames_played(
  _beegame integer,
  _match integer,
  _type integer default null,
  _user integer default null
  ) RETURNS TABLE(
    id integer,
    type_id integer,
    played boolean,
    played_type boolean
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY
 
  SELECT _match, _type, CASE 
  WHEN _user IS NOT NULL 
  THEN 1 = any(array_agg(CASE 
  WHEN bp.id IS NOT NULL 
  THEN 1 
  ELSE 0 
  END)) 
  ELSE false 
  END, 
  CASE WHEN _user IS NOT NULL 
  THEN 1 = any(array_agg(
  CASE WHEN (bp.content->>'type_id')::integer = _type 
  THEN 1 
  ELSE 0 
  END)) 
  ELSE false 
  END
  FROM beegames b
  LEFT JOIN beegames_tickets bt ON bt.beegame_id = b.id AND CASE 
  WHEN _user IS NOT NULL 
  THEN bt.user_id = _user 
  ELSE 1=1 
  END
  LEFT JOIN beegames_prognosis bp ON bp.ticket_id = bt.id AND bp.match_id = _match
  WHERE b.id = _beegame;

END $BODY$;