CREATE INDEX IF NOT EXISTS beegames_points_match_id_odds_type_id_idx ON beegames_points(match_id, odds_type_id);
CREATE INDEX IF NOT EXISTS beegames_tickets_transactions_gin_idx ON beegames_tickets USING GIN (transactions gin__int_ops);
CREATE INDEX IF NOT EXISTS beegames_type_id_idx on beegames(type_id);
CREATE INDEX IF NOT EXISTS beegames_sport_id_idx on beegames(sport_id);
CREATE INDEX IF NOT EXISTS beegames_tournaments_idx ON beegames USING GIN (tournaments gin__int_ops);
CREATE INDEX IF NOT EXISTS beegames_transactions_gin_idx ON beegames USING GIN (transactions gin__int_ops);
CREATE INDEX IF NOT EXISTS categories_name_search_idx ON categories USING GIN(name_search);
CREATE INDEX IF NOT EXISTS clusters_text_search_idx ON clusters USING GIN(text_search);
CREATE INDEX IF NOT EXISTS clusters_transactions_gin_idx ON clusters USING GIN (transactions gin__int_ops);
CREATE INDEX IF NOT EXISTS clusters_i_o_w_b_od_s_c_idx on clusters(id, owner, win, bookmaker_id, odds_value, stake, created_at);
CREATE INDEX IF NOT EXISTS clusters_i_o_w_b_od_s_bk_c_idx on clusters(id, owner, win, bookmaker_id, odds_value, stake, blocked, created_at);
CREATE INDEX IF NOT EXISTS clusters_owner_win_status_created_at_idx on clusters(owner, win, status, created_at);
CREATE INDEX IF NOT EXISTS comments_text_search_idx ON comments USING GIN(text_search);
CREATE UNIQUE INDEX IF NOT EXISTS contest_id_idx ON public.contest USING btree (id);
CREATE INDEX IF NOT EXISTS explores_name_idx ON explores(name);
CREATE INDEX IF NOT EXISTS markets_market_id_idx on markets(market_id);
create index if not exists matches_date_id on matches (date);
CREATE INDEX if not exists matches_teams_gin_idx ON matches USING GIN (teams gin__int_ops);
CREATE INDEX if not exists matches_date_sport_tournament_idx on matches(date, sport, tournament);
CREATE INDEX if not exists matches_tournament_round_idx ON matches(tournament_round);
--CREATE UNIQUE INDEX if not exists notifications_settings_id_idx ON public.notifications_settings USING btree (id);
create index if not exists odds_type_name_field_name_idx
	on odds_type (name, field_name, value);
create index if not exists odds_bookmaker_idx
	on odds (bookmaker);

create index if not exists odds_details_idx
	on odds (details);

create index if not exists odds_match_idx
	on odds (match);

create index if not exists id_best_odds_idx
	on odds (id_best_odds);

create index if not exists outcomes_name_field_name_idx
	on outcomes (name, field_name, visible);

CREATE INDEX if not exists prognosis_i_c_s_m_d_idx on prognosis(id,cluster,sport,match,match_date);

CREATE INDEX if not exists reports_id_owner_idx
    ON public.reports USING btree
    (id_owner ASC NULLS LAST)
    TABLESPACE pg_default;

    CREATE INDEX if not exists reports_id_reference_idx
    ON public.reports USING btree
    (id_reference ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: reports_id_reported_user_idx

-- DROP INDEX public.reports_id_reported_user_idx;

CREATE INDEX if not exists reports_id_reported_user_idx
    ON public.reports USING btree
    (id_reported_user ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: reports_owner_idx

-- DROP INDEX public.reports_owner_idx;

CREATE INDEX if not exists reports_owner_idx
    ON public.reports USING btree
    (id_owner ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: reports_reference_idx

-- DROP INDEX public.reports_reference_idx;

CREATE INDEX if not exists reports_reference_idx
    ON public.reports USING btree
    (id_reference ASC NULLS LAST)
    TABLESPACE pg_default;
-- Index: reports_reported_user_idx

-- DROP INDEX public.reports_reported_user_idx;

CREATE INDEX if not exists reports_reported_user_idx
    ON public.reports USING btree
    (id_reported_user ASC NULLS LAST)
    TABLESPACE pg_default;

    CREATE INDEX if not exists teams_name_search_idx ON teams USING GIN(name_search);
CREATE INDEX if not exists tournaments_name_search_idx ON tournaments USING GIN(name_search);

CREATE INDEX if not exists ON users USING GIN (nickname gin_trgm_ops);

CREATE INDEX if not exists users_biography_search_idx ON users USING GIN(biography_search);
DROP IF EXISTS index notifications_users_idx;
