CREATE TABLE IF NOT EXISTS tutorials (
  id serial primary key,
  name varchar(128) not null,
  active boolean default false, 
  admin boolean default false,
  value numeric
);
