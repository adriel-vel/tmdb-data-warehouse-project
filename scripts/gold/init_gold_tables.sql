/*
================================================
Create Gold Database Tables
================================================
*/

/* Creates the gold.movie_metrics table if it does not already exist */
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

/* Creates the gold.genre_metrics table if it does not already exist */
CREATE TABLE IF NOT EXISTS gold.genre_metrics(
    movie_id              INTEGER,
    genre_id              INTEGER,
    title                 TEXT,
    genre_name            TEXT,
    popularity            NUMERIC,
    PRIMARY KEY (movie_id, genre_id)
);

/* Creates the gold.release_metrics table if it does not already exist */
CREATE TABLE IF NOT EXISTS gold.release_metrics(
    movie_id              INTEGER PRIMARY KEY,
    title                 TEXT,
    release_date          DATE,
    release_year          INTEGER,
    release_month         INTEGER,
    release_quarter       INTEGER,
    popularity            NUMERIC
);