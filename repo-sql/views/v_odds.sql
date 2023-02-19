 -- View: public.v_odds

 DROP VIEW IF EXISTS public.v_odds CASCADE;

CREATE OR REPLACE VIEW public.v_odds
 AS
  SELECT odds.match,
    odds.date,
    odds.sport,
    odds.tournament,
    odds.teams,
    odds.status,
    odds.type AS name,
    odds.group_name,
    odds.bookmaker AS bookmaker_id,
        CASE
            WHEN odds.group_name = 'regular'::text 
            THEN ( SELECT json_agg(t.*) AS json_agg
               FROM teams t
              WHERE t.name::text = (odds."Outcome" ->> 'label'::text) AND (t.id = ANY (odds.teams)))
            ELSE NULL::json
        END AS winner,
    odds.market_id,
    odds.label,
    odds."Outcome" ->> 'id'::text AS field_id,
    odds."Outcome" ->> 'name'::text AS field_name,
        CASE
            WHEN odds.type = 'total'::text 
            THEN get_label_outcomes((CASE WHEN odds.type_keys and odds.typekey = ''::text THEN 
	
        CASE
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'OO'::text 
            THEN (odds."Outcome" - '$t'::text - 'OO'::text) || 
            jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'OO'::text)
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'UO'::text 
            THEN (odds."Outcome" - '$t'::text - 'UO'::text) || 
            jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'UO'::text)
            WHEN odds."Outcome" ? '$t'::text AND NOT (odds."Outcome" ? 'UO'::text OR odds."Outcome" ? 'OO'::text) 
            THEN (odds."Outcome" - '$t'::text) || jsonb_build_object('odd', odds."Outcome" -> '$t'::text)
            ELSE NULL::jsonb
        END->> 'typekey'::text
    ELSE odds.typekey::text END)::character varying, (odds."Outcome" ->> 'name'::text)::character varying, 
    odds.sport)
            ELSE get_label_outcomes((odds."Outcome" ->> 'label'::text)::character varying, 
            (odds."Outcome" ->> 'name'::text)::character varying, odds.sport)
        END AS field_label,
    odds."Outcome" ->> 'handicap'::text AS handicap,
    odds."Outcome" ->> 'probability'::text AS probability,
    ot.type_label,
    odds.type_keys,
    CASE WHEN odds.type_keys AND odds.typekey = ''::text THEN 
	
        CASE
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'OO'::text 
            THEN (odds."Outcome" - '$t'::text - 'OO'::text) || 
            jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'OO'::text)
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'UO'::text 
            THEN (odds."Outcome" - '$t'::text - 'UO'::text) || 
            jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'UO'::text)
            WHEN odds."Outcome" ? '$t'::text AND NOT (odds."Outcome" ? 'UO'::text OR odds."Outcome" ? 'OO'::text) 
            THEN (odds."Outcome" - '$t'::text) || jsonb_build_object('odd', odds."Outcome" -> '$t'::text)
            ELSE NULL::jsonb
        END->> 'typekey'::text
    ELSE odds.typekey::text END AS typekey,
    CASE
        WHEN odds.typekey = ''::text THEN ot.priority::double precision
        WHEN (odds.group_name = 'total'::text OR (odds.details ->> 'type'::text) = 'total'::text) 
        AND (odds."Outcome" ->> 'name'::text) = 'Over'::text 
        THEN odds.typekey::double precision
        WHEN (odds.group_name = 'total'::text OR (odds.details ->> 'type'::text) = 'total'::text) 
        AND (odds."Outcome" ->> 'name'::text) = 'Under'::text 
        THEN odds.typekey::double precision - 0.25::double precision
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
            WHEN odds."Outcome" ? 'HO'::text 
            THEN (odds."Outcome" - 'HO'::text) || jsonb_build_object('odd', odds."Outcome" -> 'HO'::text)
            WHEN odds."Outcome" ? 'DO'::text 
            THEN (odds."Outcome" - 'DO'::text) || jsonb_build_object('odd', odds."Outcome" -> 'DO'::text)
            WHEN odds."Outcome" ? 'AO'::text 
            THEN (odds."Outcome" - 'AO'::text) || jsonb_build_object('odd', odds."Outcome" -> 'AO'::text)
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'OO'::text 
            THEN (odds."Outcome" - '$t'::text - 'OO'::text) || 
            jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'OO'::text)
            WHEN odds."Outcome" ? '$t'::text AND odds."Outcome" ? 'UO'::text 
            THEN (odds."Outcome" - '$t'::text - 'UO'::text) || 
            jsonb_build_object('odd', odds."Outcome" -> '$t'::text, 'typekey', odds."Outcome" -> 'UO'::text)
            WHEN odds."Outcome" ? '$t'::text AND NOT (odds."Outcome" ? 'UO'::text OR odds."Outcome" ? 'OO'::text) 
            THEN (odds."Outcome" - '$t'::text) || jsonb_build_object('odd', odds."Outcome" -> '$t'::text)
            ELSE NULL::jsonb
        END ->> 'odd'::text)::double precision AS odd,
    ( SELECT (EXISTS ( SELECT p.id 
                       FROM prognosis p 
                       WHERE p.match = odds.match AND p.type_id = oty.id AND p.top_player AND os1.active)) 
                       AS "exists") AS top_player,
    ( SELECT (COUNT(p.id) 
      FILTER (WHERE p.type_id = oty.id))::double precision / NULLIF(COUNT(p.id) 
      FILTER (WHERE p.content->>'type' = odds.type), 0) 
      FROM prognosis p WHERE p.match = odds.match AND os2.active ) AS prognosis_rate,
    odds.disabled,
    odds.displayed
   FROM ( SELECT o.match,
            m.date,
            m.result,
            m.sport,
            to_jsonb(t.*) AS tournament,
            m.teams,
            m.status,
            o.bookmaker,
            o.details,
                CASE
                    WHEN (o.details ->> 'id'::text) IS NULL THEN ( SELECT markets.market_id
                       FROM markets
                      WHERE markets.name::text = replace(o.details ->> 'type'::text, '3way'::text, '3W'::text)
                     LIMIT 1)
                    ELSE (o.details ->> 'id'::text)::integer
                END AS market_id,
            replace(o.details ->> 'type'::text, '3way'::text, '3W'::text) AS type,
            o.details ->> 'label'::text AS label,
		 
            o.details ->> 'typekey'::text AS typekey,
            o.details ->> 'group_name'::text AS group_name,
                CASE
                    WHEN (o.details ->> 'group_name'::text) = 'total'::text 
                    OR (o.details ->> 'type'::text) = 'total'::text 
                    OR (o.details ->> 'group_name'::text) = 'score'::text 
                    THEN true
                    ELSE false
                END AS type_keys,
            o.odds_type_ids,
            CASE WHEN os.active 
            THEN o.validated 
            ELSE NULL 
            END 
            AS validated,
            jsonb_array_elements(o.details -> 'Outcome'::text) AS "Outcome",
            o.disabled,
            o.displayed
           FROM odds o
             JOIN matches m ON m.id = o.match
             JOIN tournaments t ON t.id = m.tournament
			 LEFT JOIN odds_settings os ON os.name = 'validated') odds
     JOIN outcomes ot ON ot.name::text = odds.type AND (ot.field_name::text = (odds."Outcome" ->> 'name'::text) 
     OR ot.field_name::text = ''::text) AND ot.visible
     LEFT JOIN odds_type oty ON (oty.id = ANY (odds.odds_type_ids)) AND upper(oty.name::text) = upper(odds.type) 
     AND upper(oty.field_name::text) = upper(odds."Outcome" ->> 'name'::text) AND
        CASE
            WHEN NULLIF(odds.typekey, ''::text) IS NOT NULL THEN oty.value::text = odds.typekey
            ELSE oty.value IS NULL
        END
	LEFT JOIN odds_settings os1 ON os1.name = 'top_player'
  LEFT JOIN odds_settings os2 ON os2.name = 'prognosis_rate'
  WHERE odds.group_name = 'total'::text AND odds.typekey ~~ '%.%'::text OR odds.group_name <> 'total'::text
 
 ORDER BY odds.market_id, (odds."Outcome" ->> 'id'::text);
 
 