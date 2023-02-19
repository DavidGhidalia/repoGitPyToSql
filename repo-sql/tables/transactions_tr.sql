CREATE TABLE IF NOT EXISTS transactions_tr (
  operation operation not null,
  lang_code lang REFERENCES languages(code) ON UPDATE CASCADE ON DELETE CASCADE,
  label varchar(64),
  description text,
  CONSTRAINT transactions_tr_pkey PRIMARY KEY (operation, lang_code)
);