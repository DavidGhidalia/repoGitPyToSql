DROP TRIGGER IF EXISTS trg_categories_name  ON categories;


CREATE TRIGGER trg_categories_name
BEFORE INSERT OR UPDATE ON categories 
FOR EACH ROW 
EXECUTE PROCEDURE trg_categories_name();