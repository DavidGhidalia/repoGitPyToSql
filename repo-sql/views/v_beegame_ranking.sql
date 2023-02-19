-- View: public.v_beegame_ranking

DROP VIEW IF EXISTS public.v_beegame_ranking;

CREATE OR REPLACE VIEW public.v_beegame_ranking
 AS
 SELECT row_number() OVER (PARTITION BY q.beegame_id ORDER BY q.odds_value DESC, q.created_at) AS rank,
    q.beegame_id,
    q.date_start,
    q.user_id,
    q.email,
    q.nickname,
    q.avatar,
    q.followers,
    q.ticket_id,
    q.odds_value,
    q.num_ticket,
    q.created_at
   FROM (
	  SELECT bt.beegame_id
	  FROM beegames_tickets bt
	  GROUP BY bt.beegame_id
	  HAVING count(bt.id) FILTER (WHERE bt.win IS NULL) = 0
   ) r
   JOIN ( SELECT b.id AS beegame_id,
            b.date_start,
            u.id AS user_id,
            u.email,
            u.nickname,
            u.avatar,
            u.followers,
            bt.id as ticket_id, 
            max(bt.odds_value) AS odds_value,
            bt.num_ticket,
		 	      bt.created_at
           FROM beegames b
             LEFT JOIN beegames_tickets bt ON bt.beegame_id = b.id
             LEFT JOIN users u ON u.id = bt.user_id
          WHERE bt.win = true
          GROUP BY b.id, u.id, bt.id) q on q.beegame_id = r.beegame_id;