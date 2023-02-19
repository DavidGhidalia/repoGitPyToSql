-- FUNCTION: public.get_histories(integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_histories(integer, integer, integer, integer, boolean,
                                               boolean, boolean, integer, integer) CASCADE;

CREATE OR REPLACE FUNCTION public.get_histories(
  _user integer,
  _session integer default NULL,
  _type integer default NULL,
  _beegame integer default NULL,
  _beegames boolean default false,
  _beecoins boolean default false,
  _played boolean default false,
  _limit integer default 100,
  _offset integer default 0
  ) RETURNS TABLE(
    id integer,
    "name" varchar,
    subtitle varchar,
    description varchar,
    tournament_name varchar,
    date_start timestamptz,
    date_END timestamptz,
    beecoins_fee numeric,
    beecoins_prize numeric, 
    round integer,
    code char(5),
    deep_link varchar,
    private boolean,
    pENDing_results boolean,
    tutorial_description integer[],
    tutorial_results integer[],
    priority integer,
    contest jsonb,
    "type" jsonb, 
    sport jsonb,
    win boolean,
    winner_id integer,
    odds_value numeric, 
    num_ticket bigint,
    "rank" integer,
    beecoins_bet numeric,
    beecoins_win numeric,
    beecoins_claimed boolean,
    beecoins_claimed_at timestamptz,
    points integer,
    points_pENDing integer,
    ticket jsonb,
    users integer[],
    transactions integer[],
    status text,
    matches bigint,
    date_next timestamptz,
    timer_status text,
    timer_date timestamptz
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY

-- perfect/poker
SELECT b.id, b.name, b.subtitle, b.description, b.tournament_name, b.date_start, b.date_END, 
b.beecoins_fee, b.beecoins_prize, b.round, b.code, b.deep_link, b.private, b.pENDing_results, 
b.tutorial_description, b.tutorial_results, b.priority, to_jsonb(c.*) 
AS contest, to_jsonb(bt.*) 
AS TYPE, to_jsonb(s.*) AS sport, 
CASE WHEN b.winner_id IS NOT NULL THEN 
CASE WHEN b.winner_id = _user 
THEN true ELSE false 
END 
ELSE NULL END AS win, b.winner_id, NULL AS odds_value, NULL AS num_ticket, 
(r->>'rank')::integer as rank, b.beecoins_fee as beecoins_bet, 
CASE WHEN b.date_END < now() 
THEN coalesce((r->>'beecoins_win')::numeric, 0) 
ELSE NULL 
END 
AS beecoins_win, 
CASE WHEN (r->>'id')::integer IS NOT NULL 
THEN (r->>'beecoins_claimed')::boolean 
ELSE false 
END
AS beecoins_claimed, (r->>'beecoins_claimed_at')::timestamptz 
AS beecoins_claimed_at, bp.points, bp.points_pENDing, 
NULL AS ticket, b.users, b.transactions, b.status::text, bms.matches, bms.date_next, 
bms.timer_status, bms.timer_date
FROM beegames b
JOIN beegames_types bt ON bt.id = b.type_id AND bt.slug IN ('perfect', 'pokerlive') AND 
CASE WHEN _type IS NOT NULL 
THEN bt.id = _type 
ELSE 1=1 
END
JOIN contest c ON c.id = b.contest_id
LEFT JOIN jsonb_array_elements(c.results) r ON (r->>'id')::integer = _user
LEFT JOIN sports s ON s.id = b.sport_id
LEFT JOIN get_beegames_points(b.id, _user) bp ON bp.id = b.id
LEFT JOIN get_beegames_matches_status(b.id) bms ON bms.id = b.id
WHERE b.visible AND (_user = any(b.users) OR (b.date_END > now() AND NOT (_user = any(b.users)) 
AND b.private = false))
AND CASE WHEN _beegame IS NOT NULL 
THEN b.id = _beegame 
ELSE 1=1 
END
AND CASE WHEN _beecoins 
THEN b.beecoins_fee > 0 OR (r->>'beecoins_win')::numeric > 0 
ELSE 1=1 
END
AND CASE WHEN _played 
THEN _user = any(b.users) 
ELSE 1=1 
END
AND CASE WHEN b.date_start > now() 
THEN now() BETWEEN b.date_start - interval '1' day * bt.days_start AND b.date_END 
ELSE 1=1 
END

UNION ALL 

-- topday
SELECT b.id, b.name, b.subtitle, b.description, b.tournament_name, b.date_start, b.date_END, 
b.beecoins_fee, b.beecoins_prize, b.round, b.code, b.deep_link, b.private, b.pENDing_results, 
b.tutorial_description, b.tutorial_results, b.priority, to_jsonb(c.*) AS contest, to_jsonb(bt.*) AS TYPE, 
to_jsonb(s.*) as sport, btk.win, b.winner_id, btk.odds_value, btk.num_ticket, 
CASE WHEN (r->>'ticket_id')::integer = btk.id THEN (r->>'rank')::integer 
ELSE NULL 
END 
AS rank, btk.beecoins_bet, 
CASE WHEN (r->>'ticket_id')::integer = btk.id 
THEN (r->>'beecoins_win')::numeric 
ELSE CASE WHEN btk.win IS NULL 
THEN NULL 
ELSE 0 
END 
END 
AS beecoins_win, 
CASE WHEN (r->>'ticket_id')::integer = btk.id 
THEN (r->>'beecoins_claimed')::boolean 
ELSE false 
END 
AS beecoins_claimed,  
CASE WHEN (r->>'ticket_id')::integer = btk.id 
THEN (r->>'beecoins_claimed_at')::timestamptz 
ELSE NULL 
END
AS beecoins_claimed_at, NULL AS points, NULL AS points_pENDing, to_jsonb(bti.*) 
AS ticket, b.users, btk.transactions, b.status::text, bms.matches, bms.date_next, 
bms.timer_status, bms.timer_date
	FROM beegames b
  JOIN beegames_types bt ON bt.id = b.type_id AND bt.slug = 'topday' AND 
  CASE WHEN _type IS NOT NULL 
  THEN bt.id = _type 
  ELSE 1=1 
  END
	JOIN contest c ON c.id = b.contest_id
	LEFT JOIN jsonb_array_elements(c.results) r ON (r->>'id')::integer = _user
  LEFT JOIN beegames_tickets btk ON btk.beegame_id = b.id AND btk.user_id = _user
	LEFT JOIN get_beegames_tickets(_beegame => b.id, _user => btk.user_id, _ticket => btk.id) bti 
  ON bti.id = btk.id 
  LEFT JOIN get_beegames_matches_status(b.id) bms ON bms.id = b.id
	LEFT JOIN sports s ON s.id = b.sport_id
  WHERE b.visible AND (_user = any(b.users) OR (b.date_END > now() AND NOT (_user = any(b.users)) 
  AND b.private = false))
  AND CASE WHEN _beegame IS NOT NULL 
  THEN b.id = _beegame 
  ELSE 1=1 
  END 
  AND CASE WHEN _beecoins 
  THEN btk.beecoins_bet > 0 OR (r->>'beecoins_win')::numeric > 0 
  ELSE 1=1 
  END
  AND CASE WHEN _played 
  THEN _user = any(b.users) 
  ELSE 1=1 
  END
	AND CASE WHEN b.date_start > now() 
  THEN now() BETWEEN b.date_start - interval '1' day * bt.days_start AND b.date_END 
  ELSE 1=1 
  END

UNION ALL

-- clusters
SELECT c.id, bt.name, NULL AS subtitle, NULL AS description, NULL AS tournament_name, c.created_at, c.updated_at, 
NULL AS beecoins_fee, NULL AS beecoins_prize, NULL AS round, NULL AS code, NULL AS deep_link, c.private, 
NULL AS pENDing_results, NULL AS tutorial_description, NULL AS tutorial_results, NULL AS priority, NULL AS contest, 
to_jsonb(bt.*) AS TYPE, NULL AS sport, c.win, NULL AS winner_id, c.odds_value, NULL AS num_ticket, NULL AS rank, 
c.beecoins_bet, c.beecoins_win, c.beecoins_claimed, c.beecoins_claimed_at, NULL AS points, NULL AS points_pENDing, 
to_jsonb(cl.*) AS ticket, NULL AS users, c.transactions, c.status::text, NULL AS matches, NULL AS date_next, 
NULL AS timer_status, NULL AS timer_date
	FROM clusters c
	JOIN beegames_types bt ON bt.slug = 'post' 
  AND CASE WHEN _type IS NOT NULL 
  THEN bt.id = _type 
  ELSE 1=1 
  END 
  AND CASE WHEN _beegames OR _beegame IS NOT NULL 
  THEN bt.slug <> 'post' 
  ELSE 1=1 
  END 
  LEFT JOIN get_cluster(_cluster => c.id, _owner => 
  CASE WHEN _session IS NOT NULL 
  THEN _session 
  ELSE c.owner 
  END) 
  cl ON cl.id = c.id
  WHERE c.owner = _user AND CASE WHEN _beecoins 
  THEN c.beecoins_bet > 0 OR c.beecoins_win > 0 
  ELSE 1=1 
  END

UNION ALL

-- sponsors
SELECT s.id, bt.name, NULL AS subtitle, NULL AS description, NULL AS tournament_name, 
CASE WHEN s.beecoins_claimed_at IS NOT NULL 
THEN s.beecoins_claimed_at 
ELSE s.unlocked_at_date 
END, 
CASE WHEN s.beecoins_claimed_at IS NOT NULL 
THEN s.beecoins_claimed_at 
ELSE s.unlocked_at_date 
END, 
NULL AS beecoins_fee, NULL AS beecoins_prize, NULL AS round, NULL AS code, NULL AS deep_link, NULL AS private, 
NULL AS pENDing_results, NULL AS tutorial_description, NULL AS tutorial_results, NULL AS priority, NULL AS contest, 
to_jsonb(bt.*) AS TYPE, NULL AS sport, NULL AS win, NULL AS winner_id, NULL AS odds_value, NULL AS num_ticket, 
NULL AS rank, NULL AS beecoins_bet, s.beecoins_win, s.beecoins_claimed, s.beecoins_claimed_at, NULL AS points, 
NULL AS points_pENDing, NULL AS ticket, NULL AS users, s.transactions, NULL AS status, NULL AS matches, 
NULL AS date_next, NULL AS timer_status, NULL AS timer_date
FROM get_sponsors(_user) s
JOIN beegames_types bt ON bt.slug = 'sponsor' 
AND CASE WHEN _type IS NOT NULL 
THEN bt.id = _type 
ELSE 1=1 
END 
AND CASE WHEN _beegames OR _beegame IS NOT NULL 
THEN bt.slug <> 'sponsor' 
ELSE 1=1 
END 
WHERE s.unlocked = true 
AND CASE WHEN _beecoins 
THEN s.beecoins_win > 0 
ELSE 1=1 
END

UNION ALL

-- rewards
/*SELECT ur.id, bt.name, NULL AS subtitle, NULL AS description, NULL AS tournament_name, ur.beecoins_claimed_at, ur.beecoins_claimed_at, NULL AS beecoins_fee, NULL AS beecoins_prize, NULL AS round, NULL AS code, NULL AS private, NULL AS pENDing_results, NULL AS tutorial_description, NULL AS tutorial_results, NULL AS contest, to_jsonb(bt.*) as type, NULL AS sport, NULL AS win, NULL AS winner_id, NULL AS odds_value, NULL AS num_ticket, NULL AS rank, NULL AS beecoins_bet, ur.beecoins_win, ur.beecoins_claimed, ur.beecoins_claimed_at, NULL AS points, NULL AS points_pENDing, NULL AS ticket, NULL AS users, ur.transactions
FROM users_rewards ur
JOIN beegames_types bt on bt.slug = 'reward' AND CASE WHEN _type IS NOT NULL THEN bt.id = _type ELSE 1=1 END AND CASE WHEN _beegames or _beegame IS NOT NULL THEN bt.slug <> 'reward' ELSE 1=1 END
WHERE user_id = _user AND CASE WHEN _beecoins THEN ur.beecoins_win > 0 AND ur.beecoins_claimed ELSE 1=1 END*/
SELECT u.id, bt.name, NULL AS subtitle, NULL AS description, NULL AS tournament_name, t.created_at, t.created_at, 
NULL AS beecoins_fee, NULL AS beecoins_prize, NULL AS round, NULL AS code, NULL AS deep_link, NULL AS private, 
NULL AS pENDing_results, NULL AS tutorial_description, NULL AS tutorial_results, NULL AS priority, NULL AS contest, 
to_jsonb(bt.*) AS TYPE, NULL AS sport, NULL AS win, NULL AS winner_id, NULL AS odds_value, NULL AS num_ticket, 
NULL AS rank, NULL AS beecoins_bet, t.amount AS beecoins_win, true AS beecoins_claimed, 
t.created_at AS beecoins_claimed_at, NULL AS points, NULL AS points_pENDing, NULL AS ticket, NULL AS users, 
u.transactions, NULL AS status, NULL AS matches, NULL AS date_next, NULL AS timer_status, NULL AS timer_date
FROM users u
JOIN tutorials tu ON tu.name = 'daily_reward'
JOIN transactions t ON t.id = any(u.transactions) AND t.operation = 'USR_CDT' AND t.amount = tu.value
JOIN beegames_types bt ON bt.slug = 'reward' 
AND CASE WHEN _type IS NOT NULL 
THEN bt.id = _type
ELSE 1=1 
END 
AND CASE WHEN _beegames OR _beegame IS NOT NULL 
THEN bt.slug <> 'reward' 
ELSE 1=1 
END
WHERE u.id = _user

UNION ALL

-- welcome gifts
SELECT u.id, bt.name, NULL AS subtitle, NULL AS description, NULL AS tournament_name, t.created_at, 
t.created_at, NULL AS beecoins_fee, NULL AS beecoins_prize, NULL AS round, NULL AS code, NULL AS deep_link, 
NULL AS private, NULL AS pENDing_results, NULL AS tutorial_description, NULL AS tutorial_results, NULL AS priority, 
NULL AS contest, to_jsonb(bt.*) AS TYPE, NULL AS sport, NULL AS win, NULL AS winner_id, NULL AS odds_value, 
NULL AS num_ticket, NULL AS rank, NULL AS beecoins_bet, t.amount AS beecoins_win, true AS beecoins_claimed, 
t.created_at as beecoins_claimed_at, NULL AS points, NULL AS points_pENDing, NULL AS ticket, NULL AS users, 
u.transactions, NULL AS status, NULL AS matches, NULL AS date_next, NULL AS timer_status, NULL AS timer_date
FROM users u
JOIN beecoins_settings bs ON bs.name = 'init_amount'
JOIN transactions t ON t.id = any(u.transactions) AND (t.operation = 'USR_CDT' AND t.beecoins_start = 0 
AND t.beecoins_END = bs.value OR t.operation = 'SPR_WLCM')
JOIN beegames_types bt ON bt.slug = 'gift' 
AND CASE WHEN _type IS NOT NULL 
THEN bt.id = _type 
ELSE 1=1 
END 
AND CASE WHEN _beegames OR _beegame IS NOT NULL 
THEN bt.slug <> 'gift' 
ELSE 1=1 
END
WHERE u.id = _user

ORDER BY priority, date_END DESC
LIMIT _limit OFFSET _offset;

END $BODY$;