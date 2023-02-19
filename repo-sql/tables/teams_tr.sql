CREATE TABLE IF NOT EXISTS teams_tr (
  team_id integer 
      REFERENCES teams(id) 
      ON UPDATE CASCADE 
      ON DELETE CASCADE,
  lang_code lang 
      REFERENCES languages(code) 
      ON UPDATE CASCADE,
  name varchar(512) NOT NULL,
  CONSTRAINT teams_tr_pkey PRIMARY KEY (team_id, lang_code)
);