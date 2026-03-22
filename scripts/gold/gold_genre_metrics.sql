TRUNCATE TABLE gold.genre_metrics;

INSERT INTO gold.genre_metrics(
    movie_id,
    genre_id,
    title,
    genre_name,
    popularity
)

SELECT
    m.id AS movie_id,
    g.genre_id,
    m.title,
    g.genre_name,
    m.popularity

FROM silver.movies m
JOIN silver.movie_genres mg ON m.id = mg.movie_id
JOIN silver.genres g ON mg.genre_id = g.genre_id;