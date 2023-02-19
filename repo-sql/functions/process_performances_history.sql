-- FUNCTION: public.process_performances_history()

DROP FUNCTION IF EXISTS public.process_performances_history();

CREATE OR REPLACE FUNCTION public.process_performances_history()
 RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        --
        -- Create a row in performances_history to save users monthly performance
        -- make use of the special variable TG_OP to work out the operation.
        --
        IF (TG_OP = 'DELETE') THEN
            DELETE FROM performances_history
            WHERE user_id = OLD.user_id;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            IF (EXTRACT(MONTH FROM (NEW.updated_at)) > EXTRACT(MONTH FROM (OLD.updated_at)) 
            OR EXTRACT(YEAR FROM (NEW.updated_at)) > EXTRACT(YEAR FROM (OLD.updated_at))) 
            THEN
                INSERT INTO performances_history (user_id, 
                                                  general_rank, 
                                                  monthly_rank, 
                                                  j30_rank, 
                                                  success_rate, 
                                                  prognosis_rate, 
                                                  average_odds, 
                                                  average_odds_won, 
                                                  average_stake, 
                                                  popularity, 
                                                  comments, 
                                                  roi, 
                                                  monthly_roi, 
                                                  roc, 
                                                  monthly_roc, 
                                                  score_top, 
                                                  score_monthly, 
                                                  score_j30, 
                                                  roi_coins, 
                                                  roi_coins_stake, 
                                                  roc_coins, 
                                                  roc_coins_stake, 
                                                  bet_count, 
                                                  bet_count_monthly, 
                                                  month, 
                                                  year, 
                                                  created_at, 
                                                  updated_at)
                VALUES (OLD.user_id, OLD.general_rank, OLD.monthly_rank, OLD.j30_rank, 
                OLD.success_rate, OLD.prognosis_rate, OLD.average_odds, OLD.average_odds_won, 
                OLD.average_stake, OLD.popularity, OLD.comments, OLD.roi, OLD.monthly_roi, OLD.roc, 
                OLD.monthly_roc, OLD.score_top, OLD.score_monthly, OLD.score_j30, OLD.roi_coins, 
                OLD.roi_coins_stake, OLD.roc_coins, OLD.roc_coins_stake, OLD.bet_count, 
                OLD.bet_count_monthly, 
                EXTRACT(MONTH FROM (OLD.updated_at)), 
                EXTRACT(YEAR FROM (OLD.updated_at)), NOW(), NOW())
                ON CONFLICT (user_id, month, year) DO NOTHING;
                RETURN NEW;
            END IF;
        END IF;
        RETURN NULL; -- result is ignored since this is an AFTER trigger
    END;
$$;