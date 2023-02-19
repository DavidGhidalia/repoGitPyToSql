--FUNCTION public.get_matches_odds(integer, date, integer, boolean, integer[], integer[], match_status, varchar, timestamp with time zone, timestamp with time zone, lang);

DROP FUNCTION IF EXISTS public.get_matches_odds(integer[], date, character varying, integer, boolean, integer[],
 character varying , integer, integer[], integer[] , boolean, boolean, boolean, integer, integer [], 
 match_status, character varying[], timestamp with time zone, timestamp with time zone, integer, 
lang, integer, integer);

CREATE OR REPLACE FUNCTION public.get_matches_odds(
  _matches integer[] default null,
  _date date default null,
  _country_code character varying default null,
  _sport integer default null,
  _sportMarket boolean default false,
  _tournaments integer[] default '{}',
  _tournamentRound character varying default null,
  _round integer default null,
  _markets integer[] default '{}',
  _bookmakers integer[] default '{}',
  _comparator boolean default false,
  _perfect boolean default false,
  _beegame boolean default false,
  _beegameId integer default null,
  _beegameMatches integer[] default '{}',
  _status match_status default null,
  _codes character varying[] default '{}',
  _start timestamp with time zone default null,
  _end timestamp with time zone default null,
  _user integer default null,
  _lang lang default 'fr',
  _limit integer default 100,
  _offset integer default 0
  ) RETURNS TABLE(
    match integer,
    date timestamp with time zone,
    country_code character varying,
	  sport integer,
	  tournament jsonb,
    tournament_round jsonb,
    round integer,
	  teams integer[],
    home_team integer,
    result jsonb,
    result_live jsonb,
	  status match_status,
    status_label varchar,
    match_status match_match_status,
    match_status_label varchar,
    winner_id integer,
    active boolean,
    name text, 
    group_name text,
    bookmaker_id integer,
    bookmaker json,
    winner json,
    market_id integer,
    field_id text,
    field_name text,
    field_label text,
    handicap text,
    probability text,
    label text,
    type_label text,
    description jsonb,
    "limit" integer,
    sorted boolean,
    columns integer, 
    priority integer,
    lang lang,
    type_keys boolean,
    typekey text,
    "order" double precision,
    type_id integer,
    validated boolean,
    odd double precision,
    top_player boolean,
    prognosis_rate double precision,
    disabled boolean,
    displayed boolean
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY

WITH q AS (
  SELECT q.*
  FROM (
    SELECT  m.id, 
            m.date,
            m.round,
            c.country_code,
            m.result, 
            m.result_live, 
            m.sport, 
            m.teams, 
            m.home_team, 
            m.status, 
            m.match_status, 
            m.winner_id, 
            ms1.label as status_label, 
            ms2.label as match_status_label,
            t1.name as home_team_name, 
            t2.name as away_team_name, 
            to_jsonb(t.*) AS tournament,
	  		    to_jsonb(r.*) AS tournament_round,
            tr.label_point, 
            tr.label_set, 
            os.active,
            o.match,
            o.bookmaker,
            o.details,
            o.odds_type_ids,
            o.validated,
            o.disabled,
            o.displayed,
            DENSE_RANK() OVER (PARTITION BY m.tournament ORDER BY t.order, (CASE WHEN 'closed' = any(_codes) THEN m.date END) DESC, m.date ASC) AS rank_limit
    FROM matches m
    JOIN matches_status ms on ms.status = m.status
    JOIN matches_status_tr ms1 on ms1.status::text = m.status::text and ms1.lang_code = _lang
    JOIN matches_status_tr ms2 on ms2.status::text = m.match_status::text and ms2.lang_code = _lang
    JOIN teams t1 on t1.id = m.home_team
    JOIN teams t2 on t2.id = any(m.teams) AND NOT (t2.id = m.home_team)
    JOIN tournaments t ON t.id = m.tournament
    JOIN categories c on c.id = m.category
    JOIN v_sports_tr tr ON tr.id = m.sport AND tr.lang = _lang
    JOIN odds o on o.match = m.id and o.displayed and case when _markets <> '{}' then (o.details->>'id')::integer = any(_markets) else 1=1 end         
	  JOIN odds o2 on o2.match = m.id and o2.bookmaker = 9999
    LEFT JOIN odds_settings os ON os.name = 'validated'
    LEFT JOIN tournaments_rounds_tr r on r.name::text = m.tournament_round::text and r.lang_code = _lang
    --LEFT JOIN get_perfects_played(m.id, _beegameId, _user) pp on pp.id = m.id
    WHERE CASE WHEN _matches <> '{}' THEN m.id = any(_matches) ELSE 1=1 END
    AND CASE WHEN _date IS NOT NULL THEN m.date::date = _date AND m.date >= now() ELSE 1=1 END
    AND CASE WHEN _country_code IS NOT NULL THEN c.country_code = _country_code ELSE 1=1 END
    AND CASE WHEN _sport IS NOT NULL THEN m.sport = _sport ELSE 1=1 END
    AND CASE WHEN _sportMarket THEN (o.details->>'id')::integer = tr.market_id ELSE 1=1 END
    AND CASE WHEN _beegameMatches <> '{}' THEN m.id = any(_beegameMatches) ELSE 1=1 END
    AND CASE WHEN _tournaments <> '{}' THEN m.tournament = any(_tournaments) ELSE 1=1 END
    AND CASE WHEN _tournamentRound IS NOT NULL THEN m.tournament_round = _tournamentRound ELSE 1=1 END
    AND CASE WHEN _round IS NOT NULL THEN m.round = _round ELSE 1=1 END
    AND CASE WHEN array_remove(_bookmakers, NULL) <> '{}' THEN o.bookmaker = any(_bookmakers) ELSE o.bookmaker = 9999 END
    AND CASE WHEN _status IS NOT NULL THEN m.status = _status ELSE 1=1 END
    AND CASE WHEN _codes <> '{}' THEN ms.code = any(_codes) ELSE 1=1 END
    AND CASE WHEN _start IS NOT NULL THEN m.date >= _start ELSE 1=1 END
    AND CASE WHEN _end IS NOT NULL THEN m.date <= _end ELSE 1=1 END
    --AND CASE WHEN _perfect THEN ms.code = 'not_started' OR (ms.code IN ('live', 'closed') AND pp.played) ELSE 1=1 END
    GROUP BY m.id, c.country_code, ms1.label, ms2.label, t1.name, t2.name, t.*, r.*, tr.label_point, tr.label_set, os.active, o.match, o.bookmaker, o.details, o.odds_type_ids, o.validated, o.disabled, o.displayed, t.order
	  HAVING CASE WHEN _markets <> '{}' THEN _markets <@ array_agg(distinct (o2.details->>'id')::integer) ELSE 1=1 END 
  ) q
  WHERE q.rank_limit > _offset AND q.rank_limit <= _limit + _offset
)
 
  SELECT odds.match,
    odds.date,
    odds.country_code,
    odds.sport,
    odds.tournament,
    odds.tournament_round,
    odds.round,
    odds.teams,
    odds.home_team,
    odds.result,
    odds.result_live,
    odds.status,
    odds.status_label,
    odds.match_status,
    odds.match_status_label,
    odds.winner_id,
    CASE
      WHEN odds.status IN ('not_started', 'match_about_to_start', 'delayed') THEN true
      ELSE false
    END AS active,
    odds.type AS name,
    odds.group_name,
    odds.bookmaker AS bookmaker_id,
    row_to_json(b.*) as bookmaker,
        CASE
            WHEN odds.group_name = 'regular'::text THEN ( SELECT json_agg(t.*) AS json_agg
               FROM teams t
              WHERE t.name::text = (odds."Outcome" ->> 'label'::text) AND (t.id = ANY (odds.teams)))
            ELSE NULL::json
        END AS winner,
    odds.market_id,
    odds."Outcome" ->> 'id'::text AS field_id,
    odds."Outcome" ->> 'name'::text AS field_name,
    get_label_outcomes((odds."Outcome" ->> 'id')::integer, (odds."Outcome" ->> 'name')::text, _lang, odds.home_team_name, odds.away_team_name, odds.typekey, CASE WHEN odds.sport = 5 AND odds.market_id = 127 THEN odds.label_set ELSE odds.label_point END) AS field_label,
    odds."Outcome" ->> 'handicap'::text AS handicap,
    odds."Outcome" ->> 'probability'::text AS probability,
    replace(tr.label, '{{point}}', odds.label_point) as label,
    replace(tr.type_label, '{{point}}', odds.label_point) as type_label,
    replace(tr.description::text, '{{point}}', odds.label_point)::jsonb as description,
    tr."limit",
    tr.sorted,
    tr.columns, 
    tr.priority,
    tr.lang,
    odds.type_keys,
    CASE WHEN odds.type_keys and odds.typekey = ''::text then 
	
        CASE
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'OO'::text THEN (odds."Outcome" - '$t'::text - 'OO'::text) || jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'OO'::text)
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'UO'::text THEN (odds."Outcome" - '$t'::text - 'UO'::text) || jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'UO'::text)
            WHEN odds."Outcome" ? '$t'::text AND NOT (odds."Outcome" ? 'UO'::text OR odds."Outcome" ? 'OO'::text) THEN (odds."Outcome" - '$t'::text) || jsonb_build_object('odd', odds."Outcome" -> '$t'::text)
            ELSE NULL::jsonb
        END->> 'typekey'::text
    ELSE odds.typekey::text END as typekey,
    CASE
        WHEN odds.typekey = ''::text THEN ot.priority::double precision
        WHEN (odds.group_name = 'total'::text OR (odds.details ->> 'type'::text) = 'total'::text) AND (odds."Outcome" ->> 'name'::text) = 'Over'::text THEN odds.typekey::double precision
        WHEN (odds.group_name = 'total'::text OR (odds.details ->> 'type'::text) = 'total'::text) AND (odds."Outcome" ->> 'name'::text) = 'Under'::text THEN odds.typekey::double precision - 0.25::double precision
        ELSE ot.priority::double precision
    END AS "order",
    oty.id AS type_id,
    CASE 
      WHEN odds.result IS NOT NULL THEN
        CASE 
          WHEN oty.id = ANY(odds.validated) THEN true
          ELSE false
        END
      ELSE null
    END as validated, 
    (
        CASE
            WHEN odds."Outcome" ? 'HO'::text THEN (odds."Outcome" - 'HO'::text) || jsonb_build_object('odd', odds."Outcome" -> 'HO'::text)
            WHEN odds."Outcome" ? 'DO'::text THEN (odds."Outcome" - 'DO'::text) || jsonb_build_object('odd', odds."Outcome" -> 'DO'::text)
            WHEN odds."Outcome" ? 'AO'::text THEN (odds."Outcome" - 'AO'::text) || jsonb_build_object('odd', odds."Outcome" -> 'AO'::text)
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'OO'::text THEN (odds."Outcome" - '$t'::text - 'OO'::text) || jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'OO'::text)
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'UO'::text THEN (odds."Outcome" - '$t'::text - 'UO'::text) || jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'UO'::text)
            WHEN odds."Outcome" ? '$t'::text AND NOT (odds."Outcome" ? 'UO'::text OR odds."Outcome" ? 'OO'::text) THEN (odds."Outcome" - '$t'::text) || jsonb_build_object('odd', odds."Outcome" -> '$t'::text)
            ELSE NULL::jsonb
        END ->> 'odd'::text)::double precision AS odd,
    ( SELECT (EXISTS ( SELECT p.id FROM prognosis p WHERE p.match = odds.match AND p.type_id = oty.id AND p.top_player AND os1.active)) AS "exists") AS top_player,
    ( SELECT (COUNT(p.id) FILTER (WHERE p.type_id = oty.id))::double precision / NULLIF(COUNT(p.id) FILTER (WHERE p.content->>'type' = odds.type), 0) FROM prognosis p WHERE p.match = odds.match AND os2.active ) AS prognosis_rate,
    odds.disabled,
    odds.displayed
   FROM ( SELECT q.match,
            q.date,
            q.country_code,
            q.result,
            q.result_live,
            q.sport,
            q.label_point,
            q.label_set,
            q.tournament,
            q.tournament_round,
            q.round,
            q.teams,
            q.home_team,
            q.home_team_name,
            q.away_team_name,
            q.status,
            q.status_label,
            q.match_status,
            q.match_status_label,
            q.winner_id,
            q.bookmaker,
            q.details,
                CASE
                    WHEN (q.details ->> 'id'::text) IS NULL THEN ( SELECT markets.market_id
                       FROM markets
                      WHERE markets.name::text = q.details ->> 'type'::text
                     LIMIT 1)
                    ELSE (q.details ->> 'id'::text)::integer
                END AS market_id,
            q.details ->> 'type'::text AS type,
            q.details ->> 'label'::text AS label,
            q.details ->> 'typekey'::text AS typekey,
            q.details ->> 'group_name'::text AS group_name,
                CASE
                    WHEN (q.details ->> 'group_name'::text) = 'total'::text OR (q.details ->> 'type'::text) = 'total'::text OR (q.details ->> 'group_name'::text) = 'score'::text THEN true
                    ELSE false
                END AS type_keys,
            q.odds_type_ids,
            CASE WHEN q.active THEN q.validated ELSE null END as validated,
            jsonb_array_elements(q.details -> 'Outcome'::text) AS "Outcome",
            q.disabled,
            q.displayed
           FROM q
		  ) odds
       JOIN v_markets_tr tr ON tr.market_id = odds.market_id AND tr.sport = odds.sport AND tr.lang = _lang AND tr.visible
       LEFT JOIN bookmakers bo ON bo.id = (odds."Outcome"->>'book_id')::integer AND bo.active AND CASE WHEN _comparator THEN bo.comparator ELSE 1=1 END AND CASE WHEN _beegame THEN bo.beegame ELSE 1=1 END
       JOIN bookmakers b ON b.active AND CASE WHEN bo.id IS NOT NULL THEN b.id = bo.id ELSE b.id = odds.bookmaker END AND CASE WHEN _comparator THEN b.comparator ELSE 1=1 END AND CASE WHEN _beegame THEN b.beegame ELSE 1=1 END
     JOIN outcomes ot ON ot.name::text = odds.type AND (ot.field_name::text = (odds."Outcome" ->> 'name'::text) OR ot.field_name::text = ''::text) AND ot.visible
     LEFT JOIN odds_type oty ON (oty.id = ANY (odds.odds_type_ids)) AND upper(oty.name::text) = upper(odds.type) AND upper(oty.field_name::text) = upper(odds."Outcome" ->> 'name'::text) AND
        CASE
            WHEN NULLIF(odds.typekey, ''::text) IS NOT NULL THEN oty.value::text = odds.typekey
            ELSE oty.value IS NULL
        END
	LEFT JOIN odds_settings os1 ON os1.name = 'top_player'
  LEFT JOIN odds_settings os2 ON os2.name = 'prognosis_rate'
  WHERE odds.group_name = 'total'::text AND odds.typekey ~~ '%.%'::text OR odds.group_name <> 'total'::text;
  
END $BODY$;