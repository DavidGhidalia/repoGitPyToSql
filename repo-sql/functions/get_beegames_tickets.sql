-- FUNCTION: public.get_beegames_tickets(json)

 DROP FUNCTION IF EXISTS public.get_beegames_tickets(integer, integer, lang , integer default null );

CREATE OR REPLACE FUNCTION public.get_beegames_tickets(
	_beegame integer, _user integer, _lang lang default 'fr', _ticket integer default null)
    RETURNS TABLE(id integer, beegame_id integer, user_id integer, bookmaker_id integer, 
    odds_value numeric, win boolean,  win_beegame boolean, hash text, 
    num_ticket bigint, created_at timestamp with time zone,
    updated_at timestamp with time zone, status cluster_status, content json, 
    nb_prognosis bigint, prognosis_win bigint, "position" bigint, tickets_played bigint, 
    date_start timestamptz, date_end timestamptz, beecoins_fee numeric, beecoins_prize numeric, 
    prize integer, contest_id integer, result jsonb, prognosis jsonb)
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
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
    json_build_object('bookmaker', json_build_object('id', bk.id, 'name', bk.name, 'slug', bk.slug,
    'url', bk.url, 'created_at', bk.created_at, 'updated_at', bk.updated_at, 
    'country', bk.country, 'top', bk.top, 'bonus', bk.bonus, 'currency', bk.currency, 
    'interest', bk.interest, 'odds_interest', bk.odds_interest, 'infos', bk.infos, 'active', bk.active,
    'parent_id', bk.parent_id), 'oddsValue', bt.odds_value) AS content,
    count(bp.id) AS nb_prognosis,
    count(bp.id)
    FILTER (where bp.win) AS prognosis_win,
    q1.position,
    q2.tickets_played,
    b.date_start,
    b.date_end,
    b.beecoins_fee,
    b.beecoins_prize,
	  b.prize,
    b.contest_id,
    r.value AS result,
    jsonb_agg(jsonb_build_object('id', bp.id, 'ticket', bp.ticket_id, 'sport', row_to_json(s.*),
    'sport_id', bp.sport_id, 'content', 
    get_label_prognosis(bp.content, bp.sport_id, _lang, t1.name, t2.name, s.label_point),
    'win', bp.win, 'type_id', bp.type_id, 'created_at', bp.created_at, 
    'updated_at', bp.updated_at, 'match', 
    json_build_object('id', m.id, 'date', m.date, 'round', m.round, 'result', m.result, 'sport', row_to_json(s.*), 
    'teams', ( SELECT json_agg(te.* 
              ORDER BY (
                CASE
                    WHEN m.home_team = te.id 
                    THEN 0
                    ELSE 1
                END)) 
                AS json_agg
           FROM v_teams te
          WHERE te.id = ANY (m.teams)), 'category', row_to_json(c.*), 'tournament', row_to_json(t.*), 
          'home_team', m.home_team, 'status', m.status, 'created_at', m.created_at, 
          'updated_at', m.updated_at))) 
          AS prognosis
   FROM beegames_tickets bt
     JOIN beegames_prognosis bp ON bp.ticket_id = bt.id
     JOIN matches m ON m.id = bp.match_id
     JOIN teams t1 ON t1.id = m.home_team
     JOIN teams t2 ON t2.id = ANY(m.teams) AND NOT (t2.id = m.home_team)
     JOIN v_sports_tr s ON s.id = m.sport AND s.lang = _lang
     JOIN categories c ON c.id = m.category
     JOIN tournaments t ON t.id = m.tournament
     JOIN v_bookmakers bk ON bk.id = bt.bookmaker_id
	   JOIN beegames b ON b.id = bt.beegame_id
     LEFT JOIN contest co ON co.id = b.contest_id
     LEFT JOIN jsonb_array_elements(co.results) r ON (r->>'ticket_id')::integer = bt.id
     LEFT JOIN (SELECT bt.id, row_number() OVER (
      ORDER BY (
          CASE
            WHEN bt.win 
            THEN 1
            WHEN bt.win IS NULL 
            THEN 2
            ELSE 3
          END), 
          (max(bt.odds_value)) DESC, bt.created_at) AS "position"
        FROM beegames_tickets bt
        WHERE beegame_id = _beegame
        GROUP BY bt.id) q1 ON q1.id = bt.id
     LEFT JOIN ( SELECT bt_1.beegame_id,
            count(bt_1.id) AS tickets_played
           FROM beegames_tickets bt_1
          GROUP BY bt_1.beegame_id) q2 ON q2.beegame_id = bt.beegame_id
  WHERE b.id = _beegame and bt.user_id = _user AND CASE 
  WHEN _ticket IS NOT NULL 
  THEN bt.id = _ticket 
  ELSE 1=1 
  END
  GROUP BY bt.id, bk.id, bk.name, bk.slug, bk.url, bk.created_at, bk.updated_at, 
  bk.country, bk.top, bk.bonus, bk.currency, bk.interest, bk.odds_interest, bk.infos, 
  bk.active, bk.parent_id, q1.position, q2.tickets_played, b.date_start, b.date_end, b.beecoins_fee, 
  b.beecoins_prize, b.prize, b.contest_id, r.value;
  
$BODY$;