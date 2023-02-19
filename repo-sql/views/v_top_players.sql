-- View: public.v_top_players

DROP VIEW IF EXISTS public.v_top_players;

CREATE OR REPLACE VIEW public.v_top_players
 AS
 SELECT u.id AS user_id
   FROM users u
     JOIN performances p ON p.user_id = u.id
     JOIN users_settings us ON us.type::text = 'top_player'::text AND us.ranking::text = 'top'::text 
     AND p.general_rank <= us."position" OR us.type::text = 'top_player'::text 
     AND us.ranking::text = 'monthly'::text AND p.monthly_rank <= us."position"
  WHERE u.top_player_active;