-- FUNCTION: public.get_beegames_points(integer, integer)

DROP FUNCTION IF EXISTS public.get_beegames_points(integer, integer) CASCADE;

CREATE OR REPLACE FUNCTION public.get_beegames_points(
  _beegame integer,
  _user integer
  ) RETURNS TABLE(
    id integer,
    user_id integer,
    nickname character varying,
    avatar character varying,
    bet_count integer,
    roi numeric,
	  points integer,
	  points_pending integer,
    beecoins_win numeric,
    beecoins_claimed boolean
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY

SELECT q.id, q.user_id, q.nickname, q.avatar, q.bet_count, q.roi, q.points, 
coalesce(sum((bp.content->>'points_winner')::integer)::integer, 0) 
AS points_pending, q.beecoins_win, q.beecoins_claimed
FROM (
	SELECT b.id, b.type_id, u.id 
  AS user_id, u.nickname, u.avatar, p.bet_count, p.roi, 
  coalesce((r->>'points')::integer, 0) AS points, 
  coalesce((r->>'beecoins_win')::numeric, 0) 
  AS beecoins_win, (r->>'beecoins_claimed')::boolean AS beecoins_claimed
	FROM beegames b
	LEFT JOIN users u ON u.id = _user
	LEFT JOIN performances p ON p.user_id = u.id
	LEFT JOIN contest c ON c.id = b.contest_id
	LEFT JOIN jsonb_array_elements(c.results) r ON (r->>'id')::integer = u.id
	WHERE b.id = _beegame
) q
LEFT JOIN beegames_tickets bt ON bt.beegame_id = q.id AND bt.user_id = q.user_id
LEFT JOIN beegames_prognosis bp ON bp.ticket_id = bt.id AND bp.win IS NULL
GROUP BY q.id, q.user_id, q.nickname, q.avatar, q.bet_count, q.roi, q.points, q.beecoins_win, q.beecoins_claimed;

END $BODY$;