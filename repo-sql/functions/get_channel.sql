
DROP FUNCTION IF EXISTS public.get_channel(integer, character varying);

CREATE OR REPLACE FUNCTION get_channel(_id integer, _country_code character varying) 
RETURNS jsonb AS $$
DECLARE
	_content jsonb;
BEGIN
	SELECT row_to_json(row) INTO _content
	FROM (
		SELECT DISTINCT c.name, c.logo
		FROM channels c
		WHERE 
			CASE WHEN (SELECT DISTINCT SUBSTRING(SPLIT_PART(cha.name, '-', 1), 1, CHAR_LENGTH(SPLIT_PART(cha.name, '-', 1)) - 1)
						FROM matches m, jsonb_to_recordset(m.channel) AS cha (name text, url text, country text, country_code text)
						WHERE m.id = _id AND cha.country_code LIKE _country_code FETCH FIRST 1 ROWS ONLY) IS NOT NULL
			THEN c.name LIKE CONCAT((SELECT DISTINCT SUBSTRING(SPLIT_PART(cha.name, '-', 1), 1, CHAR_LENGTH(SPLIT_PART(cha.name, '-', 1)) - 1)
									FROM matches m, jsonb_to_recordset(m.channel) AS cha (name text, url text, country text, country_code text)
									WHERE m.id = _id AND cha.country_code LIKE _country_code FETCH FIRST 1 ROWS ONLY), '%')
			ELSE c.name LIKE (SELECT DISTINCT SUBSTRING(SPLIT_PART(cha.name, '-', 1), 1, CHAR_LENGTH(SPLIT_PART(cha.name, '-', 1)) - 1)
									FROM matches m, jsonb_to_recordset(m.channel) AS cha (name text, url text, country text, country_code text)
									WHERE m.id = _id AND cha.country_code LIKE _country_code FETCH FIRST 1 ROWS ONLY)
			END
	) row;
	
    RETURN _content;
END;
$$ LANGUAGE plpgsql;