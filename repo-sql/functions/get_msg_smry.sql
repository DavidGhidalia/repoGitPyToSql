-- FUNCTION: public.get_msg_smry(bigint, numeric, numeric)

 DROP FUNCTION IF EXISTS public.get_msg_smry(integer, lang, bigint, numeric, numeric);

CREATE OR REPLACE FUNCTION public.get_msg_smry(
  _notifId integer,
  _lang lang,
  _rank bigint,
  _roi numeric,
	_roi_evo numeric)
	RETURNS TABLE(
    notif_id integer,
    lang_code lang,
    title character varying,
    message text,
    messages_tr jsonb
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN
RETURN QUERY

SELECT tr.notif_id, tr.lang_code, tr.title, replace(tr.message, '{{roi}}'::text, ROUND(_roi * 100, 1)::text), (select jsonb_object(array_agg(ntr.lang_code::text), array_agg(replace(ntr.message, '{{roi}}'::text, ROUND(_roi * 100, 1)::text))) from notifications_tr ntr where ntr.notif_id=tr.notif_id and ntr.slug=tr.slug) AS messages_tr
FROM notifications_tr tr
WHERE tr.notif_id = $1
AND tr.lang_code = $2
AND CASE WHEN _rank <= 10 
THEN tr.slug = 'bvr_smry_top' 
ELSE 
CASE WHEN _roi_evo > 0 
THEN tr.slug = 'bvr_smry_evo' 
ELSE tr.slug = 'bvr_smry' 
END 
END;

END; 
$BODY$;