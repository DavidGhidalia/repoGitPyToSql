CREATE TABLE IF NOT EXISTS brands (
  id SERIAL NOT NULL, 
  name character varying(128) NOT NULL, 
  country_code character varying(128) NOT NULL,
  currency_code character varying(128) NOT NULL,
  redemption_instructions text,
  logo character varying(128) NOT NULL,
  products jsonb,
  PRIMARY KEY(id)
 );