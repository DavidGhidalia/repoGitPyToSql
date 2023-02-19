DROP TRIGGER IF EXISTS trg_clusters_text ON clusters;


CREATE TRIGGER trg_clusters_text
BEFORE INSERT OR UPDATE ON clusters 
FOR EACH ROW 
EXECUTE PROCEDURE trg_clusters_text();