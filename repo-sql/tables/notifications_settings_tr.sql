CREATE TABLE IF NOT EXISTS notifications_settings_tr (
    notif_setting_id integer REFERENCES notifications_settings(id) ON UPDATE CASCADE ON DELETE CASCADE, 
    lang_code lang REFERENCES languages(code) ON UPDATE CASCADE,
    "label" varchar(256) NOT NULL,
  CONSTRAINT notifications_settings_tr_pkey PRIMARY KEY (notif_setting_id, lang_code)
);