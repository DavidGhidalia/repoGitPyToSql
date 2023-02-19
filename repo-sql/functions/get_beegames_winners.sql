-- FUNCTION: public.get_beegames_winners(integer)

 DROP FUNCTION IF EXISTS public.get_beegames_winners(integer, lang );

CREATE OR REPLACE FUNCTION public.get_beegames_winners(
	_beegame_id integer, _lang lang default 'fr')
    RETURNS TABLE(id integer, beegame_id integer, user_id integer, nickname varchar, 
    avatar varchar, roi numeric, nb_prognosis bigint, ticket json)
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
SELECT DISTINCT ON (bt.beegame_id) 
    bt.id, 
    bt.beegame_id,
    u.id AS user_id,
    u.nickname,
    u.avatar,
    u.roi,
    t.nb_prognosis,
	json_build_object('beegame_id', bt.beegame_id, 'bookmaker_id', bt.bookmaker_id, 
    'content', t.content, 'oddsValue', bt.odds_value, 'created_at', bt.created_at, 
    'hash', bt.hash, 'id', bt.id, 'odds_value', bt.odds_value, 'win', bt.win, 'win_beegame', 
    bt.win_beegame, 'owner', json_build_object('id', u.id, 'nickname', u.nickname, 'avatar', 
    u.avatar, 'roi', u.roi), 'prognosis', t.prognosis) AS ticket
FROM beegames_tickets bt 
JOIN get_beegames_tickets(bt.beegame_id, bt.user_id, CASE
WHEN _lang IS NOT NULL 
THEN _lang 
ELSE 'fr'::lang 
END) t 
ON t.id = bt.id
JOIN users u ON u.id = bt.user_id
JOIN (SELECT bt.beegame_id, COUNT(bt.id)
      FILTER (WHERE bt.win IS NULL) AS nb_tickets_no_result 
      FROM beegames_tickets bt 
      GROUP BY bt.beegame_id) q ON bt.beegame_id = q.beegame_id AND q.nb_tickets_no_result = 0
WHERE bt.beegame_id = _beegame_id AND bt.win
ORDER BY bt.beegame_id, bt.odds_value DESC, bt.created_at;
$BODY$;