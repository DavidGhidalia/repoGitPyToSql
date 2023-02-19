-- View: public.v_clusters_authorized

DROP VIEW IF EXISTS public.v_clusters_authorized;

CREATE OR REPLACE VIEW public.v_clusters_authorized
 AS
 SELECT q.user_id,
    q.nb_clusters < q.post_limit AS authorized,
    q.time_interval - date_part('epoch'::text, now() - q.created_at_last)::integer AS time_diff
   FROM ( SELECT u.id AS user_id,
            cs1.value AS time_interval,
            cs2.value AS post_limit,
            count(c.id) AS nb_clusters,
            max(c.created_at) AS created_at_last
           FROM users u
             LEFT JOIN clusters_settings cs1 ON cs1.name::text = 'time_interval'::text
             LEFT JOIN clusters_settings cs2 ON cs2.name::text = 'post_limit'::text
             LEFT JOIN clusters c ON c.owner = u.id 
             AND c.created_at >= (now() - '00:00:01'::interval * cs1.value::double precision)
          GROUP BY u.id, cs1.value, cs2.value) q;