-- View: public.v_tournaments_tr

 DROP VIEW IF EXISTS public.v_tournaments_tr;

CREATE OR REPLACE VIEW public.v_tournaments_tr
 AS
 SELECT t.id,
    t.unique_id,
    t.level,
    t.sport,
    t.category,
    t.slug,
    t.major,
    t."order",
    t.ground_type,
    t.info,
    tr.name,
    tr.lang_code AS lang
   FROM tournaments t
     JOIN tournaments_tr tr ON tr.tournament_id = t.id
     JOIN languages l ON l.code = tr.lang_code AND l.active;