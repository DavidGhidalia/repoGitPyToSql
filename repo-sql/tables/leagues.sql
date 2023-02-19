CREATE TABLE IF NOT EXISTS leagues(
	id integer primary key,
  name varchar(128) not null,
	group_name varchar(128),
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);