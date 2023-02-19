-- View: public.v_tickets_without_result

DROP VIEW IF EXISTS public.v_tickets_without_result;

CREATE OR REPLACE VIEW public.v_tickets_without_result
 AS
 SELECT c.id,
    c.user_id,
    sum(
        CASE
            WHEN p.win = true THEN 1
            ELSE 0
        END) AS p_wins,
    sum(
        CASE
            WHEN p.win = false THEN 1
            ELSE 0
        END) AS p_losses,
    count(p.id) AS p_total,
    array_agg(distinct p.match_id) AS matches
   FROM beegames_tickets c
     JOIN beegames_prognosis p ON p.ticket_id = c.id
  WHERE c.win IS NULL
  GROUP BY c.id
 HAVING sum(
        CASE
            WHEN p.win = true THEN 1
            ELSE 0
        END) = count(p.id) OR sum(
        CASE
            WHEN p.win = false THEN 1
            ELSE 0
        END) > 0;