-- View: public.v_perf_latest_results

 DROP VIEW IF EXISTS public.v_perf_latest_results;

CREATE OR REPLACE VIEW public.v_perf_latest_results
 AS
 SELECT a.owner,
    array_agg(a.win) AS latest_results
   FROM ( SELECT a_1.owner,
            b.win,
            row_number() OVER (PARTITION BY a_1.owner ORDER BY a_1.created_at DESC) AS seqnum
           FROM clusters a_1
             LEFT JOIN clusters b USING (id)
          WHERE a_1.win IS NOT NULL AND a_1.status IS DISTINCT FROM 'cancelled'::cluster_status) a
  WHERE a.seqnum <= 6
  GROUP BY a.owner;