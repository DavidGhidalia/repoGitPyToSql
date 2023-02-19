
CREATE TABLE IF NOT EXISTS transactions (
  id serial primary key not null,
  user_id integer 
      REFERENCES users(id) 
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  source_id integer 
      REFERENCES transactions_brands(id) 
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  destination_id integer 
      REFERENCES transactions_brands(id) 
      ON UPDATE CASCADE
      ON DELETE CASCADE,
  beecoins_start numeric not null,
  beecoins_end numeric not null,
  amount numeric not null,
  operation operation not null,
  description text,
  created_at timestamp with time zone,
  updated_at timestamp with time zone
);

