-- View: public.v_users_notifs

DROP VIEW IF EXISTS public.v_users_notifs;

CREATE OR REPLACE VIEW public.v_users_notifs
 AS
 SELECT u.id AS user_id,
    ns.id AS notif_id,
    ns.label,
    ns.type,
    ns.active,
    ns.slug,
    ns.admin,
    ns.is_displayed,
        CASE
            WHEN ns.is_push THEN
            CASE
                WHEN u.notifications THEN
                CASE
                    WHEN u.notification_ids IS NULL OR (ns.id = ANY (u.notification_ids)) THEN
                    CASE
                        WHEN ns.admin THEN u.admin
                        ELSE true
                    END
                    ELSE false
                END
                ELSE false
            END
            ELSE false
        END AS is_push
   FROM users u
  JOIN notifications_settings ns ON ns.active;