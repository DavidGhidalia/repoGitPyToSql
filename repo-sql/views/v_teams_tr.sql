-- View: public.v_teams_tr

DROP VIEW IF EXISTS public.v_teams_tr;

CREATE OR REPLACE VIEW public.v_teams_tr
 AS
 SELECT t.id,
    t.gender,
    t.sport,
    t.country,
    t.tournaments,
    t.slug,
    t.ranking,
    t.base_url_big,
    t.base_url_medium,
    t.rankings,
    tr.name,
    tr.lang_code AS lang
   FROM teams t
     JOIN teams_tr tr ON tr.team_id = t.id
     JOIN languages l ON l.code = tr.lang_code AND l.active;