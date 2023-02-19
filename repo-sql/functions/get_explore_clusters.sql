-- FUNCTION: public.get_explore_clusters(text, integer, lang, integer, integer)

DROP FUNCTION IF EXISTS public.get_explore_clusters(text, integer, lang, integer, integer);

CREATE OR REPLACE FUNCTION public.get_explore_clusters(
	_query text,
  _user integer,
  _lang lang default 'fr',
	_limit integer default 100,
  _offset integer default 0)
    RETURNS TABLE(explore_id integer, id integer, text character varying, 
    private boolean, created_at timestamp with time zone, updated_at timestamp with time zone, 
    content json, win boolean, hash text, roi numeric, odds_value numeric, stake integer, 
    bookmaker_id integer, comments bigint, likes bigint, liked boolean, shared boolean, 
    owner json, prognosis jsonb) 
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
  
  SELECT c.id, c.updated_at
  FROM clusters c, plainto_tsquery('french', _query) query
  WHERE query @@ c.text_search

  UNION 

  SELECT c.cluster, c.updated_at
  FROM comments c, plainto_tsquery('french', _query) query
  WHERE query @@ c.text_search

  UNION 

  SELECT c.id, c.updated_at
  FROM users u
  JOIN clusters c ON c.owner = u.id
  WHERE u.nickname % _query

  UNION

  SELECT c.id, c.updated_at
  FROM (
	  SELECT array_agg(distinct p.cluster) AS clusters
    FROM (
      SELECT array_agg(m.id) AS matches
	    FROM (
	      SELECT array_agg(t.id) AS teams
		    FROM teams t, plainto_tsquery('simple', _query) query
		  	WHERE query @@ t.name_search
	    ) q
	    JOIN matches m ON m.teams && q.teams and m.date::date > now() - interval '1' year
    ) r
    JOIN prognosis p ON p.match = any(r.matches)
	) s
  JOIN clusters c ON c.id = any(s.clusters)

  UNION
	
  SELECT c.id, c.updated_at
	FROM (
	  SELECT array_agg(distinct p.cluster) AS clusters
	  FROM (
	    SELECT array_agg(m.id) AS matches
	    FROM (
		    SELECT array_agg(t.id) AS tournaments
		    FROM tournaments t, plainto_tsquery('simple', _query) query
		    WHERE query @@ t.name_search
	    ) q
	    JOIN matches m on m.tournament = any(q.tournaments) AND m.date::date > now() - interval '1' year
		) r
	  JOIN prognosis p ON p.match = any(r.matches)
	) s
	JOIN clusters c ON c.id = any(s.clusters)

  ORDER BY updated_at desc
  LIMIT _limit OFFSET _offset
) q;

RETURN QUERY
SELECT e.id AS explore_id, c.*
FROM explores e
LEFT JOIN get_clusters(cids, _user, _lang) c ON c.id IS NOT NULL
WHERE e.name = 'clusters' AND e.active
ORDER BY c.updated_at DESC;

END
$BODY$;