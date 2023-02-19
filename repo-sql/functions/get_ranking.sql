-- FUNCTION: public.get_ranking(character varying, integer)

DROP FUNCTION IF EXISTS public.get_ranking(character varying, integer) cascade;

CREATE OR REPLACE FUNCTION public.get_ranking(
    _type character varying,
    _follower integer DEFAULT NULL::integer
  ) RETURNS TABLE(
    rank bigint,
    id integer,
    nickname character varying,
    avatar character varying,
    verified boolean,
    bet_count bigint,
    roi numeric,
    admin boolean,
    reward text
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
DECLARE 
ranking record;
rec record;
q text;
r text;
havings text;
BEGIN 

q := 'SELECT u_1.id, 
						u_1.nickname, 
						u_1.avatar,
            u_1.verified,
            CASE $1 WHEN ''monthly'' THEN pf.monthly_roi WHEN ''j30'' THEN roi_30 WHEN ''score_top'' THEN pf.score_top WHEN ''score_monthly'' THEN pf.score_monthly WHEN ''score_j30'' THEN pf.score_j30 WHEN ''coins'' THEN pf.roi_coins WHEN ''coins_stake'' THEN pf.roi_coins_stake ELSE pf.roi END as roi,
						count(c.id) as bet_count,
            rs.admin
					FROM users u_1
					LEFT JOIN clusters c ON c.owner = u_1.id AND c.win IS NOT NULL AND c.status IS DISTINCT FROM ''cancelled''::cluster_status AND CASE WHEN $1 = ''monthly'' OR $1 = ''score_monthly'' THEN c.created_at >= date_trunc(''month'', now()) WHEN $1 = ''j30'' OR $1 = ''score_j30'' THEN c.created_at >= CURRENT_DATE - interval ''30 day'' ELSE 1=1 END
					JOIN performances pf ON pf.user_id = u_1.id';
		
havings := 'HAVING 1=1';

FOR ranking IN SELECT type, days, bets FROM rankings_settings WHERE type = $1
LOOP 
  q := q || ' LEFT JOIN rankings_settings rs on rs.type = $1';
  q := q || ' LEFT JOIN clusters c_' || ranking.days || ' ON c_' || ranking.days || '.id = c.id AND CASE WHEN ' || ranking.days || ' > 0 THEN c_' || ranking.days || '.created_at >= (CURRENT_DATE - ''1 day''::interval day * ' || ranking.days::double precision || ') ELSE 1=1 END';
  havings := havings || ' AND count(c_' || ranking.days || '.id) >=' || ranking.bets;
END LOOP;

q := q || ' WHERE CASE WHEN $2 IS NOT NULL THEN u_1.id = $2 OR $2 = any(u_1.followers) ELSE 1=1 END GROUP BY u_1.id, rs.admin, pf.roi, pf.monthly_roi, pf.roi_30, pf.score_top, pf.score_monthly, pf.score_j30, pf.roi_coins, pf.roi_coins_stake ' || havings;
r := 'SELECT row_number() OVER (ORDER BY q.roi DESC) AS rank, q.id, q.nickname, q.avatar, q.verified, q.bet_count, q.roi, q.admin, null as reward FROM (' || q || ') q WHERE q.roi IS NOT NULL'; 

RETURN QUERY
EXECUTE r USING _type, _follower;

END $BODY$;