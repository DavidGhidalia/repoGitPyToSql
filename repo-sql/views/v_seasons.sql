-- View: public.v_seasons

DROP VIEW IF EXISTS public.v_seasons;

CREATE OR REPLACE VIEW public.v_seasons
 AS
 SELECT s.id,
    s.league AS league_id,
    s.tournament AS tournament_id,
    s.name,
    s.start_date,
    s.end_date,
    s.year,
    t.sport,
    row_to_json(l.*) AS league,
    row_to_json(t.*) AS tournament,
    array_to_json(array_agg(json_build_object('tie_break_rule', j.value ->> 'tie_break_rule'::text, 'round', 
    j.value ->> 'round'::text, 'type', j.value ->> 'type'::text, 'name', st.name, 'statistics', 
    j.value ->> 'statistics'::text, 'standings', (j.value ->> 'standings'::text)::json))) AS standings,
    s.created_at,
    s.updated_at
   FROM seasons s
     CROSS JOIN LATERAL json_array_elements(s.standings) j(value)
     JOIN standings st ON st.type::text = (j.value ->> 'type'::text) AND st.active
     JOIN leagues l ON l.id = s.league
     JOIN tournaments t ON t.id = s.tournament
  WHERE s.standings IS NOT NULL AND s.start_date <= now()::date AND s.end_date >= now()::date
  GROUP BY s.id, s.league, t.sport, l.id, t.id;