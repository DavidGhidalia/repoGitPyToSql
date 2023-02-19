CREATE TABLE IF NOT EXISTS tutorials_users (
  tutorial_id integer REFERENCES tutorials(id) ON UPDATE CASCADE ON DELETE CASCADE,
  user_id integer REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
  step integer, 
  completed boolean default false,
  created_at timestamp with time zone,
  updated_at timestamp with time zone,
  CONSTRAINT tutorials_users_pkey PRIMARY KEY (tutorial_id, user_id)
);