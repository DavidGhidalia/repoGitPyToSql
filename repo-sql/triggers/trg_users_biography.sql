DROP TRIGGER IF EXISTS trg_users_biography ON users;


CREATE TRIGGER trg_users_biography
BEFORE INSERT OR UPDATE ON users 
FOR EACH ROW 
EXECUTE PROCEDURE trg_users_biography();