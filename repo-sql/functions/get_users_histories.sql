-- FUNCTION: public.get_users_histories(integer, integer, integer, integer)

DROP FUNCTION IF EXISTS public.get_users_histories(integer, integer, integer, integer) cascade;

CREATE OR REPLACE FUNCTION public.get_users_histories(
  _user integer,
  _session integer default null,
  _limit integer default 100,
  _offset integer default 0
  ) RETURNS TABLE(
    "date" date, beecoins numeric, beegames json
  ) LANGUAGE 'plpgsql' COST 100 VOLATILE PARALLEL UNSAFE ROWS 1000 AS $BODY$
BEGIN 
RETURN QUERY

SELECT h.date_end::date as date, coalesce(sum(h.beecoins_win), 0) - coalesce(sum(h.beecoins_bet), 0) as beecoins, json_agg(h.*) as beegames
FROM get_histories(_user => _user, _session => _session, _beecoins => true, _played => true, _limit => _limit, _offset => _offset) h
GROUP BY h.date_end::date
ORDER BY h.date_end::date DESC
LIMIT _limit OFFSET _offset;

END $BODY$;