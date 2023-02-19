-- View: public.v_odds_type_tr

DROP VIEW IF EXISTS public.v_odds_type_tr;

CREATE OR REPLACE VIEW public.v_odds_type_tr
 AS
 SELECT o.id,
    o.field_id,
    o.name,
    o.value,
    o.field_label,
    o.created_at,
    o.updated_at,
    tr.field_name,
    tr.label,
    tr.lang_code AS lang
   FROM odds_type o
     JOIN odds_type_tr tr ON tr.odds_type_id = o.id
     JOIN languages l ON l.code = tr.lang_code AND l.active;