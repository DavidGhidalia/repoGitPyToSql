-- FUNCTION: public.get_latest_results(character varying, integer)

DROP FUNCTION IF EXISTS public.get_latest_results(character varying, integer) cascade;

CREATE OR REPLACE FUNCTION public.get_latest_results(
    _type character varying,
    _user integer
  ) RETURNS TABLE(
    id integer,
    latest_results boolean[]
  ) LANGUAGE 'sql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$

SELECT a.owner,
    array_agg(a.win) AS latest_results
   FROM ( SELECT a_1.owner,
            b.win,
            row_number() OVER (PARTITION BY a_1.owner 
            ORDER BY a_1.created_at DESC) 
            AS seqnum
           FROM clusters a_1
             LEFT JOIN clusters b USING (id)
          WHERE a_1.owner = $2 AND a_1.win IS NOT NULL AND a_1.status IS DISTINCT 
          FROM 'cancelled'::cluster_status AND CASE $1 
          WHEN 'monthly' 
          THEN a_1.created_at >= date_trunc('month', now()) 
          WHEN 'j30' 
          THEN a_1.created_at >= CURRENT_DATE - interval '30 day' 
          ELSE 1=1 
          END) a
  WHERE a.seqnum <= 6
  GROUP BY a.owner;

$BODY$;