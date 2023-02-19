-- View: public.v_markets_tr

DROP VIEW IF EXISTS public.v_markets_tr;

CREATE OR REPLACE VIEW public.v_markets_tr
 AS
 SELECT m.id,
    m.market_id,
    m.group_name,
    m.name,
    m.priority,
    m.visible,
    m.sport,
    m."limit",
    m.sorted,
    m.columns,
    m.with_label_point,
    m.fixed,
    m.sr_name,
    tr.label,
    tr.type_label,
    tr.description,
    tr.lang_code AS lang
   FROM markets m
     JOIN markets_tr tr ON tr.market_id = m.market_id
     JOIN languages l ON l.code = tr.lang_code AND l.active;