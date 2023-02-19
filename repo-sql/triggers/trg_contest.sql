DROP TRIGGER IF EXISTS trg_contest ON contest;


CREATE TRIGGER trg_contest AFTER INSERT OR UPDATE ON contest
FOR EACH ROW EXECUTE PROCEDURE notify_contest();