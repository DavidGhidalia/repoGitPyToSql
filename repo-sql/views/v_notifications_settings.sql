-- View: public.v_notifications_settings

DROP VIEW IF EXISTS public.v_notifications_settings;

CREATE OR REPLACE VIEW public.v_notifications_settings
 AS
 SELECT ns.id,
    ns.label,
    nt.label AS type,
    ns.active,
    ns.slug,
    ns.admin
   FROM notifications_settings ns
     JOIN notifications_types nt ON nt.id = ns.type;