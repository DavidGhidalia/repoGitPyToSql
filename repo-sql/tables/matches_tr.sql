CREATE TABLE IF NOT EXISTS matches_tr (
  match_id integer REFERENCES matches(id) ON UPDATE CASCADE ON DELETE CASCADE, 
  lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
  lineups json,
  venue json,
  CONSTRAINT matches_tr_pkey PRIMARY KEY (match_id, lang_code)
);