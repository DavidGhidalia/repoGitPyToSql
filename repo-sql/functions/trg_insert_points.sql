DROP FUNCTION IF EXISTS trg_insert_points();


CREATE OR REPLACE FUNCTION trg_insert_points() RETURNS TRIGGER AS
$BODY$
BEGIN
  INSERT INTO beegames_points (type_id, 
                               match_id, 
                               market_id, 
                               field_id, 
                               odds_type_id, 
                               points_winner, 
                               points_perfect, 
                               weight, 
                               created_at, 
                               updated_at)
  SELECT q.type_id, 
         q.match, 
         q.market_id, 
         q.field_id, 
         q.odds_type_id, 
         q.points_winner, 
         q.points_winner * q.weight_perfect, 
         q.weight_perfect, 
         now(), 
         now()
  FROM (
  SELECT bts.type_id,
         o.match, 
         (o.details->>'id')::integer AS market_id, 
         (ot->>'id')::integer AS field_id, 
         oty.id AS odds_type_id, 
         round((ot->>'$t')::double precision * CASE WHEN bw.weight_winner IS NOT NULL 
         THEN bw.weight_winner 
         ELSE bt.default_weight_winner 
         END) 
         AS points_winner, 
         CASE WHEN bw.weight_perfect IS NOT NULL 
         THEN bw.weight_perfect 
         ELSE bt.default_weight_perfect 
         END 
         AS weight_perfect
  FROM odds o
  CROSS JOIN jsonb_array_elements((o.details->>'Outcome')::jsonb) ot
  JOIN matches m ON m.id = o.match
  JOIN beegames_types bt ON bt.active
  JOIN beegames_types_sports bts ON bts.type_id = bt.id AND bts.sport_id = m.sport 
  AND (o.details->>'id')::integer = any(bts.markets)
  LEFT JOIN beegames_weights bw ON bw.type_id = bt.id 
  AND bw.tournament_round::text = m.tournament_round::text
  LEFT JOIN odds_type oty ON (oty.id = ANY (o.odds_type_ids)) 
  AND upper(oty.name::text) = upper(o.details->>'type') 
  AND upper(oty.field_name::text) = upper(ot->>'name'::text) AND
        CASE
            WHEN NULLIF(o.details->>'typekey', ''::text) IS NOT NULL 
            THEN oty.value::text = o.details->>'typekey'
            ELSE oty.value IS NULL
        END
  WHERE o.match = NEW.match AND o.bookmaker = NEW.bookmaker 
  AND (o.details->>'id')::integer = (NEW.details->>'id')::integer
  ) q
  ON CONFLICT (type_id, match_id, market_id, field_id, odds_type_id) DO NOTHING;
  RETURN NULL;
END;
$BODY$
LANGUAGE 'plpgsql';