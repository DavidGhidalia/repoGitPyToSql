-- FUNCTION: public.get_beegames_rankings(integer)

 DROP FUNCTION IF EXISTS public.get_beegames_rankings(integer);

CREATE OR REPLACE FUNCTION public.get_beegames_rankings(
	_beegame_id integer)
    RETURNS TABLE(rank bigint, beegame_id integer, user_id integer, 
    email varchar, nickname varchar, avatar varchar, followers integer[], verified boolean, vip boolean, ticket_id integer, odds_value numeric, num_ticket bigint, created_at timestamp with time zone)
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
SELECT row_number() OVER (PARTITION BY q.beegame_id 
ORDER BY q.odds_value DESC, q.created_at) AS rank,
    q.beegame_id,
    q.user_id,
    q.email,
    q.nickname,
    q.avatar,
    q.followers,
    q.verified,
    q.vip,
    q.ticket_id,
    q.odds_value,
    q.num_ticket,
    q.created_at
   FROM (
     SELECT DISTINCT ON (bt.beegame_id, bt.user_id)
      bt.beegame_id,
      bt.user_id, 
      u.email, 
      u.nickname, 
      u.avatar, 
      u.followers,
      u.verified,
      u.vip, 
      bt.id AS ticket_id, 
      bt.odds_value, 
      bt.num_ticket, 
      bt.created_at
    FROM beegames_tickets bt
    JOIN users u ON u.id = bt.user_id
    WHERE bt.beegame_id = _beegame_id AND bt.win
    ORDER BY bt.beegame_id, bt.user_id, bt.odds_value DESC) q
    JOIN (SELECT bt.beegame_id, COUNT(bt.id) 
    FILTER (WHERE bt.win IS NULL) AS nb_tickets_no_result 
    FROM beegames_tickets bt 
    GROUP BY bt.beegame_id) r ON r.beegame_id = q.beegame_id AND r.nb_tickets_no_result = 0;
$BODY$;