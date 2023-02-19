-- FUNCTION: public.get_ranking_by_month(character varying, date)

DROP FUNCTION IF EXISTS public.get_ranking_by_month(character varying, date) cascade;

CREATE OR REPLACE FUNCTION public.get_ranking_by_month(
    _type character varying,
    _month date
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
havings text;
BEGIN 
CREATE TEMP TABLE results (
  id integer,
  nickname character varying,
  avatar character varying,
  verified boolean,
  bet_count bigint,
  roi numeric,
  admin boolean
);

q := 'SELECT u_1.id, 
						u_1.nickname, 
						u_1.avatar,
            u_1.verified,
            SUM((c.odds_value * CASE WHEN c.win THEN 1 ELSE 0 END::numeric - 1::numeric) * c.stake::numeric) / NULLIF(sum(c.stake)::numeric, 0) AS roi,
            COUNT(c.id) AS bet_count,
            rs.admin
      FROM users u_1
      LEFT JOIN clusters c ON c.owner = u_1.id AND c.win IS NOT NULL AND c.status IS DISTINCT FROM ''cancelled''::cluster_status AND CASE WHEN $1 = ''monthly'' THEN c.created_at::date >= $2 AND c.created_at::date <= ($2 + interval ''1 month - 1 day'')::date ELSE c.created_at::date <= ($2 + interval ''1 month - 1 day'')::date END';
    
havings := 'HAVING 1=1';

FOR ranking IN SELECT type, days, bets FROM rankings_settings WHERE type = $1 
LOOP 
  q := q || ' LEFT JOIN rankings_settings rs on rs.type = $1';
  q := q || ' LEFT JOIN clusters c_' || ranking.days || ' ON c_' || ranking.days || '.id = c.id AND CASE WHEN ' || ranking.days || ' > 0 THEN c_' || ranking.days || '.created_at::date >= (($2 + interval ''1 month - 1 day'')::date - ''1 day''::interval day * ' || ranking.days::double precision || ') ELSE 1=1 END';
  havings := havings || ' AND count(c_' || ranking.days || '.id) >=' || ranking.bets;
END LOOP;

q := q || ' WHERE 1=1 GROUP BY u_1.id, rs.admin ' || havings;

FOR rec IN EXECUTE q USING _type, _month
LOOP
  INSERT INTO results(id, nickname, avatar, verified, bet_count, roi, admin) VALUES
  (rec.id, rec.nickname, rec.avatar, rec.verified, rec.bet_count, rec.roi, rec.admin);
END LOOP;

RETURN QUERY
EXECUTE 'SELECT row_number() OVER (ORDER BY q.roi DESC) AS rank, q.id, q.nickname, q.avatar, q.verified, q.bet_count, q.roi, q.admin, null as reward FROM results q WHERE q.roi IS NOT NULL' USING _type, _month ;

DROP TABLE IF EXISTS results;
END $BODY$;