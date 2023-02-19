
CREATE TABLE IF NOT EXISTS languages (
	code lang primary key not null,
  name varchar(64) not null,
	active boolean default 'false',
    deepl character varying(5),
    master boolean default 'false'
);

