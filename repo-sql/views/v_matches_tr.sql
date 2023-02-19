-- View: public.v_matches_tr

 DROP VIEW IF EXISTS public.v_matches_tr;

CREATE OR REPLACE VIEW public.v_matches_tr
 AS
 SELECT m.id,
    m.date,
    m.round,
    m.teams,
    m.result,
    m.sport,
    m.category,
    m.tournament,
    m.created_at,
    m.updated_at,
    m.home_team,
    m.teams_full,
    m.status,
    m.season,
    m.match_status,
    m.leagues,
    tr.lineups,
    tr.venue,
    tr.lang_code AS lang
   FROM matches m
     JOIN matches_tr tr ON tr.match_id = m.id
     JOIN languages l ON l.code = tr.lang_code AND l.active;