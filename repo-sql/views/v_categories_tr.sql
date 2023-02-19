-- View: public.v_categories_tr

DROP VIEW IF EXISTS public.v_categories_tr;

CREATE OR REPLACE VIEW public.v_categories_tr
 AS
 SELECT c.id,
    c.sports,
    c.slug,
    tr.name,
    tr.lang_code AS lang
   FROM categories c
     JOIN categories_tr tr ON tr.category_id = c.id
     JOIN languages l ON l.code = tr.lang_code AND l.active;