-- View: public.v_filters_tr

DROP VIEW IF EXISTS public.v_filters_tr;

CREATE OR REPLACE VIEW public.v_filters_tr
 AS
 SELECT f.id,
    f.key,
    f.active,
    f."limit",
    f."order",
    tr.value,
    tr.title,
    tr.lang_code AS lang
   FROM filters f
     JOIN filters_tr tr ON tr.filter_id = f.id
     JOIN languages l ON l.code = tr.lang_code AND l.active;