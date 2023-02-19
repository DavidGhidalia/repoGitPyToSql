-- public.notifications_types definition

-- Drop table

-- DROP TABLE notifications_types;

CREATE TABLE IF NOT EXISTS notifications_types (
	id serial NOT NULL,
	"name" varchar(128) NULL,
	"label" varchar(128) NULL,
	CONSTRAINT notifications_types_pk PRIMARY KEY (id)
);
CREATE UNIQUE INDEX notifications_types_id_idx ON public.notifications_types USING btree (id);
