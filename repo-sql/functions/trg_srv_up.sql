DROP FUNCTION IF EXISTS trg_srv_up();


CREATE OR REPLACE FUNCTION trg_srv_up() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF OLD.active = true AND NEW.active = false THEN
        CALL ps_notif_srv_up();
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE 'plpgsql';