-- FUNCTION: public.get_beegames_histories(integer, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_beegames_histories(integer, integer, integer, integer) cascade;

CREATE OR REPLACE FUNCTION public.get_beegames_histories(
  _user integer,
  _type integer default null,
  _limit integer default 100,
  _offset integer default 0
  ) RETURNS TABLE(
    id integer, 
    name varchar, 
    slug varchar, 
    logo varchar, 
    available json,
    ongoing json, 
    ended json
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY

SELECT  bt.id, 
        bt.name, 
        bt.slug, 
        bt.logo, 
        coalesce(json_agg(r.* ORDER BY r.priority, r.date_start) 
        FILTER (WHERE r.users IS NOT NULL AND NOT (_user = any(r.users)) 
        AND r.rank_status <= (SELECT ts.status_limit 
        FROM beegames_types_status ts 
        WHERE ts.type_id = bt.id 
        AND ts.status = 'available')), '[]') AS available,
        coalesce(json_agg(r.* ORDER BY r.priority, r.date_end DESC) 
        FILTER (WHERE _user = any(r.users) 
        AND now() BETWEEN r.date_start - interval '1' day * (r.type->>'days_start')::integer 
        AND r.date_end AND r.rank_status <= (SELECT ts.status_limit 
        FROM beegames_types_status ts 
        WHERE ts.type_id = bt.id AND ts.status = 'ongoing')), '[]') AS ongoing,
        coalesce(json_agg(r.* 
        ORDER BY r.priority, r.date_end DESC) 
        FILTER (WHERE _user = any(r.users) AND r.date_end < now() 
        AND r.rank_status <= (SELECT ts.status_limit 
        FROM beegames_types_status ts 
        WHERE ts.type_id = bt.id AND ts.status = 'ended')), '[]') AS ended
FROM beegames_types bt
LEFT JOIN (
  SELECT q.*, ROW_NUMBER() 
  OVER (PARTITION BY (q.type->>'id')::integer, 
  CASE WHEN now() BETWEEN q.date_start AND q.date_end 
  THEN 1 
  ELSE 2 
  END 
  ORDER BY q.date_end DESC) 
  AS rank_limit, ROW_NUMBER() 
  OVER (PARTITION BY (q.type->>'id')::integer, 

  CASE WHEN NOT (_user = any(q.users)) 
  THEN 1 
  ELSE CASE WHEN now() 
  BETWEEN q.date_start - interval '1' day * (q.type->>'days_start')::integer
  AND q.date_end 
  THEN 2 
  ELSE 3 
  END 
  END ORDER BY CASE WHEN NOT(_user = any(q.users)) 
  THEN q.date_start 
  END, 
  q.date_end DESC) AS rank_status
  FROM get_histories(_user => _user, _type => _type, _beegames => true, _limit => _limit, _offset => _offset) q
  WHERE now() BETWEEN q.date_start - interval '1' day * (q.type->>'days_start')::integer 
  AND q.date_end OR (q.date_end < now() AND case
  WHEN _type is null 
  THEN (q.date_end BETWEEN now() - interval '1' day * (q.type->>'days_ago_history')::integer 
  AND now() AND (q.beecoins_win is null OR q.beecoins_win = 0) OR (q.beecoins_claimed = true 
  AND now() BETWEEN q.beecoins_claimed_at 
  AND q.beecoins_claimed_at + interval '1' day * (q.type->>'days_ago_history')::integer) 
  OR (q.beecoins_win > 0 AND q.beecoins_claimed = false)) else 1=1 end)
) r ON (r.type->>'id')::integer = bt.id AND r.rank_limit > _offset AND r.rank_limit <= _limit + _offset
WHERE CASE WHEN _type IS NOT NULL 
THEN bt.id = _type 
ELSE bt.active
END

GROUP BY bt.id;

END $BODY$;