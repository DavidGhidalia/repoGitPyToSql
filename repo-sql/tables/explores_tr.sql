CREATE TABLE IF NOT EXISTS explores_tr (
  explore_id integer REFERENCES explores(id) ON UPDATE CASCADE ON DELETE CASCADE,
  lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
  label varchar(128) NOT NULL,
  CONSTRAINT explores_tr_pkey PRIMARY KEY (explore_id, lang_code)
);