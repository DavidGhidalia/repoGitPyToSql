CREATE TABLE IF NOT EXISTS gifts_levels (
  type_id integer 
      REFERENCES gifts_types(id) 
      ON UPDATE CASCADE 
      ON DELETE CASCADE,
  level integer not null,
  reward varchar(64) not null,
  unlocked_at integer not null,
  CONSTRAINT gifts_levels_pkey PRIMARY KEY (type_id, level)
);

ALTER TABLE gifts_levels
DROP  COLUMN IF EXISTS reward cascade ;