CREATE TABLE IF NOT EXISTS beegames_types(
  id serial primary key not null,
  name varchar(128) not null,
  active boolean default 'false',
  sport_id integer,
  markets integer[] default '{}',
  default_weight_winner integer,
  default_weight_perfect integer,
  days_ago integer default 1,
  tickets_consumption boolean default 'false',
  bookmaker_id integer,
  days_start integer,
  slug varchar(64),
  background_url varchar(256),
  logo varchar(256),
  days_ago_history integer,
  entry_fee boolean default 'false',
  ticket_fee boolean default 'false',
  description text,
  CONSTRAINT beegames_types_bookmaker_id_fkey FOREIGN KEY (bookmaker_id)
         REFERENCES bookmakers (id) 
         ON UPDATE CASCADE 
         ON DELETE CASCADE
);



