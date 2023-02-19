-- FUNCTION: public.get_clusters_comments(integer, integer)

DROP FUNCTION IF EXISTS public.get_clusters_comments(integer, integer) cascade;

CREATE OR REPLACE FUNCTION public.get_clusters_comments(
  _cluster integer,
	_user integer
  ) RETURNS TABLE(
    id integer,
    cluster integer,
	  text varchar(1024),
	  visible boolean,
	  moderator integer,
	  parent_id integer,
	  created_at timestamp with time zone,
	  updated_at timestamp with time zone,
	  likes bigint,
	  comments bigint,
	  liked boolean,
	  owner jsonb,
	  replies json
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY

WITH RECURSIVE q AS (
	SELECT c1.id, COUNT(DISTINCT l1.id) likes, COUNT(DISTINCT c2.id) "comments", 
  EXISTS (SELECT 1 FROM likes l2 WHERE l2.comment_id = c1.id AND l2.owner = _user) liked
	FROM comments c1
	LEFT JOIN comments c2 ON c2.parent_id = c1.id AND c2.visible
	LEFT JOIN likes l1 ON l1.comment_id = c1.id
  WHERE c1.visible
	GROUP BY c1.id
),
c AS (
    SELECT co.id, co.cluster, co.text, co.visible, co.moderator, co.parent_id, co.created_at, co.updated_at, 0 
    AS lvl, q.likes, q.comments, q.liked, jsonb_build_object('id', u.id, 'nickname', u.nickname, 
    'avatar', u.avatar, 'verified', u.verified, 'roi', pf.roi) AS OWNER
    FROM   comments co
	JOIN users u ON u.id = co.owner
  JOIN performances pf ON pf.user_id = u.id
	JOIN q ON q.id = co.id
    WHERE  co.cluster = _cluster AND co.parent_id IS NULL AND co.visible 
    AND NOT (_user = any(u.blockers)) AND NOT (_user = any(co.blockers))
  UNION ALL
    SELECT co.id, co.cluster, co.text, co.visible, co.moderator, co.parent_id, co.created_at, 
    co.updated_at, c.lvl + 1, q.likes, q.comments, q.liked, 
    jsonb_build_object('id', u.id, 'nickname', u.nickname, 'avatar', u.avatar, 'verified', u.verified, 
    'roi', pf.roi) AS OWNER
    FROM   comments co
	JOIN users u ON u.id = co.owner
  JOIN performances pf ON pf.user_id = u.id
	JOIN q ON q.id = co.id
    JOIN   c ON co.parent_id = c.id AND co.visible AND NOT (_user = any(u.blockers)) 
    AND NOT (_user = any(co.blockers))
),
maxlvl AS (
  SELECT max(lvl) maxlvl FROM c
),
j AS (
    SELECT c.*, json '[]' replies
    FROM   c, maxlvl
    WHERE  c.lvl = maxlvl OR (c.lvl = 0 AND c.comments = 0)
  UNION ALL
    SELECT   (c).*, array_to_json(array_agg(j) || array(SELECT r
                                                        FROM   (SELECT l.*, json '[]' replies
                                                                FROM   c l, maxlvl
                                                                WHERE  l.parent_id = (c).id
                                                                AND    l.lvl < maxlvl
                                                                AND    l.comments = 0) r)) replies
    FROM     (SELECT c, j
              FROM   c
              JOIN   j ON j.parent_id = c.id
			        ORDER BY c.created_at, j.created_at) v
    GROUP BY v.c
)

SELECT j.id, j.cluster, j.text, j.visible, j.moderator, j.parent_id, j.created_at, 
j.updated_at, j.likes, j.comments, j.liked, j.owner, j.replies
FROM   j
WHERE  j.lvl = 0
ORDER BY j.created_at DESC;

END $BODY$;