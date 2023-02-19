-- View: public.v_sponsors_tr

DROP VIEW IF EXISTS public.v_sponsors_tr;

CREATE OR REPLACE VIEW public.v_sponsors_tr
 AS
 SELECT s.id,
    s.name,
    s.logo,
    s.active,
    s.toast,
    tr.description,
    tr.lang_code AS lang
   FROM sponsors_settings s
     JOIN sponsors_tr tr ON tr.setting_id = s.id
     JOIN languages l ON l.code = tr.lang_code AND l.active;