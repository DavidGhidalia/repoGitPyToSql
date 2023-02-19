-- View: public.v_perf_sports_evo

DROP VIEW IF EXISTS public.v_perf_sports_evo cascade;

CREATE OR REPLACE VIEW public.v_perf_sports_evo
 AS
 SELECT d.owner,
    d.sport_id,
    d.date,
    d.period,
    q.p_wins,
    q.p_losses
   FROM ( SELECT date.date::date AS date,
            to_char(date.date, 'FMMonth YYYY'::text) AS period,
            s.id AS sport_id,
            p.user_id AS owner
           FROM generate_series(( 
            SELECT date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '11 mons'::interval), ( 
              SELECT date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) AS date_trunc), 
              '1 mon'::interval) date(date),
            sports s,
            performances p
          ORDER BY p.user_id, s.id, (date.date::date)) d
     LEFT JOIN ( SELECT c.owner,
                        s.id AS sport_id,
                        sq.date,
                        to_char(sq.date::timestamp with time zone, 'FMMonth YYYY'::text) AS period,
			                  count(DISTINCT p.id) FILTER (where p.win) AS p_wins,
			                  count(DISTINCT p.id) FILTER (where not p.win) AS p_losses
                  FROM (SELECT u.id, date_trunc('month', q.date) AS date
                        FROM users u, 
                          (select generate_series(
                                  current_date - interval '11 mons',
                                  current_date,
                                  '1 month'
                                )::date AS date) q
                        ) sq
		              LEFT JOIN clusters c ON c.created_at::date >= sq.date 
                  AND c.created_at < sq.date + interval '1 mon'
                  LEFT JOIN prognosis p ON p.cluster = c.id AND p.win IS NOT NULL
                  LEFT JOIN sports s ON s.id = p.sport
                  GROUP BY c.owner, s.id, sq.date
                  ORDER BY c.owner, s.id, sq.date) q 
                  USING (owner, sport_id, date)
      ORDER BY d.owner, d.sport_id, d.date;