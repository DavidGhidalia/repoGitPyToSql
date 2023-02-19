CREATE TABLE IF NOT EXISTS tournaments_rounds_tr (
  name tournament_round varchar(64),
  lang_code lang 
      references languages(code) 
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  label varchar(64),
  constraint tournaments_rounds_tr_pkey primary key (name, lang_code)
);

