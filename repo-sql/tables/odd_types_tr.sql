CREATE TABLE IF NOT EXISTS odds_type_tr (
  odds_type_id integer REFERENCES odds_type(id) ON UPDATE CASCADE ON DELETE CASCADE, 
  lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
  field_name varchar(256) NOT NULL,
  label varchar(256) NOT NULL,
  CONSTRAINT odds_type_tr_pkey PRIMARY KEY (odds_type_id, lang_code)
);