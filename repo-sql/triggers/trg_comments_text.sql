DROP TRIGGER IF EXISTS trg_comments_text  ON comments;


CREATE TRIGGER trg_comments_text
BEFORE INSERT OR UPDATE ON comments 
FOR EACH ROW 
EXECUTE PROCEDURE trg_comments_text();