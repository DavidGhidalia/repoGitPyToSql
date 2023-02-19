CREATE TABLE IF NOT EXISTS Commands (
  id SERIAL NOT NULL, 
  user_id INTEGER NOT NULL, 
  brand_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  beecoins_price INTEGER NOT NULL,
  euro_price INTEGER NOT NULL,
  gift_card character varying(10) NOT NULL,
  created_at timestamp with time zone,
  PRIMARY KEY (id),
  CONSTRAINT FKCommands379065 FOREIGN KEY (brand_id) 
        REFERENCES brands (id),
  CONSTRAINT FKCommands423439 FOREIGN KEY (user_id) 
        REFERENCES users (id)
  );
