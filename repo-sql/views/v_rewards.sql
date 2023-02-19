-- View: public.v_rewards

DROP VIEW IF EXISTS public.v_rewards;

CREATE OR REPLACE VIEW public.v_rewards
 AS
 SELECT DISTINCT ON (r.id, u.id) r.id,
 		r.next_id,
		r.beecoins_min,
		r.beecoins_max,
		r.created_at,
		r.updated_at,
		u.id AS user_id,
		ur.date,
		ur.beecoins_win,
		ur.beecoins_claimed,
		ur.beecoins_claimed_at
 FROM rewards r
 LEFT JOIN users u ON u.reward_id IS NOT NULL
 LEFT JOIN users_rewards ur ON ur.user_id = u.id AND ur.reward_id = r.id 
 AND ur.date > (date_trunc('day', now()) - interval '6' day)::date AND u.reward_id >= r.id
 ORDER BY r.id, u.id, ur.date DESC;