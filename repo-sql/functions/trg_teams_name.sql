DROP FUNCTION IF EXISTS trg_teams_name();


CREATE OR REPLACE FUNCTION trg_teams_name() 
RETURNS TRIGGER AS
$BODY$
BEGIN
    IF NEW.name IS NOT NULL THEN
      IF NEW.name <> OLD.name OR OLD.name IS NULL THEN
        NEW.name_search = to_tsvector('simple', NEW.name);
      END IF;
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';