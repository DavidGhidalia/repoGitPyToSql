CREATE TABLE IF NOT EXISTS actions_histories (
  id serial PRIMARY KEY NOT NULL,
  user_id integer,
  date timestamp with time zone,
  commentaire character varying,
  type character varying
);
