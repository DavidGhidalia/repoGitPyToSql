CREATE TABLE IF NOT EXISTS public.app_version (
    num_version character varying(10) NOT NULL,
    force_update boolean NOT NULL,
    released_at timestamptz(0) NULL,
    platform platform
    CONSTRAINT app_version_num_version_key UNIQUE (num_version),
    CONSTRAINT app_version_pkey PRIMARY KEY (num_version)

);

ALTER TABLE app_version
ALTER COLUMN IF EXISTS platform type platform using platform::platform;


