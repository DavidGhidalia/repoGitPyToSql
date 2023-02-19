DROP TRIGGER IF EXISTS trg_tournaments_name ON tournaments;


CREATE TRIGGER trg_tournaments_name
BEFORE INSERT OR UPDATE ON tournaments 
FOR EACH ROW 
EXECUTE PROCEDURE trg_tournaments_name();