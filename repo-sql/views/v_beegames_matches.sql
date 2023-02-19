-- View: public.v_beegames_matches

DROP VIEW IF EXISTS public.v_beegames_matches;

CREATE OR REPLACE VIEW public.v_beegames_matches
 AS
 SELECT b.id,
    b.name,
    b.subtitle,
    b.private,
    m.id AS match_id,
    m.date AS match_date,
    m.sport,
    ( SELECT array_agg(t_1.name ORDER BY (
                CASE
                    WHEN t_1.id = m.home_team THEN 0
                    ELSE 1
                END)) AS array_agg
           FROM teams t_1
          WHERE t_1.id = ANY (m.teams)) AS teams,
    t.name AS tournament,
    m.result,
    m.result_live,
    m.status,
    m.match_status,
    (EXISTS ( SELECT 1
           FROM beegames_prognosis bp
          WHERE bp.match_id = m.id)) AS played
   FROM beegames b
     JOIN matches m ON m.date >= b.date_start AND m.date <= b.date_end AND
        CASE
            WHEN b.sport_id IS NOT NULL THEN m.sport = b.sport_id
            ELSE 1 = 1
        END AND
        CASE
            WHEN b.tournaments <> '{}'::integer[] THEN m.tournament = ANY (b.tournaments)
            ELSE 1 = 1
        END
     JOIN tournaments t ON t.id = m.tournament;