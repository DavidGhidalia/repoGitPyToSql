-- View: public.v_transactions

DROP VIEW IF EXISTS public.v_transactions;

CREATE OR REPLACE VIEW public.v_transactions
 AS
  SELECT t.id,
    t.user_id,
    t.source_id,
    t.destination_id,
    t.beecoins_start,
    t.beecoins_end,
    t.amount,
    t.operation,
    t.description,
    t.created_at,
    t.updated_at,
    tr.lang_code AS lang,
    tr.description as lang_desc
   FROM transactions t
     LEFT JOIN transactions_tr tr ON tr.operation = t.operation
     LEFT JOIN languages l ON l.code = tr.lang_code AND l.active;