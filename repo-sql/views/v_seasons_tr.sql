-- View: public.v_seasons_tr

DROP VIEW IF EXISTS public.v_seasons_tr;

CREATE OR REPLACE VIEW public.v_seasons_tr
 AS
 SELECT s.id,
    s.league,
    s.start_date,
    s.end_date,
    s.year,
    s.tournament,
    s.created_at,
    s.updated_at,
    tr.name,
    tr.standings,
    tr.lang_code AS lang
   FROM seasons s
     JOIN seasons_tr tr ON tr.season_id = s.id AND tr.league_id = s.league
     JOIN languages l ON l.code = tr.lang_code AND l.active;