CREATE TABLE IF NOT EXISTS markets_tr (
  market_id integer NOT NULL, 
  lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
  label varchar(256) NOT NULL,
  type_label varchar(128) NOT NULL,
  description jsonb,
  CONSTRAINT markets_tr_pkey PRIMARY KEY (market_id, lang_code)
);