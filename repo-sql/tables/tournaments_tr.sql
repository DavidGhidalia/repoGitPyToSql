CREATE TABLE IF NOT EXISTS tournaments_tr (
  tournament_id integer 
      REFERENCES tournaments(id) 
      ON UPDATE CASCADE 
      ON DELETE CASCADE,
  lang_code lang 
      REFERENCES languages(code)
      ON UPDATE CASCADE,
  name varchar(128) NOT NULL,
  CONSTRAINT tournaments_tr_pkey PRIMARY KEY (tournament_id, lang_code)
);