-- FUNCTION: public.get_msg_rslt(integer, lang, boolean, bigint, double precision, numeric, integer)

DROP FUNCTION IF EXISTS public.get_msg_rslt(integer, lang, boolean, bigint, double precision, numeric, integer);

CREATE OR REPLACE FUNCTION public.get_msg_rslt(
  _notifId integer,
  _lang lang,
	_win boolean,
	_streak bigint,
	_rate double precision,
	_roi numeric,
	_rank integer)
  RETURNS TABLE(
    notif_id integer,
    lang_code lang,
    title character varying,
    message text,
    messages_tr jsonb
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN
RETURN QUERY

SELECT tr.notif_id, tr.lang_code, tr.title, replace(replace(replace(tr.message, '{{streak}}'::text, _streak::text), '{{roi}}'::text, ROUND(_roi * 100, 1)::text), '{{rank}}'::text, _rank::text) as message, (select jsonb_object(array_agg(ntr.lang_code::text), array_agg(replace(replace(replace(ntr.message, '{{streak}}'::text, _streak::text), '{{roi}}'::text, ROUND(_roi * 100, 1)::text), '{{rank}}'::text, _rank::text))) from notifications_tr ntr where ntr.notif_id=tr.notif_id and ntr.slug=tr.slug) AS messages_tr
FROM notifications_tr tr
WHERE tr.notif_id = $1 
AND tr.lang_code = $2 
AND CASE WHEN _win THEN CASE WHEN _streak > 1 THEN tr.slug = 'bvr_rslt_wstrk' ELSE tr.slug = 'bvr_rslt_w' END ELSE CASE WHEN _rate >= 0.75 THEN tr.slug = 'bvr_rslt_lnrly' ELSE tr.slug = 'bvr_rslt_l' END END;

END $BODY$;