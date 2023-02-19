-- FUNCTION: public.get_contests_gifts(integer, integer, lang)

 DROP FUNCTION IF EXISTS public.get_contests_gifts(integer, integer, lang);

CREATE OR REPLACE FUNCTION public.get_contests_gifts(
	_contest integer,
	_user integer,
  _lang lang default 'fr')
    RETURNS TABLE(type_id integer, name varchar, description jsonb, lang lang, reward text, 
    gift_id integer, user_id integer, contest_id integer, logo varchar, code varchar, 
    created_at timestamp with time zone, updated_at timestamp with time zone, 
    expired_at timestamp with time zone) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY

SELECT *
FROM (
  SELECT g.type_id, gt.name, tr.description, tr.lang_code AS lang, gt.value || 
  '€' AS reward, g.id AS gift_id, g.user_id, g.contest_id, g.logo, g.code, g.created_at,
  g.updated_at, g.expired_at
  FROM contest c
  JOIN gifts g ON g.contest_id = c.id AND g.user_id = _user
  JOIN gifts_types gt ON gt.id = g.type_id
  JOIN gifts_tr tr ON tr.type_id = gt.id AND tr.lang_code = _lang
  WHERE c.id = _contest AND c.date_end <= now()

  UNION ALL

  SELECT g.type_id, gt.name, tr.description, tr.lang_code AS lang, gt.value || '€' 
  AS reward, g.id AS gift_id, g.user_id, g.contest_id, g.logo, NULL, g.created_at, g.updated_at, g.expired_at
  FROM contest c
  JOIN jsonb_array_elements(c.results) r ON (r->>'id')::integer = _user
  JOIN gifts_types gt ON gt.value = replace((r->>'reward'), '€', '')::integer
  JOIN gifts g ON g.type_id = gt.id AND g.user_id is null
  JOIN gifts_tr tr ON tr.type_id = gt.id AND tr.lang_code = _lang
  WHERE c.id = _contest AND c.date_end <= now()
) q
ORDER BY CASE WHEN q.user_id IS NOT NULL 
THEN 0 
ELSE 1 
END, q.created_at
LIMIT 1;
  
END
$BODY$;