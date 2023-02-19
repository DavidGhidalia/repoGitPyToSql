DROP FUNCTION IF EXISTS trg_clusters_text();


CREATE OR REPLACE FUNCTION trg_clusters_text() 
RETURNS TRIGGER AS
$BODY$
BEGIN
    IF NEW.text IS NOT NULL THEN
      IF NEW.text <> OLD.text OR OLD.text IS NULL THEN
        NEW.text_search = to_tsvector('french', NEW.text);
      END IF;
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';