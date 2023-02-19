-- FUNCTION: public.get_beegames_stats(integer)

 DROP FUNCTION IF EXISTS public.get_beegames_stats(integer);

CREATE OR REPLACE FUNCTION public.get_beegames_stats(
	_beegame integer)
    RETURNS TABLE(
      id integer, 
      odd_min numeric, 
      odd_max numeric, 
      odd_avg double precision, 
      participants jsonb, 
      tickets bigint, 
      tickets_matches_avg double precision
    )
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$

SELECT 	b.id, 
		    (SELECT  min(odds_value) 
         FROM beegames_tickets 
         WHERE beegame_id = b.id AND  odds_value > 1) 
         AS odd_min,
		    (SELECT  max(odds_value) 
         FROM beegames_tickets 
         WHERE beegame_id = b.id AND  odds_value > 1) 
         AS odd_max,
			  (SELECT percentile_cont(0.5::double precision) 
        WITHIN group (
         ORDER BY odds_value) 
         FROM beegames_tickets 
         WHERE beegame_id = b.id AND odds_value > 1) 
         AS odd_avg,
		   	coalesce(jsonb_agg(jsonb_build_object('id', u.id, 'nickname', u.nickname, 'avatar', u.avatar,
         'verified', u.verified, 'vip', u.vip, 'roi', pf.roi)) 
         FILTER (
           WHERE u.id IS NOT NULL), '[]') 
           AS participants,
		    (SELECT count(id) 
         FROM beegames_tickets 
         WHERE beegame_id = b.id ) 
         AS tickets,
		    (SELECT percentile_cont(0.5::double precision) 
        WITHIN group (
          ORDER BY q.prognosis) 
          FROM (
            SELECT bt.id, count(bp.*) 
            AS prognosis 
            FROM beegames_tickets bt 
            JOIN beegames_prognosis bp 
            ON bp.ticket_id = bt.id 
            WHERE bt.beegame_id = b.id 
            GROUP BY bt.id) q) 
            AS tickets_matches_avg
FROM beegames b
LEFT JOIN users u ON u.id = any(b.users)
LEFT JOIN performances pf ON pf.user_id = u.id
WHERE b.id = _beegame
GROUP BY b.id;

$BODY$;