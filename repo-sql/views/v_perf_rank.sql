-- View: public.v_perf_rank

 DROP VIEW IF EXISTS public.v_perf_rank;

CREATE OR REPLACE VIEW public.v_perf_rank
 AS
 SELECT u.id,
    r1.rank as general_rank,
    r2.rank as monthly_rank,
    r3.rank as j30_rank
   FROM users u
     LEFT JOIN get_ranking('top') r1 ON r1.id = u.id
     LEFT JOIN get_ranking('monthly') r2 ON r2.id = u.id
     LEFT JOIN get_ranking('j30') r3 on r3.id = u.id;