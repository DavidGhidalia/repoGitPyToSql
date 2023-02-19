-- FUNCTION: public.get_beegames_jokers(integer, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_beegames_jokers(integer, integer) cascade;

CREATE OR REPLACE FUNCTION public.get_beegames_jokers(
  _beegame integer,
  _user integer
  ) RETURNS TABLE(
    id integer,
    jokers integer[]
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY
 
SELECT q.id, array_remove(array_agg(CASE WHEN q.joker_used = false THEN q.joker ELSE NULL END), NULL) jokers
FROM (
  SELECT b.id, bj.joker, 1 = any(array_agg(case when bp.id is not null THEN 1 else 0 end)) AS joker_used
  FROM beegames b
  LEFT JOIN beegames_jokers bj ON bj.type_id = b.type_id AND bj.active
  LEFT JOIN beegames_tickets bt ON bt.beegame_id = b.id AND bt.user_id = _user
  LEFT JOIN beegames_prognosis bp ON bp.ticket_id = bt.id AND bp.joker = bj.joker
  WHERE b.id = _beegame
  GROUP BY b.id, bj.joker
) q
GROUP BY q.id;

END $BODY$;