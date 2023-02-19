-- View: public.v_perf

DROP VIEW IF EXISTS public.v_perf;

CREATE OR REPLACE VIEW public.v_perf
 AS
 SELECT performances.id,
    performances.user_id,
    performances.general_rank,
    performances.monthly_rank,
    performances.success_rate::double precision AS success_rate,
    performances.popularity,
    performances.comments,
    performances.roi::double precision AS roi,
    (( SELECT (q1.roi - q2.roi_prev) /
                CASE
                    WHEN q2.roi_prev = 0::numeric THEN 1::numeric
                    ELSE abs(q2.roi_prev)
                END AS roi_evo
           FROM ( SELECT p.roi
                   FROM performances p
                  WHERE p.user_id = performances.user_id) q1,
            ( SELECT u.id,
                    COALESCE(t.roi, 0::numeric) AS roi_prev
                   FROM users u
                     LEFT JOIN ( SELECT c_1.owner,
                            sum((c_1.odds_value *
                                CASE
                                    WHEN c_1.win THEN 1
                                    ELSE 0
                                END::numeric - 1::numeric) * c_1.stake::numeric) / sum(c_1.stake)::numeric AS roi
                           FROM clusters c_1
                          WHERE c_1.win IS NOT NULL AND c_1.status IS DISTINCT FROM 'cancelled'::cluster_status AND c_1.created_at < date_trunc('week'::text, CURRENT_DATE::timestamp with time zone)
                          GROUP BY c_1.owner) t ON t.owner = u.id
                  WHERE u.id = performances.user_id) q2))::double precision AS roi_evo,
    performances.roi_30::double precision AS roi_30,
    (( SELECT (q1.roi_30 - q2.roi_30_prev) /
                CASE
                    WHEN q2.roi_30_prev = 0::numeric THEN 1::numeric
                    ELSE abs(q2.roi_30_prev)
                END AS roi_30_evo
           FROM ( SELECT p.roi_30
                   FROM performances p
                  WHERE p.user_id = performances.user_id) q1,
            ( SELECT u.id,
                    COALESCE(t.roi_30, 0::numeric) AS roi_30_prev
                   FROM users u
                     LEFT JOIN ( SELECT c_1.owner,
                            sum((c_1.odds_value *
                                CASE
                                    WHEN c_1.win THEN 1
                                    ELSE 0
                                END::numeric - 1::numeric) * c_1.stake::numeric) / sum(c_1.stake)::numeric AS roi_30
                           FROM clusters c_1
                          WHERE c_1.win IS NOT NULL AND c_1.status IS DISTINCT FROM 'cancelled'::cluster_status AND c_1.created_at < date_trunc('week'::text, CURRENT_DATE::timestamp with time zone)
                          GROUP BY c_1.owner) t ON t.owner = u.id
                  WHERE u.id = performances.user_id) q2))::double precision AS roi_30_evo,
    performances.monthly_roi::double precision AS monthly_roi,
    (( SELECT (q1.monthly_roi - q2.monthly_roi_prev) /
                CASE
                    WHEN q2.monthly_roi_prev = 0::numeric THEN 1::numeric
                    ELSE abs(q2.monthly_roi_prev)
                END AS monthly_roi_evo
           FROM ( SELECT p.monthly_roi
                   FROM performances p
                  WHERE p.user_id = performances.user_id) q1,
            ( SELECT u.id,
                    COALESCE(t.roi_monthly, 0::numeric) AS monthly_roi_prev
                   FROM users u
                     LEFT JOIN ( SELECT c_1.owner,
                            sum((c_1.odds_value *
                                CASE
                                    WHEN c_1.win THEN 1
                                    ELSE 0
                                END::numeric - 1::numeric) * c_1.stake::numeric) / sum(c_1.stake)::numeric AS roi_monthly
                           FROM clusters c_1
                          WHERE c_1.win IS NOT NULL AND c_1.status IS DISTINCT FROM 'cancelled'::cluster_status AND c_1.created_at >= date_trunc('month'::text, CURRENT_DATE - '1 mon'::interval month) AND c_1.created_at < date_trunc('month'::text, CURRENT_DATE::timestamp with time zone)
                          GROUP BY c_1.owner) t ON t.owner = u.id
                  WHERE u.id = performances.user_id) q2))::double precision AS monthly_roi_evo,
    performances.roc::double precision AS roc,
    ( SELECT (performances.roc::double precision - q.roc_prev) /
                CASE
                    WHEN q.roc_prev = 0::numeric::double precision THEN 1::numeric::double precision
                    ELSE abs(q.roc_prev)
                END AS roc_evo
           FROM ( SELECT q_1.id,
                    q_1.stake_profits_prev - q_1.stakes_prev AS roc_prev
                   FROM ( SELECT u.id,
                            COALESCE(sum(c_won.odds_value::double precision * (c_won.stake::double precision / 10::double precision)), 0::double precision) AS stake_profits_prev,
                            COALESCE(sum(c_win.stake::double precision / 10::double precision), 0::double precision) AS stakes_prev
                           FROM users u
                             LEFT JOIN clusters c_win ON c_win.owner = u.id AND c_win.win IS NOT NULL AND c_win.status IS DISTINCT FROM 'cancelled'::cluster_status AND c_win.created_at < date_trunc('week'::text, CURRENT_DATE::timestamp with time zone)
                             LEFT JOIN clusters c_won ON c_won.id = c_win.id AND c_won.win
                          WHERE u.id = performances.user_id
                          GROUP BY u.id) q_1) q) AS roc_evo,
    performances.roc_30::double precision AS roc_30,
    ( SELECT (performances.roc_30::double precision - q.roc_30_prev) /
                CASE
                    WHEN q.roc_30_prev = 0::numeric::double precision THEN 1::numeric::double precision
                    ELSE abs(q.roc_30_prev)
                END AS roc_30_evo
           FROM ( SELECT q_1.id,
                    q_1.stake_profits_prev - q_1.stakes_prev AS roc_30_prev
                   FROM ( SELECT u.id,
                            COALESCE(sum(c_won.odds_value::double precision * (c_won.stake::double precision / 10::double precision)), 0::double precision) AS stake_profits_prev,
                            COALESCE(sum(c_win.stake::double precision / 10::double precision), 0::double precision) AS stakes_prev
                           FROM users u
                             LEFT JOIN clusters c_win ON c_win.owner = u.id AND c_win.win IS NOT NULL AND c_win.status IS DISTINCT FROM 'cancelled'::cluster_status AND c_win.created_at < date_trunc('week'::text, CURRENT_DATE::timestamp with time zone)
                             LEFT JOIN clusters c_won ON c_won.id = c_win.id AND c_won.win
                          WHERE u.id = performances.user_id
                          GROUP BY u.id) q_1) q) AS roc_30_evo,
    performances.monthly_roc::double precision AS monthly_roc,
    ( SELECT (performances.monthly_roc::double precision - q.monthly_roc_prev) /
                CASE
                    WHEN q.monthly_roc_prev = 0::numeric::double precision THEN 1::numeric::double precision
                    ELSE abs(q.monthly_roc_prev)
                END AS monthly_roc_evo
           FROM ( SELECT q_1.id,
                    q_1.stake_profits_prev - q_1.stakes_prev AS monthly_roc_prev
                   FROM ( SELECT u.id,
                            COALESCE(sum(c_won.odds_value::double precision * (c_won.stake::double precision / 10::double precision)), 0::double precision) AS stake_profits_prev,
                            COALESCE(sum(c_win.stake::double precision / 10::double precision), 0::double precision) AS stakes_prev
                           FROM users u
                             LEFT JOIN clusters c_win ON c_win.owner = u.id AND c_win.win IS NOT NULL AND c_win.status IS DISTINCT FROM 'cancelled'::cluster_status AND c_win.created_at >= date_trunc('month'::text, CURRENT_DATE - '1 mon'::interval month) AND c_win.created_at < date_trunc('month'::text, CURRENT_DATE::timestamp with time zone)
                             LEFT JOIN clusters c_won ON c_won.id = c_win.id AND c_won.win
                          WHERE u.id = performances.user_id
                          GROUP BY u.id) q_1) q) AS monthly_roc_evo,
    performances.created_at,
    performances.updated_at,
    performances.prognosis_rate::double precision AS prognosis_rate,
    performances.average_stake::double precision AS average_stake,
    performances.average_odds_won::double precision AS average_odds_won,
    performances.bet_count,
    performances.bet_count_monthly,
    performances.bet_count_weekly,
    vplr.latest_results,
    ( SELECT
                CASE
                    WHEN q.median_odds > 1::numeric AND q.median_odds <= 3::numeric THEN 1
                    WHEN q.median_odds > 3::numeric AND q.median_odds <= 10::numeric THEN 2
                    WHEN q.median_odds > 10::numeric THEN 3
                    ELSE 0
                END AS risk
           FROM ( SELECT percentile_disc(0.5::double precision) WITHIN GROUP (ORDER BY c.odds_value) AS median_odds
                   FROM clusters c
                  WHERE c.owner = performances.user_id
                  AND c.status IS DISTINCT FROM 'cancelled'::cluster_status) q) AS risk,
    (( SELECT count(c.*) AS count
           FROM clusters c
          WHERE c.owner = performances.user_id
          AND c.status IS DISTINCT FROM 'cancelled'::cluster_status))::integer AS nb_prognosis,
    (( SELECT min(clusters.odds_value) AS min
           FROM clusters
          WHERE clusters.owner = performances.user_id AND clusters.status IS DISTINCT FROM 'cancelled'::cluster_status AND clusters.win AND clusters.odds_value::double precision > 1::double precision))::double precision AS smallest_odds,
          (( SELECT c.id
          FROM ( SELECT min(clusters.odds_value) AS min
            FROM clusters
            WHERE clusters.owner = performances.user_id AND clusters.status IS DISTINCT FROM 'cancelled'::cluster_status AND clusters.win AND clusters.odds_value::double precision > 1::double precision 
          ) q
          JOIN clusters c ON c.owner = performances.user_id AND c.odds_value = q.min AND c.win
          ORDER BY c.created_at DESC
          LIMIT 1
        )) AS smallest_odds_cluster,
    (( SELECT percentile_disc(0.5::double precision) WITHIN GROUP (ORDER BY clusters.odds_value) AS median
           FROM clusters
          WHERE clusters.owner = performances.user_id AND clusters.status IS DISTINCT FROM 'cancelled'::cluster_status AND clusters.win AND clusters.odds_value::double precision > 1::double precision))::double precision AS median_odds,
    (( SELECT c.id
          FROM ( SELECT percentile_disc(0.5::double precision) WITHIN GROUP (ORDER BY clusters.odds_value) AS median
            FROM clusters
            WHERE clusters.owner = performances.user_id AND clusters.status IS DISTINCT FROM 'cancelled'::cluster_status AND clusters.win AND clusters.odds_value::double precision > 1::double precision 
          ) q
          JOIN clusters c ON c.owner = performances.user_id AND c.odds_value >= q.median AND c.win
          ORDER BY abs(q.median-c.odds_value), c.created_at DESC
          LIMIT 1
        )) AS median_odds_cluster,
    (( SELECT avg(clusters.odds_value) AS avg
           FROM clusters
          WHERE clusters.owner = performances.user_id AND clusters.status IS DISTINCT FROM 'cancelled'::cluster_status AND clusters.win AND clusters.odds_value::double precision > 1::double precision))::double precision AS average_odds,
    (( SELECT max(clusters.odds_value) AS max
           FROM clusters
          WHERE clusters.owner = performances.user_id AND clusters.status IS DISTINCT FROM 'cancelled'::cluster_status AND clusters.win AND clusters.odds_value::double precision > 1::double precision))::double precision AS biggest_odds,
          (( SELECT c.id
          FROM ( SELECT max(clusters.odds_value) AS max
            FROM clusters
            WHERE clusters.owner = performances.user_id AND clusters.status IS DISTINCT FROM 'cancelled'::cluster_status AND clusters.win AND clusters.odds_value::double precision > 1::double precision 
          ) q
          JOIN clusters c ON c.owner = performances.user_id AND c.odds_value = q.max AND c.win
          ORDER BY c.created_at DESC
          LIMIT 1
        )) AS biggest_odds_cluster,
    ( SELECT q.name AS favorite_sport
           FROM ( SELECT p.sport,
                    s.name,
                    count(p.sport) AS nb_prognosis
                   FROM prognosis p
                     JOIN clusters c ON c.id = p.cluster AND c.status IS DISTINCT FROM 'cancelled'::cluster_status
                     JOIN sports s ON s.id = p.sport
                  WHERE c.owner = performances.user_id
                  AND p.status IS DISTINCT FROM 'cancelled'::prognosis_status
                  GROUP BY p.sport, s.name) q
          ORDER BY q.nb_prognosis DESC
         LIMIT 1) AS favorite_sport,
    (( SELECT count(*) AS count
           FROM clusters c
          WHERE c.status IS DISTINCT FROM 'cancelled'::cluster_status AND c.created_at >= date_trunc('week'::text, CURRENT_DATE::timestamp with time zone) AND c.owner = performances.user_id))::integer AS nb_prognosis_weekly,
    (( SELECT (q1.nb_prognosis - q2.nb_prognosis_prev)::numeric /
                CASE
                    WHEN q2.nb_prognosis_prev::numeric = 0::numeric THEN 1::bigint
                    ELSE q2.nb_prognosis_prev
                END::numeric
           FROM ( SELECT count(*) AS nb_prognosis
                   FROM clusters c
                  WHERE c.status IS DISTINCT FROM 'cancelled'::cluster_status AND c.created_at >= date_trunc('week'::text, CURRENT_DATE::timestamp with time zone) AND c.owner = performances.user_id) q1,
            ( SELECT count(*) AS nb_prognosis_prev
                   FROM clusters c
                  WHERE c.status IS DISTINCT FROM 'cancelled'::cluster_status AND c.created_at >= date_trunc('week'::text, CURRENT_DATE::timestamp with time zone - '7 days'::interval) AND c.created_at < date_trunc('week'::text, CURRENT_TIMESTAMP) AND c.owner = performances.user_id) q2))::double precision AS nb_prognosis_weekly_evo,
    ( SELECT json_agg(q.*) AS sports
           FROM ( SELECT s.id,
                    s.name,
                    s.slug,
                    s.active,
                    s.sr_id,
                    s.market,
                    s.sportradar,
                    s.label_point,
                    s.ball_icon_url,
                    s.short_name,
                    ( SELECT json_build_object('sport_frequency', ( SELECT COALESCE(( SELECT count(p_1.*)::numeric / q_1.total::numeric
   FROM prognosis p_1
     JOIN clusters c_1 ON c_1.id = p_1.cluster AND c_1.status IS DISTINCT FROM 'cancelled'::cluster_status
     JOIN ( SELECT c_1_1.owner,
      count(*) AS total
     FROM prognosis p_1_1
       JOIN clusters c_1_1 ON c_1_1.id = p_1_1.cluster AND c_1_1.status IS DISTINCT FROM 'cancelled'::cluster_status
    WHERE c_1_1.owner = performances.user_id
    AND p_1_1.status IS DISTINCT FROM 'cancelled'::prognosis_status
    GROUP BY c_1_1.owner) q_1 ON q_1.owner = c_1.owner
  WHERE c_1.owner = performances.user_id AND p_1.sport = s.id AND p_1.status IS DISTINCT FROM 'cancelled'::prognosis_status
  GROUP BY q_1.total), 0::numeric) AS "coalesce"), 'global_success_rate', ( SELECT q1.success::numeric /
CASE q2.total
 WHEN 0 THEN 1::bigint
 ELSE q2.total
END::numeric
                                   FROM ( SELECT count(*) AS success
   FROM prognosis p_1
     JOIN clusters c_1 ON c_1.id = p_1.cluster AND c_1.status IS DISTINCT FROM 'cancelled'::cluster_status
  WHERE p_1.win = true AND p_1.sport = s.id AND p_1.status IS DISTINCT FROM 'cancelled'::prognosis_status AND c_1.owner = performances.user_id) q1,
                                    ( SELECT count(*) AS total
   FROM prognosis p_1
     JOIN clusters c_1 ON c_1.id = p_1.cluster AND c_1.status IS DISTINCT FROM 'cancelled'::cluster_status
  WHERE p_1.sport = s.id AND p_1.win IS NOT NULL AND p_1.status IS DISTINCT FROM 'cancelled'::prognosis_status AND c_1.owner = performances.user_id) q2)) AS json_build_object) AS sport_stats
                   FROM sports s
                     JOIN prognosis p ON p.sport = s.id AND p.win IS NOT NULL AND p.status IS DISTINCT FROM 'cancelled'::prognosis_status
                     JOIN clusters c ON c.id = p.cluster AND c.status IS DISTINCT FROM 'cancelled'::cluster_status
                  WHERE c.owner = performances.user_id
                  GROUP BY s.id) q) AS sports,
    ( SELECT json_build_object('user_id', evo.user_id, 'roi', evo.roi, 'roc', evo.roc, 'periods', evo.periods) AS json_build_object
           FROM v_perf_global_evo evo
          WHERE evo.user_id = performances.user_id) AS global_evolutions,
    json_object_agg(ps.code, ps.description) as descriptions
   FROM performances
     LEFT JOIN v_perf_latest_results vplr ON vplr.owner = performances.user_id
     LEFT JOIN performances_settings ps on ps.active
	 GROUP BY performances.id, vplr.latest_results;