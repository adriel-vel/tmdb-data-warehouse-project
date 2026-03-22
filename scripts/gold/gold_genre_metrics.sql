/* Truncate gold genre_metrics table if it exists to prevent duplicate entries */
TRUNCATE TABLE gold.genre_metrics;

/* Insert data into gold.genre_metrics table from silver.movies */
INSERT INTO gold.genre_metrics(
    movie_id,
    genre_id,
    title,
    genre_name,
    popularity
)

/* Select and transform data to join movies with their genres and extract relevant information */
SELECT
    m.id AS movie_id,
    g.genre_id,
    m.title,
    g.genre_name,
    m.popularity

FROM silver.movies m
JOIN silver.movie_genres mg ON m.id = mg.movie_id
JOIN silver.genres g ON mg.genre_id = g.genre_id;