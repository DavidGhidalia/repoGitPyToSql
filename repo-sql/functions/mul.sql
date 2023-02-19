DROP AGGREGATE IF EXISTS mul(double precision)

CREATE AGGREGATE mul(double precision) ( SFUNC = float8mul, STYPE=double precision );