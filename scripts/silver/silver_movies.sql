/* Truncate Silver Tables if they exist to prevent duplicate entries */
TRUNCATE TABLE silver.movie_genres;
TRUNCATE TABLE silver.genres;
TRUNCATE TABLE silver.movies;

/* CTE to find movies that have duplicate entries and only grab the first occurrence*/
WITH deduplicated AS(
    SELECT *, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS row_num
    FROM bronze.tmdb_movies
    WHERE status = 'Released'
)

/* Insert data into silver.movies table from bronze.tmdb_movies (deduplicated) */
INSERT INTO silver.movies(
    id,
    title,
    vote_average,
    vote_count,
    release_date,
    revenue,
    runtime,
    adult,
    budget,
    imdb_id,
    original_language,
    original_title,
    popularity
)

/* Select and cast data to correct data types, handling empty strings as NULLs*/
SELECT
    CAST(NULLIF(id, '') AS INTEGER) AS id,
    title,
    CAST(NULLIF(vote_average, '') AS NUMERIC) AS vote_average,
    CAST(NULLIF(vote_count, '') AS INTEGER) as vote_count,
    CAST(NULLIF(release_date, '') AS DATE) as release_date,
    CAST(NULLIF(revenue, '') AS BIGINT) as revenue,
    CAST(NULLIF(runtime, '') AS INTEGER) as runtime,
    CAST(NULLIF(adult, '') AS BOOLEAN) as adult,
    CAST(NULLIF(budget, '') AS BIGINT) as budget,
    imdb_id,
    original_language,
    original_title,
    CAST(NULLIF(popularity, '') AS NUMERIC) as popularity

FROM deduplicated
WHERE row_num = 1;