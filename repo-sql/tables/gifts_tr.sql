CREATE TABLE IF NOT EXISTS gifts_tr (
  type_id integer REFERENCES gifts_types(id) ON UPDATE CASCADE ON DELETE CASCADE, 
  lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
  description jsonb,
  CONSTRAINT gifts_tr_pkey PRIMARY KEY (type_id, lang_code)
);