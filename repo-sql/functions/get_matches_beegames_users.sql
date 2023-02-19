-- FUNCTION: public.get_matches_beegames_users(integer, integer, lang)

DROP FUNCTION IF EXISTS public.get_matches_beegames_users(integer, integer[], character varying[], boolean, 
                        integer, lang, integer, integer) cascade;

CREATE OR REPLACE FUNCTION public.get_matches_beegames_users(
  _beegame integer,
  _matches integer[] default null,
  _status character varying[] default '{}',
  _played boolean default false,
  _user integer default null,
	_lang lang default 'fr',
  _limit integer default 100,
  _offset integer default 0
  ) RETURNS TABLE(
    id integer,
    date timestamp with time zone,
	  sport integer,
    round integer,
	  tournament jsonb,
    tournament_round jsonb,
	  teams json,
    status match_status,
    status_label varchar,
    match_status match_match_status,
    match_status_label varchar,
    winner_id integer,
    status_code character varying,
    result jsonb,
    result_live jsonb,
    played boolean,
    weight_winner integer,
    weight_perfect integer,
	  markets json,
    prognosis json,
    channel jsonb
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY

SELECT markets.match AS id,
    markets.date,
    markets.sport,
    markets.round,
    markets.tournament,
    markets.tournament_round,
    ( SELECT json_agg(t.* 
    ORDER BY CASE WHEN t.id = markets.home_team 
    THEN 0 
    ELSE 1 
    END) 
    AS json_agg
           FROM v_teams t
          WHERE t.id = ANY (markets.teams)) AS teams,
    markets.status,
    markets.status_label,
    markets.match_status,
    markets.match_status_label,
    markets.winner_id,
    ms.code AS status_code,
    markets.result,
    markets.result_live,
    markets.played,
    markets.weight_winner,
    markets.weight_perfect,
    markets.markets,
    ( SELECT coalesce(json_agg(q.* 
    ORDER BY q.created_at), '[]') 
    AS json_agg
      FROM (
        SELECT bp.*, coalesce(json_agg(row_to_json(bb.*)) 
        FILTER (WHERE bb.id IS NOT NULL), '[]') 
        AS bonuses
        FROM beegames_prognosis bp
        JOIN beegames_tickets bt ON bt.id = bp.ticket_id AND bt.beegame_id = _beegame AND bt.user_id = _user
        LEFT JOIN beegames_bonuses bb ON bb.id = any(bp.bonuses) AND bb.active
        WHERE bp.match_id = markets.match
        GROUP BY bp.id
      ) q
    ) AS prognosis,
    get_channel(markets.match, 'FRA') AS channel
   FROM ( SELECT mk.match,
            mk.date,
            mk.sport,
            mk.round,
            mk.tournament,
            mk.tournament_round,
            mk.teams,
            mk.home_team,
            mk.status,
            mk.status_label,
            mk.match_status,
            mk.match_status_label,
            mk.winner_id,
		 	mk.result,
		 	mk.result_live,
       mk.played,
       mk.weight_winner,
       mk.weight_perfect,
            json_agg(mk.*) AS markets
           FROM (SELECT o.match,
    o.date,
    o.active,
    o.sport,
    o.round,
    o.tournament,
    o.tournament_round,
    o.teams,
    o.home_team,
    o.status,
    o.status_label,
    o.match_status,
    o.match_status_label,
    o.winner_id,
    o.name,
    o.group_name,
    o.lang,
    o.result,
    o.result_live,
    o.weight_winner,
    o.weight_perfect,
    o.played,
    CASE WHEN o.sport <> 99 
    THEN json_agg(o.odds) 
    ELSE '[]' 
    END 
    AS odds
   FROM ( SELECT m_1.match,
                    m_1.date,
                    m_1.sport,
                    m_1.round,
                    m_1.tournament,
                    m_1.tournament_round,
                    m_1.teams,
                    m_1.home_team,
                    m_1.status,
                    m_1.status_label,
                    m_1.match_status,
                    m_1.match_status_label,
                    m_1.winner_id,
                    m_1.name,
                    m_1.group_name,
                    m_1.market_id,
                    m_1.field_id,
                    m_1.type_id,
                    m_1.active,
                    m_1.lang,
                    m_1.result,
                    m_1.result_live,
                    CASE WHEN bw.weight_winner IS NOT NULL 
                    THEN bw.weight_winner 
                    ELSE q.default_weight_winner 
                    END AS weight_winner,
                    CASE WHEN bw.weight_perfect IS NOT NULL 
                    THEN bw.weight_perfect 
                    ELSE q.default_weight_perfect 
                    END AS weight_perfect,
                    pl.played,
                    json_build_object('type_id', m_1.type_id, 'field_id', m_1.field_id, 'field_name',
                     m_1.field_name, 'field_label', m_1.field_label, 'hANDicap', m_1.hANDicap, 
                     'probability', m_1.probability, 'best_odd', m_1.odd, 'best_points_winner',
                      coalesce(bp.points_winner, 0), 'best_points_perfect', coalesce(bp.points_perfect, 0), 
                      'typekey', m_1.typekey, 'type_label', m_1.type_label, 'winner', m_1.winner, 
                      'bookmaker', m_1.bookmaker, 'top_player', m_1.top_player, 'prognosis_rate',
                       m_1.prognosis_rate, 'played', pl.played_type) AS odds
                   FROM (
                    SELECT b.id, 
                    b.type_id, 
                    b.sport_id, 
                    bts.markets, 
                    bt.default_weight_winner, 
                    bt.default_weight_perfect, 
                    bt.bookmaker_id, 
                    array_agg(distinct bp.match_id) AS matches
                    FROM beegames b
                    JOIN beegames_types bt ON bt.id = b.type_id
                    LEFT JOIN beegames_types_sports bts ON bts.type_id = bt.id AND bts.sport_id = b.sport_id
                    JOIN beegames_tickets btk ON btk.beegame_id = b.id AND btk.user_id = _user
                    JOIN beegames_prognosis bp ON bp.ticket_id = btk.id AND bp.win
                    JOIN matches m ON m.id = bp.match_id
                    JOIN jsonb_array_elements(m.result->'Score') s ON s->>'type' = 'FT' 
                    AND (s->>'retired')::boolean = false 
                    AND (s->>'canceled')::boolean = false 
                    AND (s->>'walkover')::boolean = false 
                    AND (s->>'postponed')::boolean = false
                    WHERE b.id = _beegame
                    GROUP BY b.id, bt.id, bts.markets
                   ) q
                    JOIN get_matches_odds(_matches => q.matches, _sport => q.sport_id, _markets => q.markets,
                     _codes => _status, _bookmakers => ARRAY[q.bookmaker_id], _lang => _lang, _limit => _limit, 
                     _offset => _offset) m_1 ON m_1.match IS NOT NULL
                    LEFT JOIN beegames_weights bw ON bw.type_id = q.type_id 
                    AND bw.tournament_round::text = (m_1.tournament_round->>'name')::text
					          LEFT JOIN beegames_points bp ON bp.type_id = q.type_id AND bp.match_id = m_1.match 
                    AND bp.odds_type_id = m_1.type_id
                    LEFT JOIN get_beegames_played(q.id, m_1.match, m_1.type_id, _user) pl ON pl.id = m_1.match
                    WHERE pl.played
                   ) o
  GROUP BY o.match, o.date, o.active, o.sport, o.round, o.tournament, o.tournament_round, o.teams, o.home_team,
   o.name, o.lang, o.status, o.status_label, o.match_status, o.match_status_label, o.winner_id, o.group_name, 
   o.result, o.result_live, o.weight_winner, o.weight_perfect, o.played, o.weight_winner, o.weight_perfect) mk
          GROUP BY mk.match, mk.date, mk.sport, mk.round, mk.tournament, mk.tournament_round, mk.teams, 
          mk.home_team, mk.status, mk.status_label, mk.match_status, mk.match_status_label, mk.winner_id, 
          mk.result, mk.result_live, mk.played, mk.weight_winner, mk.weight_perfect
          ORDER BY mk.date ASC) markets
          JOIN matches_status ms ON ms.status = markets.status AND ms.active
  ORDER BY markets.date ASC;

END $BODY$;