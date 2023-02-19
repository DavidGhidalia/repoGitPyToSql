DROP FUNCTION IF EXISTS public.get_label_prognosis(jsonb, integer, lang, character varying,
                                                     character varying, character varying) cascade;


CREATE OR REPLACE FUNCTION public.get_label_prognosis(
    _content jsonb, 
    _sport integer, 
    _lang lang, 
    _home character varying, 
    _away character varying, 
    _point character varying) 
    RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
content jsonb;
result text;
type_label text;
BEGIN

SELECT replace(replace(replace(replace(otr.field_label, '{{home}}', _home), '{{away}}', _away), '{{typekey}}', 
CASE WHEN ot.value IS NOT NULL 
THEN ot.value::text 
ELSE 'null' 
END), 
'{{point}}', _point), replace(mtr.type_label, '{{point}}', _point) 
INTO result, type_label
FROM odds_type ot
LEFT JOIN odds_tr otr ON otr.field_id = ot.field_id AND otr.lang_code = _lang
LEFT JOIN v_markets_tr mtr ON mtr.name = ot.name AND mtr.sport = _sport AND mtr.lang = _lang
WHERE ot.id = (_content->>'type_id')::integer;

IF result IS NOT NULL THEN
  content = jsonb_set(_content, '{result}', to_jsonb(result));
ELSE
  content = _content;
END IF;

IF type_label IS NOT NULL THEN
  content = jsonb_set(content, '{type_label}', to_jsonb(type_label));
END IF;

RETURN content;
END;
$$;