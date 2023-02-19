-- FUNCTION: public.format_email(json)

 DROP FUNCTION IF EXISTS public.format_email(json);

CREATE OR REPLACE FUNCTION public.format_email(
	_matches json,
  OUT msg text)
    RETURNS text
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare
rec record;
r record;
i integer;
t_head text;
t_body text;
begin
t_head = '<tr>';
FOR rec IN SELECT * FROM json_each(_matches->0)
LOOP 
  t_head := t_head || '<th>' || rec.key || '</th> ';
END LOOP;
t_head := t_head || '</tr>';

t_body = '';

FOR i IN 1..coalesce(json_array_length(_matches), 0) 
LOOP
	t_body := t_body || '<tr>';
	
	FOR r IN SELECT * FROM json_each(_matches->i)
  LOOP 
    t_body := t_body || '<td>' || r.value || '</td> ';
  END LOOP;
  
    t_body := t_body || '</tr>';
  
END LOOP;

msg = concat('<table>', t_head, t_body, '</table>');


end;
$BODY$;