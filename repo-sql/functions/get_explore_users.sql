-- FUNCTION: public.get_explore_users(text, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_explore_users(text, integer, integer, integer);

CREATE OR REPLACE FUNCTION public.get_explore_users(
	_query text,
  _user integer,
  _limit integer default 100,
  _offset integer default 0)
    RETURNS TABLE(explore_id integer, id integer, nickname character varying, 
    avatar character varying, verified boolean, roi numeric, followed boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY

SELECT e.id AS explore_id, u.id, u.nickname, u.avatar, u.verified, p.roi, 
CASE WHEN _user = ANY(u.followers) 
THEN true 
ELSE false 
END 
AS followed
FROM explores e
CROSS JOIN plainto_tsquery('french', _query) query
LEFT JOIN users u ON u.id <> _user AND (u.nickname % _query OR u.location % _query OR query @@ u.biography_search)
LEFT JOIN performances p on p.user_id = u.id
WHERE e.name = 'users' AND e.active
ORDER BY u.nickname ASC 
LIMIT _limit OFFSET _offset;

END
$BODY$;