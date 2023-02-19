CREATE TABLE categories_tr (
  category_id integer REFERENCES categories(id) ON UPDATE CASCADE ON DELETE CASCADE,
  lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
  name varchar(128) NOT NULL,
  CONSTRAINT categories_tr_pkey PRIMARY KEY (category_id, lang_code)
);