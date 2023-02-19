-- View: public.v_beegame_winner

DROP VIEW IF EXISTS public.v_beegame_winner;

CREATE OR REPLACE VIEW public.v_beegame_winner
 AS
 SELECT DISTINCT ON (bt.beegame_id) 
    bt.id, 
    bt.beegame_id,
    u.id AS user_id,
    u.nickname,
    u.avatar,
    u.roi,
    bt.nb_prognosis,
    json_build_object('beegame_id', bt.beegame_id, 'bookmaker_id', bt.bookmaker_id, 'content', 
    bt.content, 'created_at', bt.created_at, 'hash', bt.hash, 'id', bt.id, 'odds_value', bt.odds_value, 
    'win', bt.win, 'win_beegame', bt.win_beegame, 'owner', 
    json_build_object('id', u.id, 'nickname', u.nickname, 'avatar', u.avatar, 'roi', u.roi), 
    'prognosis', bt.prognosis) AS ticket
   FROM (
	  SELECT bt.beegame_id
	  FROM beegames_tickets bt
	  GROUP BY bt.beegame_id
	  HAVING count(bt.id) 
     FILTER (WHERE bt.win IS NULL) = 0
   ) q
   JOIN v_beegame_tickets bt on bt.beegame_id = q.beegame_id
  JOIN users u ON u.id = bt.user_id
  WHERE bt.win
  ORDER BY bt.beegame_id, bt.odds_value DESC, bt.created_at;