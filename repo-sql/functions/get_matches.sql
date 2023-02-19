-- FUNCTION: public.get_matches(integer, lang)

DROP FUNCTION IF EXISTS public.get_matches(integer, date, character varying,character varying[], lang, integer,integer) cascade;

CREATE OR REPLACE FUNCTION public.get_matches(
  _sport integer,
  _date date,
  _country_code character varying default null,
  _status character varying[] default null,
  _lang lang default 'fr',
  _limit integer default 100,
  _offset integer default 0
  ) RETURNS TABLE(
    id integer,
    date timestamp with time zone,
    country_code character varying,
	  sport integer,
	  tournament jsonb,
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
    markets.country_code,
    markets.sport,
    markets.tournament,
    markets.tournament_round,
    ( SELECT json_agg(t.* ORDER BY CASE WHEN t.id = markets.home_team THEN 0 ELSE 1 END) AS json_agg
           FROM v_teams t
          WHERE t.id = ANY (markets.teams)) AS teams,
    markets.status,
    markets.status_label,
    markets.match_status,
    markets.match_status_label,
    markets.winner_id,
    markets.markets_number,
    markets.markets,
    get_channel(markets.match, 'FRA') AS channel
   FROM ( SELECT mk.match,
            mk.date,
            mk.country_code,
            mk.sport,
            mk.tournament,
            mk.tournament_round,
            mk.teams,
            mk.home_team,
            mk.status,
            mk.status_label,
            mk.match_status,
            mk.match_status_label,
            mk.winner_id,
            ( SELECT count(DISTINCT o.details ->> 'type'::text) AS count
                   FROM odds o
                  WHERE o.match = mk.match) AS markets_number,
            json_agg(mk.*) AS markets
           FROM (SELECT o.match,
    o.date,
    o.country_code,
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
    o.winner_id,
    o.name,
    o.lang,
    CASE WHEN o.sport <> 99 THEN json_agg(o.odds) ELSE '[]' END AS odds
   FROM ( SELECT m_1.match,
                    m_1.date,
                    m_1.country_code,
                    m_1.sport,
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
            json_build_object('type_id', m_1.type_id, 'field_id', m_1.field_id, 'field_name', m_1.field_name, 'field_label', m_1.field_label, 'handicap', m_1.handicap, 'probability', m_1.probability, 'best_odd', m_1.odd, 'typekey', m_1.typekey, 'type_label', m_1.type_label, 'winner', m_1.winner, 'bookmaker', m_1.bookmaker, 'top_player', m_1.top_player, 'prognosis_rate', m_1.prognosis_rate) AS odds
                   FROM get_matches_odds(_sport => _sport, _sportMarket => true, _date => _date, _country_code => _country_code, _codes => _status, _comparator => true, _lang => _lang, _limit => _limit, _offset => _offset) m_1
                   ) o
  GROUP BY o.match, o.date, o.country_code, o.active, o.sport, o.tournament, o.tournament_round, o.teams, o.home_team, o.name, o.lang, o.status, o.status_label, o.match_status, o.match_status_label, o.winner_id) mk
          GROUP BY mk.match, mk.date, mk.country_code, mk.sport, mk.tournament, mk.tournament_round, mk.teams, mk.home_team, mk.status, mk.status_label, mk.match_status, mk.match_status_label, mk.winner_id
          ORDER BY mk.date asc) markets
  ORDER BY markets.date asc;

END $BODY$;