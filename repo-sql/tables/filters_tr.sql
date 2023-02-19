CREATE TABLE IF NOT EXISTS filters_tr (
  filter_id integer NOT NULL,
  lang_code lang 
      REFERENCES languages(code) 
      ON UPDATE CASCADE,
  value json,
  title varchar(128) NOT NULL,
  CONSTRAINT filters_tr_pkey PRIMARY KEY (filter_id, lang_code),
  CONSTRAINT filters_tr_filter_id_fkey FOREIGN KEY (filter_id) 
      REFERENCES filters (id) 
      ON UPDATE CASCADE 
      ON DELETE CASCADE
);


