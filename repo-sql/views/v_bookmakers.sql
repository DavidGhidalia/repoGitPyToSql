-- View: public.v_bookmakers

DROP VIEW IF EXISTS public.v_bookmakers CASCADE;

CREATE OR REPLACE VIEW public.v_bookmakers
 AS
 SELECT b.id,
    b.name,
    b.slug,
    b.url,
    b.created_at,
    b.updated_at,
    b.country,
    b.top,
    b.bonus,
    b.currency,
    b.interest,
    b.odds_interest,
    b.infos,
    b.active,
    b.parent_id,
    b.comparator,
    b.beegame
   FROM bookmakers b
  WHERE b.active;