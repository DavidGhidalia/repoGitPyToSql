-- FUNCTION: public.get_clusters_relevant(integer[], integer)

DROP FUNCTION IF EXISTS public.get_clusters_relevant(integer[], integer);

CREATE OR REPLACE FUNCTION public.get_clusters_relevant(
	_cids integer[],
	_owner integer)
    RETURNS TABLE(id integer, text character varying, private boolean, created_at timestamp with time zone, updated_at timestamp with time zone, content json, win boolean, hash text, roi numeric, odds_value numeric, stake integer, bookmaker_id integer, beecoins_bet numeric, beecoins_win numeric, beecoins_claimed boolean, beecoins_claimed_at timestamptz, comments bigint, likes bigint, liked boolean, shared boolean, owner json, prognosis jsonb) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 1000

AS $BODY$
DECLARE
cids integer[];
BEGIN
SELECT array_agg(q.id) INTO cids
FROM (
  SELECT c.id
  FROM (
    SELECT u.following, cs.active
    FROM users u
    JOIN clusters_settings cs ON cs.name = 'following'
    WHERE u.id = _owner
  ) q
  JOIN clusters c ON c.id = any(_cids) AND CASE WHEN q.active 
  THEN c.owner = any(q.following) 
  ELSE 1=1 
  END

  UNION 

  SELECT c.id
  FROM clusters c
  JOIN performances p ON p.user_id = c.owner
  JOIN clusters_settings cs ON cs.name = 'top'
  WHERE c.id = any(_cids) AND CASE WHEN cs.active 
  THEN p.general_rank <= cs.value 
  ELSE 1=1 
  END 

  UNION 

  SELECT c.id
  FROM clusters c
  JOIN performances p ON p.user_id = c.owner
  JOIN clusters_settings cs ON cs.name = 'monthly'
  WHERE c.id = any(_cids) AND CASE WHEN cs.active 
  THEN p.monthly_rank <= cs.value 
  ELSE 1=1 
  END 

  UNION

  SELECT c.id
  FROM clusters c
  JOIN performances p ON p.user_id = c.owner
  JOIN clusters_settings cs ON cs.name = 'j30'
  WHERE c.id = any(_cids) AND CASE WHEN cs.active 
  THEN p.j30_rank <= cs.value 
  ELSE 1=1 
  END 

  UNION

  SELECT c.id
  FROM clusters c
  JOIN users u ON u.id = c.owner
  JOIN clusters_settings cs ON cs.name = 'verified'
  WHERE c.id = any(_cids) AND CASE WHEN cs.active 
  THEN u.verified 
  ELSE 1=1 
  END

  UNION

  SELECT c.id
  FROM clusters c
  JOIN users u ON u.id = c.owner
  JOIN clusters_settings cs ON cs.name = 'vip'
  WHERE c.id = any(_cids) AND CASE WHEN cs.active 
  THEN u.vip 
  ELSE 1=1 
  END
) q;

RETURN QUERY
SELECT 
  r.id,
	c.text,
	c.private,
	c.created_at,
	c.updated_at,
	c.content,
	c.win,
	c.hash,
	c.roi,
	c.odds_value,
	c.stake,
	c.bookmaker_id,
  c.beecoins_bet,
  c.beecoins_win,
  c.beecoins_claimed,
  c.beecoins_claimed_at,
	r.comments,
	r.likes,
	r.liked,
	r.shared,
	r.owner,
	r.prognosis
FROM(
    SELECT 
        clusters.id,
        clusters.liked AS liked,
        clusters.shared AS shared,
        clusters.comments AS comments,
        clusters.likes AS likes,
        json_build_object('id',u.id,'nickname',u.nickname,'avatar',u.avatar,'followers',u.followers::integer[], 
        'roi', u.roi, 'followed', clusters.followed) AS OWNER,
        jsonb_agg(json_build_object('id', p.id, 'sport', p.sport, 'match', 
        json_build_object('id', m.id, 'date', m.date, 'round', m.round, 'result', m.result, 
        'status', m.status, 'sport', row_to_json(s.*), 'category', row_to_json(c.*), 
        'tournament', row_to_json(ts.*), 'created_at', m.created_at, 'updated_at', m.updated_at, 
        'home_team', m.home_team, 'teams', (SELECT json_agg(t_1.* 
        ORDER BY CASE WHEN t_1.id = m.home_team 
        THEN 0 
        ELSE 1 
        END) 
        AS json_agg 
        FROM v_teams t_1 
        WHERE t_1.id = ANY (m.teams))), 'type_id', p.type_id, 'content', p.content, 
        'win', p.win, 'status', p.status, 'cluster', p.cluster, 'created_at', p.created_at, 
        'updated_at', p.updated_at)) AS prognosis
    FROM(
        SELECT 
            c.id,
            c.owner,
            c.text,
            c.private,
            c.created_at,
            c.updated_at,
            c.content,
            c.win,
            c.hash,
            c.roi,
            c.odds_value,
            c.stake,
            c.bookmaker_id,
            count(DISTINCT(co.*)) AS comments,
            count(DISTINCT(l.*)) as likes,
            (CASE WHEN _owner IS NOT NULL THEN (
              SELECT CASE WHEN count(1) > 0 
              THEN true 
              ELSE false 
              END
              FROM likes
              WHERE likes.owner = _owner AND cluster=c.id AND likes.comment_id IS NULL) 
              END) AS liked,
            (CASE WHEN _owner IS NOT NULL 
            THEN (
              SELECT CASE WHEN count(1) > 0 
              THEN true ELSE false 
              END
              FROM shares
              WHERE shares.owner = _owner AND cluster=c.id) 
              END) AS shared,
              (CASE WHEN _owner IS NOT NULL THEN (
              SELECT CASE WHEN _owner = ANY(u.followers) 
              THEN true 
              ELSE false 
              END
              FROM users u
              WHERE u.id = c.owner) END) AS followed
        FROM clusters c
        LEFT JOIN comments co ON c.id = co.cluster AND co.visible
        LEFT JOIN likes l ON c.id = l.cluster AND l.comment_id IS NULL
        WHERE c.private = false
        AND c.id = ANY(cids)
		    GROUP BY c.id
        ) clusters
    INNER JOIN users u ON clusters.owner = u.id
    INNER JOIN prognosis p ON p.cluster = clusters.id 
    INNER JOIN matches m ON m.id = p.match
    INNER JOIN sports s ON s.id = m.sport
    INNER JOIN tournaments ts ON ts.id = m.tournament
    INNER JOIN categories c ON c.id = m.category
    GROUP BY
        clusters.id,
        clusters.liked,
        clusters.shared,
        clusters.comments,
        clusters.likes,
        clusters.followed, 
        u.id)r
    INNER JOIN clusters c ON c.id = r.id
    ORDER BY c.updated_at DESC;
	END
$BODY$;