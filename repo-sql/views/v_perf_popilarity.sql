-- View: public.v_perf_popularity

 DROP VIEW IF EXISTS public.v_perf_popularity;

CREATE OR REPLACE VIEW public.v_perf_popularity
 AS
 SELECT q1.owner,
    sum(q1.likes + q2.comments) AS popularity
   FROM ( SELECT c.owner,
            sum(
                CASE
                    WHEN c.owner <> l.owner THEN 1
                    ELSE 0
                END) AS likes
           FROM clusters c
             LEFT JOIN likes l ON l.cluster = c.id
          GROUP BY c.owner) q1,
    ( SELECT c.owner,
            sum(
                CASE
                    WHEN c.owner <> co.owner THEN 1
                    ELSE 0
                END) AS comments
           FROM clusters c
             LEFT JOIN comments co ON co.cluster = c.id AND co.visible
          GROUP BY c.owner) q2
  WHERE q1.owner = q2.owner
  GROUP BY q1.owner
 HAVING sum(q1.likes + q2.comments) > 0::numeric;