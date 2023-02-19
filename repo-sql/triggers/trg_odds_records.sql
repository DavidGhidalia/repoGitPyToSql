DROP TRIGGER IF EXISTS trg_odds_records ON odds_records;

CREATE TRIGGER trg_odds_records AFTER INSERT OR UPDATE ON odds_records
FOR EACH ROW EXECUTE PROCEDURE notify_odds();