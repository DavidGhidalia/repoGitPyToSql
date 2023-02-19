-- View: public.v_perfect_soccer_stats

DROP VIEW IF EXISTS public.v_perfect_soccer_stats;

CREATE OR REPLACE VIEW public.v_perfect_soccer_stats
 AS
 SELECT r.beegame_id,
    b.name,
    b.subtitle,
    b.private,
    array_length(b.users, 1) AS nb_users,
    array_length(array_agg(DISTINCT r.users_pronos), 1) AS nb_users_with_pronos,
    avg(r.nb_pronos) AS nb_pronos_avg,
    ( SELECT jsonb_agg(jsonb_build_object('id', bm.match_id, 'date', bm.match_date, 'sport', bm.sport, 'teams', bm.teams, 'tournament', bm.tournament, 'result', bm.result, 'result_live', bm.result_live, 'status', bm.status, 'match_status', bm.match_status, 'played', bm.played) ORDER BY bm.sport, bm.match_date) AS jsonb_agg
           FROM v_beegames_matches bm
          WHERE bm.id = r.beegame_id) AS matches,
    ( SELECT count(*) AS count
           FROM v_beegames_matches bm
          WHERE bm.id = r.beegame_id AND bm.played = false) AS nb_matches_without_pronos
   FROM ( SELECT bt.beegame_id,
            bp.ticket_id,
            array_agg(DISTINCT bt.user_id) AS users_pronos,
            count(bp.id) AS nb_pronos
           FROM beegames_tickets bt
             JOIN beegames_prognosis bp ON bt.id = bp.ticket_id
          GROUP BY bt.beegame_id, bp.ticket_id) r
     JOIN beegames b ON b.id = r.beegame_id AND b.type_id = 2 AND b.sport_id = 1
  GROUP BY r.beegame_id, b.name, b.subtitle, b.private, (array_length(b.users, 1))
  ORDER BY (array_length(b.users, 1)) DESC;