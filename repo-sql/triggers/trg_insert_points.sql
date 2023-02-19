DROP TRIGGER IF EXISTS trg_insert_points ON odds;


CREATE TRIGGER trg_insert_points 
AFTER INSERT ON odds 
FOR EACH ROW 
WHEN (NEW.bookmaker = 9999) 
EXECUTE PROCEDURE trg_insert_points();