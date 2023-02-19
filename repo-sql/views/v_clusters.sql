
 DROP VIEW IF EXISTS public.v_clusters;

CREATE OR REPLACE VIEW public.v_clusters AS
 SELECT c.id,
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
    c.bookmaker,
    c.bookmaker_id,
    b.name AS bookmaker_name,
    u.nickname AS user_name
   FROM ((public.clusters c
     JOIN public.users u ON ((u.id = c.owner)))
     JOIN v_bookmakers b ON ((b.id = c.bookmaker_id)));