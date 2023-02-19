-- View: public.v_explores_tr

 DROP VIEW IF EXISTS public.v_explores_tr;

CREATE OR REPLACE VIEW public.v_explores_tr
 AS
 SELECT e.id,
    e.name,
    e.limit,
    e.active,
    tr.label,
    tr.lang_code AS lang
   FROM explores e
     JOIN explores_tr tr ON tr.explore_id = e.id
     JOIN languages l ON l.code = tr.lang_code AND l.active;