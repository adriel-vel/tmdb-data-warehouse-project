TRUNCATE TABLE gold.movie_metrics;

INSERT INTO gold.movie_metrics(
    movie_id,
    title,
    vote_average,
    vote_count,
    runtime,
    popularity,
    budget,
    revenue,
    profit,
    popularity_tier,
    vote_reliability
)
SELECT
    id AS movie_id,
    title,
    vote_average,
    vote_count,
    runtime,
    popularity,
    budget,
    revenue,
    (revenue - budget) AS profit,
    CASE
        WHEN popularity IS NULL THEN 'Unscored'
        WHEN popularity <= 10 THEN 'Low'
        WHEN popularity <= 50 THEN 'Medium'
        WHEN popularity <= 100 THEN 'High'
        ELSE 'Blockbuster'
    END AS popularity_tier,
    vote_count * vote_average AS vote_reliability
FROM silver.movies;