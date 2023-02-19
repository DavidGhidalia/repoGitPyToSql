CREATE TABLE IF NOT EXISTS notifications_types_tr (
    notif_type_id integer REFERENCES notifications_types(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
    "label" varchar(256) NOT NULL,
  CONSTRAINT notifications_types_tr_pkey PRIMARY KEY (notif_type_id, lang_code)
);