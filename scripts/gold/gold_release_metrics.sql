/* Truncate gold release_metrics table if it exists to prevent duplicate entries */
TRUNCATE TABLE gold.release_metrics;

/* Insert data into gold.release_metrics table from silver.movies */
INSERT INTO gold.release_metrics(
    movie_id,
    title,
    release_date,
    release_year,
    release_month,
    release_quarter,
    popularity
)

/* Select and transform data to extract release year, month, and quarter */
SELECT
    id AS movie_id,
    title,
    release_date,
    EXTRACT(YEAR FROM release_date) AS release_year,
    EXTRACT(MONTH FROM release_date) AS release_month,
    CASE
        WHEN EXTRACT(MONTH FROM release_date) BETWEEN 1 AND 3 THEN 1
        WHEN EXTRACT(MONTH FROM release_date) BETWEEN 4 AND 6 THEN 2
        WHEN EXTRACT(MONTH FROM release_date) BETWEEN 7 AND 9 THEN 3
        WHEN EXTRACT(MONTH FROM release_date) BETWEEN 10 AND 12 THEN 4
        ELSE NULL
    END AS release_quarter,
    popularity

FROM silver.movies;