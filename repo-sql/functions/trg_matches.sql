DROP FUNCTION IF EXISTS trg_matches();


CREATE OR REPLACE FUNCTION trg_matches()
 RETURNS TRIGGER AS
$BODY$
BEGIN
    IF OLD.date <> NEW.date THEN

      UPDATE beegames b
      SET date_start = NEW.date, updated_at = now()
      WHERE b.match_id = NEW.id AND b.date_start <> NEW.date;

    END IF;

    IF NEW.status IN ('postponed', 'cancelled') THEN

      UPDATE beegames b
      SET date_end = NOW()
      WHERE b.match_id = NEW.id AND b.date_end IS NULL;

    END IF;

    IF OLD.status <> NEW.status THEN
      
      UPDATE rooms r
      SET active = q.active, updated_at = now()
      FROM (
        SELECT CASE WHEN NEW.status = 'live' THEN true ELSE false END AS active
      ) q
      WHERE r.id = any(SELECT room_id FROM beegames WHERE match_id = NEW.id) AND r.active <> q.active;
      
    END IF;

    RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';