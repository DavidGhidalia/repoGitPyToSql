DROP FUNCTION IF EXISTS trg_users_biography();


CREATE OR REPLACE FUNCTION trg_users_biography()
 RETURNS TRIGGER AS
$BODY$
BEGIN
    IF NEW.biography IS NOT NULL THEN
      IF NEW.biography <> OLD.biography OR OLD.biography IS NULL THEN
        NEW.biography_search = to_tsvector('french', NEW.biography);
      END IF;
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';