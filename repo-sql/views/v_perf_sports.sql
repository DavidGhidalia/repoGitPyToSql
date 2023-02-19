-- View: public.v_perf_sports

DROP VIEW IF EXISTS public.v_perf_sports;

CREATE OR REPLACE VIEW public.v_perf_sports
 AS
 SELECT s.id,
    s.name,
    s.short_name,
    s.slug,
    s.active,
    s.sr_id,
    s.market,
    s.sportradar,
    s.label_point,
    s.ball_icon_url,
    u.id AS user_id,
    json_build_object('nb_prognosis', count(DISTINCT p_sport.id), 'nb_prognosis_monthly', count(DISTINCT p_sport_monthly.id), 'nb_prognosis_monthly_evo', COALESCE((count(DISTINCT p_sport_monthly.id) - count(DISTINCT p_sport_monthly_prev.id))::numeric / NULLIF(count(DISTINCT p_sport_monthly_prev.id), 0)::numeric, 0::numeric), 'nb_prognosis_weekly', count(DISTINCT p_sport_weekly.id), 'nb_prognosis_weekly_evo', COALESCE((count(DISTINCT p_sport_weekly.id) - count(DISTINCT p_sport_weekly_prev.id))::numeric / NULLIF(count(DISTINCT p_sport_weekly_prev.id), 0)::numeric, 0::numeric), 'perf_wins_evolution', ARRAY( SELECT count(DISTINCT p.id) AS count
           FROM generate_series(date_trunc('month'::text, CURRENT_DATE - '11 mons'::interval), CURRENT_DATE::timestamp without time zone, '1 mon'::interval) month(month)
             LEFT JOIN clusters c ON c.owner = u.id AND c.created_at >= month.month AND c.created_at::date <= (month.month + '1 mon -1 days'::interval)::date
             LEFT JOIN prognosis p ON p.cluster = c.id AND p.sport = s.id AND p.win
          GROUP BY month.month), 'perf_losses_evolution', ARRAY( SELECT count(DISTINCT p.id) AS count
           FROM generate_series(date_trunc('month'::text, CURRENT_DATE - '11 mons'::interval), CURRENT_DATE::timestamp without time zone, '1 mon'::interval) month(month)
             LEFT JOIN clusters c ON c.owner = u.id AND c.created_at >= month.month AND c.created_at::date <= (month.month + '1 mon -1 days'::interval)::date
             LEFT JOIN prognosis p ON p.cluster = c.id AND p.sport = s.id AND p.win = false
          GROUP BY month.month), 'perf_evolution_labels', ARRAY( SELECT to_char(generate_series(date_trunc('month'::text, CURRENT_DATE - '11 mons'::interval), CURRENT_DATE::timestamp without time zone, '1 mon'::interval), 'FMMonth YYYY'::text) AS to_char), 'global_success_rate', count(DISTINCT p_won.id)::numeric / NULLIF(count(p_win.id), 0)::numeric, 'annual_success_rate', count(DISTINCT p_won_annual.id)::numeric / NULLIF(count(p_win_annual.id), 0)::numeric, 'monthly_success_rate', count(DISTINCT p_won_monthly.id)::numeric / NULLIF(count(p_win_monthly.id), 0::numeric), 'weekly_success_rate', count(DISTINCT p_won_weekly.id)::numeric / NULLIF(count(p_win_weekly.id), 0), 'sport_frequency', COALESCE(count(DISTINCT p_sport.id)::numeric / NULLIF(( SELECT count(DISTINCT p.id) AS count
           FROM prognosis p
             JOIN clusters c ON c.id = p.cluster
          WHERE c.owner = u.id), 0)::numeric, 0::numeric), 'average_stake', COALESCE(percentile_cont(0.5::double precision) WITHIN GROUP (ORDER BY (c_sport.stake::double precision)), 0::double precision), 'smallest_odds', min((p_won_odds.content ->> 'odd'::text)::double precision), 'smallest_odds_cluster', (SELECT p.cluster FROM ( SELECT min((p_won_odds.content ->> 'odd'::text)::double precision) as min ) q JOIN clusters c ON c.owner = u.id JOIN prognosis p ON p.cluster = c.id AND p.sport = s.id AND (p.content->>'odd')::double precision = q.min AND p.win ORDER BY p.created_at DESC LIMIT 1), 'biggest_odds', max((p_won_odds.content ->> 'odd'::text)::double precision), 'biggest_odds_cluster', (SELECT p.cluster FROM ( SELECT max((p_won_odds.content ->> 'odd'::text)::double precision) as max ) q JOIN clusters c ON c.owner = u.id JOIN prognosis p ON p.cluster = c.id AND p.sport = s.id AND (p.content->>'odd')::double precision = q.max AND p.win ORDER BY p.created_at DESC LIMIT 1), 'average_odds', avg((p_won_odds.content ->> 'odd'::text)::double precision), 'median_odds', percentile_cont(0.5::double precision) WITHIN GROUP (ORDER BY ((p_won_odds.content ->> 'odd'::text)::double precision)), 'median_odds_cluster', ( SELECT p.cluster FROM ( SELECT percentile_cont(0.5::double precision) WITHIN GROUP (ORDER BY ((p_won_odds.content ->> 'odd'::text)::double precision)) as median ) q JOIN clusters c ON c.owner = u.id JOIN prognosis p ON p.cluster = c.id AND p.sport = s.id AND (p.content->>'odd')::double precision >= q.median AND p.win ORDER BY abs(q.median - (p.content->>'odd')::double precision), p.created_at DESC LIMIT 1)) AS sport_stats
   FROM sports s
     CROSS JOIN users u
     JOIN clusters c_sport ON c_sport.owner = u.id
     JOIN prognosis p_sport ON p_sport.cluster = c_sport.id AND p_sport.sport = s.id
     LEFT JOIN prognosis p_sport_monthly ON p_sport_monthly.id = p_sport.id AND p_sport_monthly.created_at >= date_trunc('month'::text, CURRENT_DATE::timestamp with time zone)
     LEFT JOIN prognosis p_sport_monthly_prev ON p_sport_monthly_prev.id = p_sport.id AND p_sport_monthly_prev.created_at >= date_trunc('month'::text, CURRENT_DATE - '30 days'::interval) AND p_sport_monthly_prev.created_at < date_trunc('month'::text, CURRENT_TIMESTAMP)
     LEFT JOIN prognosis p_sport_weekly ON p_sport_weekly.id = p_sport.id AND p_sport_weekly.created_at >= date_trunc('week'::text, CURRENT_DATE::timestamp with time zone)
     LEFT JOIN prognosis p_sport_weekly_prev ON p_sport_weekly_prev.id = p_sport.id AND p_sport_weekly_prev.created_at >= date_trunc('week'::text, CURRENT_DATE - '7 days'::interval) AND p_sport_weekly_prev.created_at < date_trunc('week'::text, CURRENT_DATE::timestamp with time zone)
     LEFT JOIN prognosis p_win ON p_win.id = p_sport.id AND p_win.win IS NOT NULL
     LEFT JOIN prognosis p_win_annual ON p_win_annual.id = p_win.id AND date_part('year'::text, p_win_annual.created_at) = date_part('year'::text, CURRENT_DATE)
     LEFT JOIN prognosis p_win_monthly ON p_win_monthly.id = p_sport_monthly.id AND p_win_monthly.win IS NOT NULL
     LEFT JOIN prognosis p_win_weekly ON p_win_weekly.id = p_sport_weekly.id AND p_win_weekly.win IS NOT NULL
     LEFT JOIN prognosis p_won ON p_won.id = p_win.id AND p_won.win
     LEFT JOIN prognosis p_won_annual ON p_won_annual.id = p_win_annual.id AND p_won_annual.win
     LEFT JOIN prognosis p_won_monthly ON p_won_monthly.id = p_win_monthly.id AND p_won_monthly.win
     LEFT JOIN prognosis p_won_weekly ON p_won_weekly.id = p_win_weekly.id AND p_won_weekly.win
     LEFT JOIN prognosis p_won_odds ON p_won_odds.id = p_won.id AND ((p_won_odds.content ->> 'odd'::text)::double precision) > 1::double precision
  GROUP BY s.id, u.id;
