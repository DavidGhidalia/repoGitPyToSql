CREATE TABLE IF NOT EXISTS sponsors_tr (
  setting_id integer REFERENCES sponsors_settings(id) ON UPDATE CASCADE ON DELETE CASCADE,
  lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
  description jsonb,
  CONSTRAINT sponsors_tr_pkey PRIMARY KEY (setting_id, lang_code)
);