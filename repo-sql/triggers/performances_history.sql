DROP TRIGGER IF EXISTS performances_history ON public.performances; 


CREATE TRIGGER performances_history AFTER DELETE OR UPDATE ON public.performances 
    FOR EACH ROW EXECUTE PROCEDURE public.process_performances_history();