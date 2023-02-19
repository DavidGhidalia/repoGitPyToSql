-- View: public.v_tutorials

DROP VIEW IF EXISTS public.v_tutorials;

CREATE OR REPLACE VIEW public.v_tutorials
 AS
 SELECT t.id,
    t.name,
    t.active,
    t.admin,
    json_agg(tu.*) AS users
   FROM tutorials t
     JOIN tutorials_users tu ON tu.tutorial_id = t.id 
  WHERE t.active
  GROUP BY t.id;