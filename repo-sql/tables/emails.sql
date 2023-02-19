CREATE TABLE IF NOT EXISTS emails (
  id serial primary key not null,
  sender varchar(256) not null,
  recipient varchar(256) not null,
  recipient_copy varchar[] default '{}',
  subject varchar(256),
  body text,
  matches integer[] default '{}',
  sport integer,
  is_treated boolean default 'false',
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  CONSTRAINT emails_sport_fkey FOREIGN KEY (sport) 
        REFERENCES sports (id) 
        ON UPDATE CASCADE
);


