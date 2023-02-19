-- FUNCTION: public.get_sponsors_gifts(integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_sponsors_gifts(integer, integer, integer);

CREATE OR REPLACE FUNCTION public.get_sponsors_gifts(
	_user integer,
  _level integer,
  _gift integer)
    RETURNS TABLE(id integer, type_id integer, user_id integer, logo varchar, code varchar, created_at timestamp with time zone, updated_at timestamp with time zone, expired_at timestamp with time zone, reward text, unlocked boolean, unlocked_at integer, unlocked_at_level integer, unlocked_at_total bigint, unlocked_at_users json, unlocked_at_left integer, is_authorized boolean) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY

SELECT s.*, s.unlocked_at - json_array_length(s.unlocked_at_users) as unlocked_at_left, CASE WHEN g.id IS NULL AND json_array_length(s.unlocked_at_users)::double precision / s.unlocked_at = 1 THEN true ELSE false END as is_authorized
FROM (
  SELECT q.id, q.type_id, q.user_id, q.logo, CASE WHEN q.user_id = _user THEN q.code ELSE null END as code, q.created_at, q.updated_at, q.expired_at, q.reward || '€', q.unlocked, q.unlocked_at, q.unlocked_at_level, q.unlocked_at_total, COALESCE(json_agg(r.* ORDER BY r.rank) FILTER (WHERE r.rank > q.unlocked_at_total - q.unlocked_at AND r.rank <= q.unlocked_at_total), '[]') as unlocked_at_users
  FROM (
    SELECT g.id, g.type_id, g.user_id, g.logo, g.code, g.created_at, g.updated_at, g.expired_at, gt.value as reward, CASE WHEN g.user_id = _user THEN true ELSE false END as unlocked, gl.unlocked_at, gl.level as unlocked_at_level, sum(gl.unlocked_at) over(order by gl.level) as unlocked_at_total
    FROM gifts g
    JOIN gifts_levels gl on gl.type_id = g.type_id and gl.level = _level
    JOIN gifts_types gt on gt.id = gl.type_id
    WHERE g.id = _gift
  ) q
  LEFT JOIN (
	  SELECT row_number() over(order by u.created_at) as rank, u.id, u.sponsor_id, u.nickname, u.avatar, u.created_at
	  FROM users u
	  WHERE u.sponsor_id = _user
  ) r on r.sponsor_id = _user
  GROUP BY q.id, q.type_id, q.user_id, q.logo, q.code, q.created_at, q.updated_at, q.expired_at, q.reward, q.unlocked, q.unlocked_at, q.unlocked_at_level, q.unlocked_at_total
  ORDER BY q.unlocked_at_level
) s
LEFT JOIN gifts g on g.user_id = _user and g.level = _level and g.contest_id is null;

END
$BODY$;