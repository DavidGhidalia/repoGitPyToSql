DROP TRIGGER IF EXISTS trg_srv_up ON settings;


CREATE TRIGGER trg_srv_up 
BEFORE UPDATE ON settings 
FOR EACH ROW 
WHEN (OLD.name = NEW.name AND NEW.name = 'maintenance') 
EXECUTE PROCEDURE trg_srv_up();