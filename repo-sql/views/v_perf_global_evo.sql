-- View: public.v_perf_global_evo

DROP VIEW IF EXISTS public.v_perf_global_evo;

CREATE OR REPLACE VIEW public.v_perf_global_evo
 AS
 SELECT d.user_id,
    array_agg(COALESCE(t.roi, 0::numeric)) AS roi,
    array_agg(COALESCE(t.roc, 0::numeric)) AS roc,
    array_agg(d.period) AS periods
   FROM ( SELECT date.date::date AS date,
            format_month(date.date) AS period,
            p.user_id
           FROM generate_series(( 
            SELECT date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '11 mons'::interval), ( 
               SELECT date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) AS date_trunc), 
               '1 mon'::interval) date(date),
            performances p) d
     LEFT JOIN ( SELECT v.user_id,
            v.date,
            v.period,
            v.roi,
            v.roc
           FROM ( SELECT q.user_id,
                    q.date,
                    q.period,
                    q.roi,
                    q.roc
                   FROM ( SELECT ph.user_id,
                            make_date(ph.year, ph.month, 1) AS date,
                            format_month(make_date(ph.year, ph.month, 1)::timestamp with time zone) AS period,
                            ph.roi,
                            ph.monthly_roc AS roc
                           FROM performances_history ph
                          WHERE make_date(ph.year, ph.month, 1) >= (( 
                           SELECT date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) - '11 mons'::interval)) 
                           AND make_date(ph.year, ph.month, 1) < (( 
                              SELECT date_trunc('month'::text, CURRENT_DATE::timestamp with time zone) AS date_trunc))
                          GROUP BY ph.year, ph.month, ph.user_id, ph.roi, ph.monthly_roc
                        UNION
                         SELECT p.user_id,
                            date_trunc('month'::text, now())::date AS day,
                            format_month(now()) AS period,
                            p.roi,
                            p.monthly_roc AS roc
                           FROM performances p
                  ORDER BY 1, 2) q) v) t USING (user_id, date)
  GROUP BY d.user_id;