DROP FUNCTION IF EXISTS random_between(numeric, numeric);


CREATE OR REPLACE FUNCTION random_between(low numeric, high numeric) 
   RETURNS numeric AS
$$
BEGIN
   RETURN floor(random()* (high-low + 1) + low);
END;
$$ language 'plpgsql' STRICT;