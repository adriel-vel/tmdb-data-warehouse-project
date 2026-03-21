CREATE TABLE IF NOT EXISTS gold.movie_metrics(
    movie_id              INTEGER PRIMARY KEY,
    title                 TEXT,
    vote_average          NUMERIC,
    vote_count            INTEGER,
    runtime               INTEGER,
    popularity            NUMERIC,
    budget                BIGINT,
    revenue               BIGINT,
    profit                BIGINT,
    popularity_tier       TEXT,
    vote_reliability      NUMERIC
);