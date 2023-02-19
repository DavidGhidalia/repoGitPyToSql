DROP VIEW IF EXISTS public.v_odds_old;


CREATE VIEW public.v_odds_old AS
 SELECT odds.match,
    odds.date,
    odds.sport,
    odds.tournament,
    odds.teams,
    odds.type AS name,
    odds.group_name,
    odds.bookmaker AS bookmaker_id,
        CASE
            WHEN (odds.group_name = 'regular'::text) 
            THEN ( SELECT json_agg(t.*) AS json_agg
               FROM public.teams t
              WHERE (((t.name)::text = (odds."Outcome" ->> 'label'::text)) AND (t.id = ANY (odds.teams))))
            ELSE NULL::json
        END 
        AS winner,
    odds.market_id,
    odds.label,
    (odds."Outcome" ->> 'id'::text) AS field_id,
    (odds."Outcome" ->> 'name'::text) AS field_name,
        CASE
            WHEN (odds.type = 'total'::text) 
            THEN public.get_label_outcomes((odds.typekey)::character varying, 
            ((odds."Outcome" ->> 'name'::text))::character varying, odds.sport)
            ELSE public.get_label_outcomes(((odds."Outcome" ->> 'label'::text))::character varying, 
            ((odds."Outcome" ->> 'name'::text))::character varying, odds.sport)
        END 
        AS field_label,
    (odds."Outcome" ->> 'handicap'::text) AS handicap,
    odds.type_keys,
    odds.typekey,
        CASE
            WHEN (((odds.group_name = 'total'::text) OR ((odds.details ->> 'type'::text) = 'total'::text)) 
            AND ((odds."Outcome" ->> 'name'::text) = 'Over'::text)) 
            THEN (odds.typekey)::double precision
            WHEN (((odds.group_name = 'total'::text) OR ((odds.details ->> 'type'::text) = 'total'::text)) 
            AND ((odds."Outcome" ->> 'name'::text) = 'Under'::text)) 
            THEN ((odds.typekey)::double precision - (0.25)::double precision)
            ELSE NULL::double precision
        END 
        AS "order",
    oty.id AS type_id,
    ((
        CASE
            WHEN (odds."Outcome" ? 'HO'::text) 
            THEN ((odds."Outcome" - 'HO'::text) || jsonb_build_object('odd', (odds."Outcome" -> 'HO'::text)))
            WHEN (odds."Outcome" ? 'DO'::text) 
            THEN ((odds."Outcome" - 'DO'::text) || jsonb_build_object('odd', (odds."Outcome" -> 'DO'::text)))
            WHEN (odds."Outcome" ? 'AO'::text) 
            THEN ((odds."Outcome" - 'AO'::text) || jsonb_build_object('odd', (odds."Outcome" -> 'AO'::text)))
            WHEN ((odds."Outcome" ? '$t'::text) AND (odds."Outcome" ? 'OO'::text)) 
            THEN (((odds."Outcome" - '$t'::text) - 'OO'::text) || 
            jsonb_build_object('odd', (odds."Outcome" -> '$t'::text), 
            'typekey', (odds."Outcome" -> 'OO'::text)))
            WHEN ((odds."Outcome" ? '$t'::text) AND (odds."Outcome" ? 'UO'::text)) 
            THEN (((odds."Outcome" - '$t'::text) - 'UO'::text) || 
            jsonb_build_object('odd', (odds."Outcome" -> '$t'::text), 'typekey', 
            (odds."Outcome" -> 'UO'::text)))
            WHEN ((odds."Outcome" ? '$t'::text) AND (NOT ((odds."Outcome" ? 'UO'::text) 
            OR (odds."Outcome" ? 'OO'::text)))) 
            THEN ((odds."Outcome" - '$t'::text) || jsonb_build_object('odd', (odds."Outcome" -> '$t'::text)))
            ELSE NULL::jsonb
        END ->> 'odd'::text))::double precision AS odd
   FROM (( SELECT o.match,
            m.date,
            m.sport,
            to_jsonb(t.*) AS tournament,
            m.teams,
            o.bookmaker,
            o.details,
                CASE
                    WHEN ((o.details ->> 'id'::text) IS NULL) 
                    THEN ( SELECT markets.market_id
                       FROM public.markets
                      WHERE ((markets.name)::text = replace((o.details ->> 'type'::text), '3way'::text, '3W'::text))
                     LIMIT 1)
                    ELSE ((o.details ->> 'id'::text))::integer
                END AS market_id,
            replace((o.details ->> 'type'::text), '3way'::text, '3W'::text) AS type,
            (o.details ->> 'label'::text) AS label,
            (o.details ->> 'typekey'::text) AS typekey,
            (o.details ->> 'group_name'::text) AS group_name,
                CASE
                    WHEN (((o.details ->> 'group_name'::text) = 'total'::text) 
                    OR ((o.details ->> 'type'::text) = 'total'::text) 
                    OR ((o.details ->> 'group_name'::text) = 'score'::text)) 
                    THEN true
                    ELSE false
                END AS type_keys,
            o.odds_type_ids,
            jsonb_array_elements((o.details -> 'Outcome'::text)) AS "Outcome"
           FROM ((public.odds o
             JOIN public.matches m ON ((m.id = o.match)))
             JOIN public.tournaments t ON ((t.id = m.tournament)))) odds
     LEFT JOIN public.odds_type oty ON (((oty.id = ANY (odds.odds_type_ids)) 
     AND (upper((oty.name)::text) = upper(odds.type)) 
     AND (upper((oty.field_name)::text) = upper((odds."Outcome" ->> 'name'::text))) AND
        CASE
            WHEN (NULLIF(odds.typekey, ''::text) IS NOT NULL) 
            THEN ((oty.value)::text = odds.typekey)
            ELSE (oty.value IS NULL)
        END)))
  ORDER BY odds.market_id, (odds."Outcome" ->> 'id'::text);