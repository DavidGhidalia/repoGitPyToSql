
-- View: public.v_gifts

 DROP VIEW IF EXISTS public.v_gifts;

CREATE OR REPLACE VIEW public.v_gifts
 AS
 SELECT gt.id AS type_id, 
        gt.name, 
        gt.value AS reward, 
        tr.description, 
        tr.lang_code AS lang, 
        gl.level, 
        gl.unlocked_at, 
        g.id AS gift_id, 
        g.user_id, 
        g.level AS user_level, 
        g.contest_id, 
        g.logo, 
        g.code, 
        g.created_at, 
        g.updated_at, 
        g.expired_at
 FROM gifts_types gt
 LEFT JOIN gifts_levels gl ON gl.type_id = gt.id
 LEFT JOIN gifts_tr tr ON tr.type_id = gt.id
 LEFT JOIN gifts g ON g.type_id = gl.type_id
 LEFT JOIN languages l ON l.code = tr.lang_code AND l.active
 WHERE gt.active
 
 UNION 
 
 SELECT gt.id AS type_id, 
        gt.name, 
        gt.value AS reward, 
        tr.description, 
        tr.lang_code AS lang,
        gl.level, 
        gl.unlocked_at, 
        g.id AS gift_id, 
        g.user_id, 
        g.level AS user_level, 
        g.contest_id, 
        g.logo, 
        g.code, 
        g.created_at, 
        g.updated_at, 
        g.expired_at
 FROM gifts_types gt
 LEFT JOIN gifts_levels gl ON gl.type_id = gt.id
 LEFT JOIN gifts_tr tr ON tr.type_id = gt.id
 LEFT JOIN gifts g ON g.type_id = gl.type_id AND g.id IS NULL
 LEFT JOIN languages l ON l.code = tr.lang_code AND l.active
 WHERE gt.active;