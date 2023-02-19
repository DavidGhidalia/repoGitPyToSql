DROP FUNCTION IF EXISTS public.get_label_outcomes(integer, text, character varying, character varying, 
                                                  text, character varying) CASCADE;


CREATE OR REPLACE FUNCTION public.get_label_outcomes(
    _fieldId integer,
    _fieldName text,
    _lang lang, _home character varying,
    _away character varying,
    _typekey text, 
    _point character varying) 
    RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
label text;
begin

SELECT replace(replace(replace(replace(tr.field_label, '{{home}}', _home), '{{away}}', _away), '{{typekey}}', _typekey), '{{point}}', _point) INTO label
FROM odds_tr tr
WHERE tr.field_id = _fieldId
AND tr.lang_code = _lang;

if label is not null then
  return label;
end if;

return _fieldName;
end;
$$;