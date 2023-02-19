 DROP VIEW IF EXISTS public.v_matches_without_result;


CREATE VIEW public.v_matches_without_result AS
 SELECT m.id,
    m.date,
    c.name AS category,
    s.name AS sport,
    t.name AS tournament,
    json_agg(te.name) AS teams,
    json_agg(DISTINCT p.id) AS pronos,
    m.date AS created_at,
    m.date AS updated_at
   FROM ((((((public.matches m
     JOIN public.odds o ON ((o.match = m.id)))
     JOIN public.sports s ON ((m.sport = s.id)))
     JOIN public.categories c ON ((m.category = c.id)))
     JOIN public.tournaments t ON ((m.tournament = t.id)))
     JOIN public.teams te ON ((te.id = ANY (m.teams))))
     LEFT JOIN public.prognosis p ON ((p.match = m.id)))
  WHERE ((m.result IS NULL) AND ((m.date)::date >= '2021-06-01'::date) AND ((m.date)::date <= (now())::date))
  GROUP BY m.id, m.date, c.name, s.name, t.name, t."order"
  ORDER BY t."order";