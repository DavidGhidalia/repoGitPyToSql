-- View: public.v_beegame

 DROP VIEW IF EXISTS public.v_beegame;

CREATE OR REPLACE VIEW public.v_beegame
 AS
 SELECT b.id,
    b.name,
    b.date_start,
    b.date_end,
    b.prize,
    b.sponsor,
    b.description,
    b.logo,
    b.winner_id,
    b.pending_results,
    b.notified_users,
    ( SELECT jsonb_agg(q.* ORDER BY ((q.tournament ->> 'order'::text)::integer), q.date) AS jsonb_agg
           FROM ( SELECT m_1.id,
                    m_1.date,
                    m_1.result,
                    row_to_json(s_1.*) AS sport,
                    json_agg(t.* ORDER BY (
                        CASE
                            WHEN t.id = m_1.home_team THEN 0
                            ELSE 1
                        END)) AS teams,
                    row_to_json(tr.*) AS tournament,
                    row_to_json(c_1.*) AS category
                   FROM matches m_1
                     JOIN teams t ON t.id = ANY (m_1.teams)
                     JOIN tournaments tr ON tr.id = m_1.tournament
                     JOIN categories c_1 ON c_1.id = m_1.category
                     JOIN sports s_1 ON s_1.id = m_1.sport
                  WHERE m_1.date 
                  BETWEEN b.date_start AND b.date_end 
                  AND CASE WHEN b.matches <> '{}' 
                  THEN m_1.id = any(b.matches) 
                  ELSE 1=1 end AND CASE WHEN b.sport_id IS NOT NULL 
                  THEN m_1.sport = b.sport_id 
                  ELSE 1=1 
                  END 
                  AND CASE WHEN b.tournaments <> '{}' 
                  THEN m_1.tournament = any(b.tournaments) 
                  ELSE 1=1 END
                  GROUP BY m_1.id, s_1.id, tr.id, c_1.id) q) AS matches,
    ( SELECT jsonb_agg
    (DISTINCT jsonb_build_object('id', t.id, 'name', t.name, 'category', row_to_json(c_1.*), 
    'winner', row_to_json(te.*))) AS jsonb_agg
           FROM tournaments t
             LEFT JOIN categories c_1 ON c_1.id = t.category
             LEFT JOIN seasons s_1 ON s_1.tournament = t.id 
             AND s_1.end_date >= b.date_start::date AND s_1.end_date <= b.date_end::date
             LEFT JOIN teams te ON te.id = s_1.winner_id
          WHERE t.id = ANY (b.tournaments)) AS tournaments,
    b.type_id,
    b.sport_id,
    b.contest_id,
    b.match_id,
    b.room_id,
    b.round,
    b.tournament_round,
    b.tournament_name,
    b.tutorial_description,
    b.tutorial_results,
    b.background_url,
    b.beecoins_fee,
    b.beecoins_prize,
    b.transactions,
    b.users,
    b.subtitle,
    b.code,
    b.private,
    b.priority,
    b.deep_link,
    b.top,
    b.background_url_top,
    b.mix,
    b.major,
    b.status,
    b.visible,
    b.created_at,
    b.updated_at,
    bt.name AS type_name,
    bt.slug,
    bt.default_weight_winner,
    bt.default_weight_perfect,
    bt.days_start,
    bt.days_ago,
    json_build_object('id', bt.id, 'name', bt.name, 'slug', bt.slug, 'logo', bt.logo, 
    'bookmaker_id', bt.bookmaker_id, 'days_start', bt.days_start, 'days_ago', bt.days_ago, 
    'tickets_consumption', bt.tickets_consumption, 'background_url', bt.background_url, 
    'default_weight_winner', bt.default_weight_winner, 'default_weight_perfect', bt.default_weight_perfect, 
    'entry_fee', bt.entry_fee, 'ticket_fee', bt.ticket_fee, 'active', bt.active, 'description', bt.description, 
    'label', bts.label) AS type,
    row_to_json(c.*) AS contest,
    row_to_json(m.*) AS match,
    row_to_json(r.*) AS room,
    row_to_json(sp.*) AS sport,
    json_build_object('id', u.id, 'nickname', u.nickname, 'avatar', u.avatar, 'verified', 
    u.verified, 'vip', u.vip) AS owner,
    json_build_object('odd_min', min(r1.odds_value), 'odd_max', max(r1.odds_value), 'odd_avg', 
    avg(r1.odds_value)::numeric(36,2), 'odd_median', percentile_cont(0.5::double precision) 
    WITHIN GROUP (ORDER BY (r1.odds_value::double precision))::numeric(36,2), 'current_tickets', 
    count(r1.id), 'participants', count(DISTINCT r1.user_id), 'avg_ticket_prognosis', 
    avg(r1.ticket_prognosis)::numeric(36,2)) AS stats,
    bms.timer_status,
    bms.timer_date
   FROM beegames b
     LEFT JOIN beegames_types bt ON bt.id = b.type_id
     LEFT JOIN beegames_types_sports bts ON bts.type_id = bt.id AND bts.sport_id = b.sport_id
     LEFT JOIN contest c ON c.id = b.contest_id
     LEFT JOIN matches m ON m.id = b.match_id
     LEFT JOIN rooms r ON r.id = b.room_id
     LEFT JOIN seasons s ON s.tournament = ANY (b.tournaments)
     LEFT JOIN sports sp ON sp.id = b.sport_id
     LEFT JOIN users u ON u.id = b.owner
     LEFT JOIN ( SELECT bt_1.id,
            bt_1.beegame_id,
            bt_1.user_id,
            bt_1.odds_value,
            count(bp.id) AS ticket_prognosis
           FROM beegames_tickets bt_1
             LEFT JOIN beegames_prognosis bp ON bp.ticket_id = bt_1.id
          WHERE bt_1.odds_value > 1::numeric
          GROUP BY bt_1.id) r1 ON r1.beegame_id = b.id
      LEFT JOIN get_beegames_matches_status(b.id) bms ON bms.id = b.id
  GROUP BY b.id, 
           bt.id, 
           bts.type_id, 
           bts.sport_id, 
           c.id, 
           m.id, 
           r.id, 
           sp.id, 
           u.id, 
           bms.timer_status, 
           bms.timer_date;