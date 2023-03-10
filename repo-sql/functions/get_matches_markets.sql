-- FUNCTION: public.get_matches_markets(integer, lang)

DROP FUNCTION IF EXISTS public.get_matches_markets(integer, lang) CASCADE;

CREATE OR REPLACE FUNCTION public.get_matches_markets(
  _match integer,
	_lang lang default 'fr'
  ) RETURNS TABLE(
    id integer,
    date timestamp with time zone,
	  sport integer,
	  sport_name varchar,
	  tournament json,
    tournament_round jsonb,
	  teams json,
    status match_status,
    status_label varchar,
    match_status match_match_status,
    match_status_label varchar,
    winner_id integer,
	  markets_number bigint,
	  markets json,
    channel jsonb
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY
 
 SELECT markets.match AS id,
    markets.date,
    markets.sport,
    s.name AS sport_name,
    row_to_json(t.*) AS tournament,
    markets.tournament_round,
    ( SELECT json_agg(t_1.* 
    ORDER BY CASE WHEN t_1.id = markets.home_team 
    THEN 0 
    ELSE 1 
    END)
     AS json_agg
           FROM v_teams t_1
          WHERE t_1.id = ANY (markets.teams)) AS teams,
    markets.status,
    markets.status_label,
    markets.match_status,
    markets.match_status_label,
    markets.winner_id,
    markets.markets_number,
    markets.markets,
    get_channel(markets.match, 'FRA') AS channel
   FROM ( SELECT mk.match,
            m.date,
            m.sport,
            m.tournament,
            mk.tournament_round,
            m.teams,
            m.home_team,
            mk.status,
            mk.status_label,
            mk.match_status,
            mk.match_status_label,
            m.winner_id,
            count(mk.name) AS markets_number,
            json_agg(mk.* ORDER BY priority) AS markets
           FROM matches m
             JOIN (SELECT o.match,
    o.date,
    o.active,
    o.sport,
    o.tournament,
    o.tournament_round,
    o.teams,
    o.home_team,
    o.status,
    o.status_label,
    o.match_status,
    o.match_status_label,
    o.name,
    o.group_name,
    o.label,
    o."limit",
    o.sorted,
    o.columns, 
    o.priority,
    o.description,
	  o.lang,
    o.type_keys,
    json_agg(o.odds) AS odds
   FROM ( SELECT  o_1.match,
			            o_1.date,
                  o_1.sport,
                  o_1.tournament,
                  o_1.tournament_round,
                  o_1.teams,
                  o_1.home_team,
                  o_1.status,
                  o_1.status_label,
                  o_1.match_status,
                  o_1.match_status_label,
                  o_1.name,
                  o_1.group_name,
                  o_1.market_id,
                  o_1.label,
                  o_1."limit",
                  o_1.sorted,
                  o_1.columns, 
                  o_1.priority,
                  o_1.description,
	                o_1.lang,
                  o_1.type_keys,
                  o_1.field_id,
                  o_1.type_id,
                  o_1.active,
                  json_build_object('type_id', 
                                    o_1.type_id, 
                                    'field_id', 
                                    o_1.field_id, 
                                    'field_name', 
                                    o_1.field_name, 
                                    'field_label', 
                                    o_1.field_label, 
                                    'handicap', 
                                    o_1.handicap, 
                                    'probability', 
                                    o_1.probability, 
                                    'best_odd', 
                                    o_1.odd, 
                                    'typekey', 
                                    o_1.typekey, 
                                    'type_label', 
                                    o_1.type_label,
                                    'order', 
                                    o_1.order, 
                                    'winner', 
                                    o_1.winner, 
                                    'bookmaker', 
                                    o_1.bookmaker, 
                                    'validated', 
                                    o_1.validated, 
                                    'top_player', 
                                    o_1.top_player, 
                                    'prognosis_rate', 
                                    o_1.prognosis_rate)
                                  AS odds
          FROM get_matches_odds(_matches => ARRAY[_match], 
                                _comparator => true,
                                _lang => _lang) o_1
          ) o
  GROUP BY o.match,  
           o.date, 
           o.active, 
           o.sport, 
           o.tournament, 
           o.tournament_round, 
           o.teams, 
           o.home_team, 
           o.status, 
           o.status_label, 
           o.match_status, 
           o.match_status_label, 
           o.name, o.group_name, 
           o.columns, 
           o.sorted, 
           o.label, 
           o."limit", 
           o.priority, 
           o.description, 
           o.lang, 
           o.type_keys
  ORDER BY o.priority) mk ON mk.match = m.id
          GROUP BY mk.match, 
                   m.date, 
                   m.sport, 
                   m.tournament, 
                   mk.tournament_round, 
                   m.teams, 
                   m.home_team, 
                   mk.status, 
                   mk.status_label, 
                   mk.match_status, 
                   mk.match_status_label, 
                   m.winner_id) 
                   markets
     JOIN tournaments t ON t.id = markets.tournament
     JOIN sports s ON s.id = markets.sport;

END $BODY$;