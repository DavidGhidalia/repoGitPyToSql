CREATE TABLE IF NOT EXISTS beegames_jokers (
  type_id integer REFERENCES beegames_types(id) 
        ON UPDATE CASCADE 
        ON DELETE CASCADE,
  joker integer not null,
  active boolean default false,
  CONSTRAINT beegames_jokers_pkey PRIMARY KEY (type_id, joker)
);