-- FUNCTION: public.get_results(json)

DROP FUNCTION IF EXISTS public.get_results(json);

CREATE OR REPLACE FUNCTION public.get_results(
	results json)
    RETURNS TABLE(type text, field_name text, typekey text, type_id integer) 
    LANGUAGE 'sql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
SELECT r1.type, r1.field_name, r1.typekey, ot.id AS type_id
		FROM (
			SELECT r.type, r.winners ->> 'type'::text AS field_name,
					CASE 
						WHEN r.group_name = 'total'::text THEN r.line 
						ELSE NULL::text
                	END AS typekey
			FROM (
				SELECT markets.markets ->> 'name'::text as type,
				markets.markets ->> 'group_name'::text AS group_name,
                markets.markets ->> 'line'::text AS line,
				json_array_elements(CASE WHEN (markets.markets -> 'winners_fields')::text <> 'null' THEN markets.markets -> 'winners_fields'::text ELSE '[null]' END) as winners
				FROM (
					SELECT json_array_elements(results -> 'markets'::text) AS markets
					
				) markets
			) r
		) r1
	LEFT JOIN odds_type ot ON upper(ot.name::text) = upper(r1.type) AND upper(ot.field_name::text) = upper(r1.field_name) AND
        CASE
            WHEN NULLIF(r1.typekey, ''::text) IS NOT NULL THEN ot.value::text = r1.typekey
            ELSE ot.value IS NULL
        END
$BODY$;