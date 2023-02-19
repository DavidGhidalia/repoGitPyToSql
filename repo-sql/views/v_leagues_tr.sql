-- View: public.v_leagues_tr

DROP VIEW  iF EXISTS public.v_leagues_tr;

CREATE OR REPLACE VIEW public.v_leagues_tr
 AS
 SELECT l.id,
    l.created_at,
    l.updated_at,
    tr.name,
    tr.group_name,
    tr.lang_code AS lang
   FROM leagues l
     JOIN leagues_tr tr ON tr.league_id = l.id
     JOIN languages lg ON lg.code = tr.lang_code AND lg.active;