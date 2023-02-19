
-- public.notifications_settings definition

-- Drop table

-- DROP TABLE notifications_settings;

CREATE TABLE IF NOT EXISTS notifications_settings (
	id serial NOT NULL,
  slug varchar(128) NULL,
	"label" varchar(256) NOT NULL,
	"type" integer NOT NULL,
	active boolean NULL,
	"admin" boolean NULL DEFAULT false,
    is_push boolean default false,
    is_displayed boolean default false,
	CONSTRAINT notifications_settings_pk PRIMARY KEY (id)
);
