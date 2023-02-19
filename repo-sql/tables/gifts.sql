CREATE TABLE IF NOT EXISTS gifts (
  id serial primary key not null,
  type_id integer not null,
  user_id integer,
  level integer not null,
  logo varchar(256),
  code varchar(128),
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  expired_at timestamp with time zone,
  contest_id integer,
  level integer NOT NULL,
  value integer,
CONSTRAINT gifts_type_id_fkey FOREIGN KEY (type_id) 
        REFERENCES gifts_types (id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
CONSTRAINT gifts_user_id_fkey FOREIGN KEY (user_id) 
        REFERENCES users (id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
CONSTRAINT gifts_contest_id_fkey FOREIGN KEY (contest_id) 
        REFERENCES contest (id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE
);

ALTER TABLE IF EXISTS gifts
ALTER  COLUMN  level DROP NOT NULL;


ALTER TABLE gifts
DROP COLUMN IF EXISTS value;