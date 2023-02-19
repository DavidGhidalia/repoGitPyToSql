CREATE TABLE IF NOT EXISTS leagues_tr (
  league_id integer REFERENCES leagues(id) ON UPDATE CASCADE ON DELETE CASCADE, 
  lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
  name varchar(128) NOT NULL,
  group_name varchar(128),
  CONSTRAINT leagues_tr_pkey PRIMARY KEY (league_id, lang_code)
);