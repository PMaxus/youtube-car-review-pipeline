-- YouTube -> AI car-review pipeline - sanitized PostgreSQL schema.
-- Column names are taken from the actual workflow nodes; types are representative.
-- Process state lives here, which makes the pipeline restart-safe and auditable,
-- and lets a human step in at any stage.
--
-- The client schema name was renamed to a neutral "carreview".
-- prompt_library ships as STRUCTURE ONLY - the prompt texts are not published.

CREATE SCHEMA IF NOT EXISTS carreview;

-- Telegram conversation state per user.
CREATE TABLE carreview.sessions (
    id               SERIAL       PRIMARY KEY,
    user_telegram_id BIGINT       NOT NULL,
    menu_state       TEXT,                       -- current menu / step
    mode             TEXT,                       -- e.g. normal | hot
    choosed_car      TEXT,                       -- the make/model being worked on
    active_job_id    INTEGER,                    -- -> jobs.job_id
    created_at       TIMESTAMPTZ  DEFAULT NOW(),
    updated_at       TIMESTAMPTZ  DEFAULT NOW()
);

-- One review job per car request, with a status model.
CREATE TABLE carreview.jobs (
    job_id           SERIAL       PRIMARY KEY,
    user_telegram_id BIGINT       NOT NULL,
    status           TEXT         DEFAULT 'searching',
        -- searching | awaiting_confirmation | transcribing | summarizing | assembling | voicing | done | error
    total_summary    TEXT,                       -- assembled final review
    error_text       TEXT,
    created_at       TIMESTAMPTZ  DEFAULT NOW(),
    updated_at       TIMESTAMPTZ  DEFAULT NOW()
);

-- Confirmed source videos for a job, with transcripts and per-video summaries.
-- Only sources the user confirms (human-in-the-loop) are stored here.
CREATE TABLE carreview.job_videos (
    id                    SERIAL      PRIMARY KEY,
    job_id_jobs           INTEGER     REFERENCES carreview.jobs(job_id),
    youtube_video_title   TEXT,
    youtube_video_url     TEXT,
    youtube_channel_title TEXT,
    youtube_channel_url   TEXT,
    published_at          TIMESTAMPTZ,
    transcript_text       TEXT,                  -- raw transcript (ScrapeCreators)
    transcript_summary    TEXT,                  -- per-video summary (OpenRouter)
    created_at            TIMESTAMPTZ DEFAULT NOW(),
    updated_at            TIMESTAMPTZ DEFAULT NOW()
);

-- Shared prompt store (public schema). STRUCTURE ONLY - prompt rows not published.
-- Agents read the active prompt by key at run time.
CREATE TABLE public.prompt_library (
    id           SERIAL      PRIMARY KEY,
    agent_key    TEXT,
    version      INTEGER,
    status       TEXT,                            -- 'active' | 'deprecated'
    prompt_text  TEXT,                            -- NOT included in this repository
    created_at   TIMESTAMPTZ DEFAULT NOW()
);
