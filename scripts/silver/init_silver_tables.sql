/*
================================================
Create Silver Database Tables
================================================
*/

/* Creates the silver.movies table if it does not already exist */
CREATE TABLE IF NOT EXISTS silver.movies(
    id                    INTEGER PRIMARY KEY,
    title                 TEXT,
    vote_average          NUMERIC,
    vote_count            INTEGER,
    release_date          DATE,
    revenue               BIGINT,
    runtime               INTEGER,
    adult                 BOOLEAN,
    budget                BIGINT,
    imdb_id               TEXT,
    original_language     TEXT,
    original_title        TEXT,
    popularity            NUMERIC
);

/* Creates the silver.genres table if it does not already exist */
CREATE TABLE IF NOT EXISTS silver.genres(
    genre_id              SERIAL PRIMARY KEY,
    genre_name            TEXT UNIQUE
);

/* Creates the silver.movie_genres table if it does not already exist */
CREATE TABLE IF NOT EXISTS silver.movie_genres(
    movie_id              INT NOT NULL REFERENCES silver.movies(id),
    genre_id              INT NOT NULL REFERENCES silver.genres(genre_id),
    PRIMARY KEY            (movie_id, genre_id)
);