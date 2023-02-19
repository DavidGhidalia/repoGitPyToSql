-- FUNCTION: public.get_sponsors(integer)

DROP FUNCTION IF EXISTS public.get_sponsors(integer);

CREATE OR REPLACE FUNCTION public.get_sponsors(
	_user integer)
    RETURNS TABLE (
      id integer, 
      level integer,
      beecoins_win numeric,
      beecoins_claimed boolean,
      beecoins_claimed_at timestamptz,
      unlocked boolean,
      unlocked_at integer,
      unlocked_at_total bigint,
      unlocked_at_users json,
      unlocked_at_rate double precision,
      unlocked_at_left integer,
      unlocked_at_date timestamptz,
      transactions integer[]
    )
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
BEGIN
RETURN QUERY

SELECT s.id,
        s.level,
        s.beecoins_win,
        s.beecoins_claimed,
        s.beecoins_claimed_at,
        case when json_array_length(s.unlocked_at_users) = s.unlocked_at then true else false end as unlocked,
        s.unlocked_at,
        s.unlocked_at_total,
        s.unlocked_at_users,
        json_array_length(s.unlocked_at_users)::double precision / s.unlocked_at as unlocked_at_rate,
        s.unlocked_at - json_array_length(s.unlocked_at_users) as unlocked_at_left,
        case when json_array_length(s.unlocked_at_users) = s.unlocked_at then s.unlocked_at_date else null end as unlocked_at_date,
        s.transactions
FROM (
  SELECT q.*, COALESCE(json_agg(r.* ORDER BY r.rank) FILTER (WHERE r.rank > q.unlocked_at_total - q.unlocked_at AND r.rank <= q.unlocked_at_total), '[]') as unlocked_at_users, max(r.created_at) filter (where r.rank > q.unlocked_at_total - q.unlocked_at AND r.rank <= q.unlocked_at_total) as unlocked_at_date  
  FROM (
    SELECT  s.id,
            s.level,
            s.unlocked_at,
            sum(s.unlocked_at) over(order by s.level) as unlocked_at_total,
            s.beecoins_win, 
            case when t.id is not null then true else false end as beecoins_claimed, 
            case when t.id is not null then t.created_at else null end as beecoins_claimed_at,
            s.transactions
    FROM sponsors s
    LEFT JOIN transactions t on t.id = any(s.transactions) and t.user_id = _user
    WHERE s.active
  ) q
  LEFT JOIN (
    SELECT row_number() over(order by u.created_at) as rank, u.id, u.sponsor_id, u.nickname, u.avatar, u.verified, u.vip, u.created_at
	  FROM users u
	  WHERE u.sponsor_id = _user AND CASE WHEN EXISTS(SELECT 1 FROM settings s WHERE s.name = 'phone_verification' AND s.active = true) THEN u.phone_verified ELSE 1=1 END
	) r on r.sponsor_id = _user
  GROUP BY q.id, q.level, q.unlocked_at, q.unlocked_at_total, q.beecoins_win, q.beecoins_claimed, q.beecoins_claimed_at, q.transactions
) s;

END
$BODY$;