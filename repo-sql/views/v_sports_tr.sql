-- View: public.v_sports_tr

DROP VIEW IF EXISTS public.v_sports_tr;

CREATE OR REPLACE VIEW public.v_sports_tr
 AS
 SELECT s.id,
    s.slug,
    s.active,
    s.sr_id,
    s.market,
    s.market_id,
    s.sportradar,
    s.ball_icon_url,
    tr.name,
    tr.short_name,
    tr.label_point,
    tr.label_set,
    tr.lang_code AS lang
   FROM sports s
     JOIN sports_tr tr ON tr.sport_id = s.id
     JOIN languages l ON l.code = tr.lang_code AND l.active;