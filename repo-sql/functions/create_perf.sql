DROP FUNCTION IF EXISTS public.create_perf() cascade;

CREATE FUNCTION public.create_perf() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        -- Check that id is given
        IF NEW.id IS NULL THEN
            RAISE EXCEPTION 'id cannot be null';
        END IF;

		-- init performance
		INSERT INTO performances (user_id, created_at, updated_at) VALUES (NEW.id, NOW(), NOW());

        RETURN NEW;
    END;
$$;