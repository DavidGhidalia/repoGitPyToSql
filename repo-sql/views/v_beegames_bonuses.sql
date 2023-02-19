-- View: public.v_beegames_bonuses

DROP VIEW IF EXISTS public.v_beegames_bonuses;

CREATE OR REPLACE VIEW public.v_beegames_bonuses
 AS
 SELECT bb.id,
    bb.name,
    bb.active,
    bb.weight,
    bb.slug,
    bb.logo,
    bb.description,
    b.id AS beegame_id,
    u.user_id,
    (EXISTS ( SELECT 1
           FROM beegames_prognosis bp
             JOIN beegames_tickets bt ON bt.id = bp.ticket_id
          WHERE bt.beegame_id = b.id AND bt.user_id = u.user_id AND bb.id = any(bp.bonuses))) AS played
   FROM beegames_bonuses bb
     JOIN beegames b ON bb.id = ANY (b.bonuses)
     CROSS JOIN LATERAL unnest(b.users) u(user_id)
  WHERE bb.active;