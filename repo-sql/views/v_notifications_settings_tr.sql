-- View: public.v_notifications_settings_tr

DROP VIEW IF EXISTS public.v_notifications_settings_tr;

CREATE OR REPLACE VIEW public.v_notifications_settings_tr
  AS
  SELECT ns.id,
    ns_tr.label,
    nt_tr.label AS type,
    ns.active,
    ns.slug,
    ns.admin,
    ns_tr.lang_code AS lang
  FROM notifications_settings ns
    JOIN notifications_types nt ON nt.id = ns.type
    JOIN notifications_settings_tr ns_tr ON ns_tr.notif_setting_id = ns.id
    JOIN notifications_types_tr nt_tr ON nt_tr.notif_type_id = nt.id AND ns_tr.lang_code = nt_tr.lang_code
    JOIN languages l ON l.code = ns_tr.lang_code AND l.code = nt_tr.lang_code AND l.active;
