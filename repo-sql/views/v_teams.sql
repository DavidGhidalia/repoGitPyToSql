-- View: public.v_teams

DROP VIEW IF EXISTS public.v_teams;

CREATE OR REPLACE VIEW public.v_teams
 AS
 SELECT teams.id,
    teams.gender,
    teams.name AS full_name,
    ( SELECT
                CASE
                    WHEN teams.sport <> 5 THEN teams.name::text
                    ELSE
                    CASE
                        WHEN teams.name::text ~~ '%/%'::text THEN teams.name::text
                        ELSE (split_part(teams.name::text, ','::text, 1) || ', '::text) 
                        || "left"(btrim(split_part(teams.name::text, ','::text, 2)), 1)
                    END
                END AS "case") AS name,
    teams.sport,
    teams.country,
    teams.tournaments,
    teams.slug,
    teams.ranking,
    teams.base_url_medium AS url_medium,
    teams.base_url_big AS url_big,
    teams.rankings
   FROM teams;