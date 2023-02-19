-- FUNCTION: public.get_sponsors_old(integer, lang)

DROP FUNCTION IF EXISTS public.get_sponsors_old(integer, lang);

CREATE OR REPLACE FUNCTION public.get_sponsors_old(
  _user integer, _lang lang default 'fr')
    RETURNS TABLE(gift_id integer, type_id integer, user_id integer, level integer, logo varchar, code varchar, created_at timestamp with time zone, updated_at timestamp with time zone, expired_at timestamp with time zone, reward text, name varchar, description jsonb, lang lang, unlocked boolean, unlocked_at integer, unlocked_at_total bigint, unlocked_at_users json, unlocked_at_rate double precision, unlocked_at_left integer) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY

SELECT t.*, json_array_length(t.unlocked_at_users)::double precision / t.unlocked_at as unlocked_at_rate, t.unlocked_at - json_array_length(t.unlocked_at_users) as unlocked_at_left
FROM (
  SELECT  r.gift_id, 
          r.type_id, 
          r.user_id,
          r.level, 
          r.logo, 
          CASE WHEN r.user_id IS NOT NULL THEN r.code ELSE null END as code, 
          r.created_at, 
          r.updated_at, 
          r.expired_at, 
          r.reward || '€', 
          r.name,
          r.description,
          r.lang,
          r.unlocked, 
          r.unlocked_at, 
          r.unlocked_at_total, 
          COALESCE(json_agg(s.* ORDER BY s.rank) FILTER (WHERE s.rank > r.unlocked_at_total - r.unlocked_at AND s.rank <= r.unlocked_at_total), '[]') as unlocked_at_users
  FROM (
    SELECT q.gift_id, q.type_id, q.user_id, q.level, q.logo, q.code, q.created_at, q.updated_at, q.expired_at, q.reward, q.name, q.description, q.lang, q.unlocked, q.unlocked_at, sum(q.unlocked_at) over (order by q.level) as unlocked_at_total   
    FROM (
      SELECT DISTINCT ON (q.level) q.*, CASE WHEN q.user_id IS NOT NULL THEN true ELSE false END as unlocked
      FROM (
        SELECT g.*, row_number() over(partition by g.level order by g.level, case when g.gift_id is not null then 0 else 1 end, case when g.user_id is not null then 0 else 1 end, g.created_at) as rn, count(*) over(partition by g.gift_id)
        FROM v_gifts g
        WHERE g.lang = _lang AND (g.user_id IS NULL OR (g.user_id = _user AND g.user_level = g.level AND g.contest_id IS NULL))
      ) q 
      WHERE CASE WHEN q.count > 1 THEN q.rn = q.level OR q.gift_id is null ELSE 1=1 END
      ORDER BY q.level, q.rn
    ) q
  ) r
  LEFT JOIN (
    SELECT row_number() over(order by u.created_at) as rank, u.id, u.sponsor_id, u.nickname, u.avatar, u.created_at
    FROM users u
    WHERE u.sponsor_id = _user
  ) s on s.sponsor_id = _user
  GROUP BY r.gift_id, r.type_id, r.user_id, r.level, r.logo, r.code, r.created_at, r.updated_at, r.expired_at, r.unlocked_at, r.reward, r.name, r.description, r.lang, r.unlocked, r.unlocked_at_total
  ORDER BY r.level
) t;

END
$BODY$;
