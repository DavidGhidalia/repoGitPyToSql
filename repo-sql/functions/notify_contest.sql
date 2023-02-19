DROP FUNCTION IF EXISTS notify_contest()

CREATE OR REPLACE FUNCTION notify_contest() RETURNS trigger AS $$
DECLARE
  rec RECORD;
  payload TEXT;
BEGIN

  -- Set record row depending on operation
  CASE TG_OP
  WHEN 'UPDATE' THEN
     rec := NEW;
  WHEN 'INSERT' THEN
     rec := NEW;
  ELSE
     RAISE EXCEPTION 'Unknown TG_OP: "%". Should not occur!', TG_OP;
  END CASE;

  -- Build the payload
  payload := json_build_object('timestamp',CURRENT_TIMESTAMP,'action',LOWER(TG_OP),'schema',TG_TABLE_SCHEMA,'identity',TG_TABLE_NAME,'record',row_to_json(rec));

  -- Notify the channel
  PERFORM pg_notify('contest',payload);

  RETURN rec;
END;
$$ LANGUAGE plpgsql;