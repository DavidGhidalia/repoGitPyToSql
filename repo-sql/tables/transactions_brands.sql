CREATE TABLE iF NOT EXISTS transactions_brands (
  id serial primary key not null,
  name varchar(128) not null,
  logo varchar(256),
  active boolean default false
);