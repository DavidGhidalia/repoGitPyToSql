-- FUNCTION: public.get_msg_best(integer, integer, numeric)

DROP FUNCTION IF EXISTS public.get_msg_best(integer, lang, integer, integer, numeric);

CREATE OR REPLACE FUNCTION public.get_msg_best(
  _notifId integer,
  _lang lang,
  _rankGen integer,
  _rankMon integer,
	_odd numeric)
    RETURNS TABLE(
    notif_id integer,
    lang_code lang,
    title character varying,
    message text,
    messages_tr jsonb
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN
RETURN QUERY

SELECT tr.notif_id, tr.lang_code, tr.title, replace(tr.message, '{{odd}}', ROUND(_odd, 2)::text), (select jsonb_object(array_agg(ntr.lang_code::text), array_agg(replace(ntr.message, '{{odd}}', ROUND(_odd, 2)::text))) from notifications_tr ntr where ntr.notif_id=tr.notif_id and ntr.slug=tr.slug) AS messages_tr
FROM notifications_tr tr
WHERE tr.notif_id = $1
AND tr.lang_code = $2
AND CASE WHEN _rankGen = 1 THEN slug = 'bvr_best_top1' ELSE CASE WHEN _rankMon = 1 THEN slug = 'bvr_best_mnth1' ELSE CASE WHEN _rankGen <= _rankMon OR (_rankGen IS NOT NULL AND _rankMon IS NULL) THEN slug = 'bvr_best_top' ELSE slug = 'bvr_best_mnth' END END END;

END;
$BODY$;