-- View: public.v_beegame_tickets

DROP VIEW IF EXISTS public.v_beegame_tickets;

CREATE OR REPLACE VIEW public.v_beegame_tickets
 AS
 SELECT bt.id,
    bt.beegame_id,
    bt.user_id,
    bt.bookmaker_id,
    bt.odds_value,
    bt.win,
    bt.win_beegame,
    bt.hash,
    bt.num_ticket,
    bt.created_at,
    bt.updated_at,
    bt.status,
    json_build_object('bookmaker', json_build_object('id', bk.id, 'name', bk.name, 'slug', 
    bk.slug, 'url', bk.url, 'created_at', bk.created_at, 'updated_at', bk.updated_at, 'country', 
    bk.country, 'top', bk.top, 'bonus', bk.bonus, 'currency', bk.currency, 'interest', bk.interest, 
    'odds_interest', bk.odds_interest, 'infos', bk.infos, 'active', bk.active, 'parent_id', bk.parent_id), 
    'oddsValue', bt.odds_value) AS content,
    count(bp.id) AS nb_prognosis,
    row_number() OVER (PARTITION BY bt.beegame_id ORDER BY (
        CASE
            WHEN bt.win THEN 1
            WHEN bt.win IS NULL THEN 2
            ELSE 3
        END), (max(bt.odds_value)) DESC, bt.created_at) AS "position",
    q.tickets_played,
    json_agg(json_build_object('id', bp.id, 'ticket', bp.ticket_id, 'sport', bp.sport_id, 'content', 
    bp.content, 'win', bp.win, 'type_id', bp.type_id, 'created_at', bp.created_at, 'updated_at', bp.updated_at, 
    'match', json_build_object('id', m.id, 'date', m.date, 'round', m.round, 'result', m.result, 'sport', 
    row_to_json(s.*), 'teams', 
    ( SELECT json_agg(te.* 
    ORDER BY (
                CASE
                    WHEN m.home_team = te.id THEN 0
                    ELSE 1
                END)) AS json_agg
           FROM v_teams te
          WHERE te.id = ANY (m.teams)), 'category', row_to_json(c.*), 'tournament', row_to_json(t.*), 
          'home_team', m.home_team, 'status', m.status, 'created_at', m.created_at, 'updated_at', 
          m.updated_at))) AS prognosis
   FROM beegames_tickets bt
     JOIN beegames_prognosis bp ON bp.ticket_id = bt.id
     JOIN matches m ON m.id = bp.match_id
     JOIN sports s ON s.id = m.sport
     JOIN categories c ON c.id = m.category
     JOIN tournaments t ON t.id = m.tournament
     JOIN v_bookmakers bk ON bk.id = bt.bookmaker_id
     LEFT JOIN ( SELECT bt_1.beegame_id,
            count(bt_1.id) AS tickets_played
           FROM beegames_tickets bt_1
          GROUP BY bt_1.beegame_id) q ON q.beegame_id = bt.beegame_id
  GROUP BY bt.id, 
           bk.id, 
           bk.name, 
           bk.slug, 
           bk.url, 
           bk.created_at, 
           bk.updated_at, 
           bk.country, 
           bk.top, 
           bk.bonus, 
           bk.currency, 
           bk.interest, 
           bk.odds_interest, 
           bk.infos, 
           bk.active, 
           bk.parent_id, 
           q.tickets_played;