DROP FUNCTION IF EXISTS public.get_dates(integers[]);

CREATE FUNCTION public.get_dates(date_filters integer[]) 
RETURNS TABLE(_date date) AS $$

SELECT current_date + days::integer
FROM unnest(date_filters) s(days)

$$ LANGUAGE SQL;