/*
===============================================================================
Quality Checks - Silver Layer
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' layer. It includes checks for:
    - NULL or duplicate primary keys
    - Row count validation against bronze layer
    - Invalid or out-of-range values
    - Data cleaning rules correctly applied
    - Referential integrity between related tables

Usage Notes:
    - Run these checks after loading the Silver Layer.
    - Every check includes an expectation comment.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ============================================================
-- Checking 'silver.movies'
-- ============================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    id,
    COUNT(*)
FROM silver.movies
GROUP BY id
HAVING COUNT(*) > 1 OR id IS NULL;

-- Check Row Count Against Bronze (Released movies only)
-- Expectation: Difference should equal number of duplicates removed (1,074)
SELECT
    (SELECT COUNT(*) FROM bronze.tmdb_movies WHERE status = 'Released') AS bronze_released_count,
    (SELECT COUNT(*) FROM silver.movies) AS silver_movies_count,
    (SELECT COUNT(*) FROM bronze.tmdb_movies WHERE status = 'Released') -
    (SELECT COUNT(*) FROM silver.movies) AS duplicates_removed;

-- Check That Only 'Released' Movies Were Loaded
-- Expectation: No Results
SELECT DISTINCT status
FROM bronze.tmdb_movies
WHERE id IN (SELECT CAST(id AS TEXT) FROM silver.movies)
AND status != 'Released';

-- Check for Invalid Runtime (Cleaning Rule: runtime <= 0 set to NULL)
-- Expectation: No Results
SELECT id, title, runtime
FROM silver.movies
WHERE runtime <= 0;

-- Check for Invalid Budget (Cleaning Rule: budget = 0 set to NULL)
-- Expectation: No Results
SELECT id, title, budget
FROM silver.movies
WHERE budget = 0;

-- Check for Invalid Revenue (Cleaning Rule: revenue <= 0 set to NULL)
-- Expectation: No Results
SELECT id, title, revenue
FROM silver.movies
WHERE revenue <= 0;

-- Check for Invalid Vote Count (Cleaning Rule: vote_count = 0 set to NULL)
-- Expectation: No Results
SELECT id, title, vote_count
FROM silver.movies
WHERE vote_count = 0;

-- Check for Invalid Popularity (Cleaning Rule: popularity = 0 set to NULL)
-- Expectation: No Results
SELECT id, title, popularity
FROM silver.movies
WHERE popularity = 0;

-- Check for Invalid Release Dates (Cleaning Rule: before 1888-01-01 or after 2025-12-31 set to NULL)
-- Expectation: No Results
SELECT id, title, release_date
FROM silver.movies
WHERE release_date < '1888-01-01'
   OR release_date > '2025-12-31';

-- Check for Negative Popularity Values
-- Expectation: No Results
SELECT id, title, popularity
FROM silver.movies
WHERE popularity < 0;

-- Check for Out-of-Range Vote Average (Valid range: 0.0 to 10.0)
-- Expectation: No Results
SELECT id, title, vote_average
FROM silver.movies
WHERE vote_average < 0 OR vote_average > 10;

-- Check for Unwanted Spaces in Title
-- Expectation: No Results
SELECT id, title
FROM silver.movies
WHERE title != TRIM(title);

-- Check for Negative Runtime Values
-- Expectation: No Results
SELECT id, title, runtime
FROM silver.movies
WHERE runtime < 0;

-- Check for Negative Budget Values
-- Expectation: No Results
SELECT id, title, budget
FROM silver.movies
WHERE budget < 0;

-- Check for Negative Revenue Values
-- Expectation: No Results
SELECT id, title, revenue
FROM silver.movies
WHERE revenue < 0;

-- ============================================================
-- Checking 'silver.genres'
-- ============================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    genre_id,
    COUNT(*)
FROM silver.genres
GROUP BY genre_id
HAVING COUNT(*) > 1 OR genre_id IS NULL;

-- Check for Duplicate Genre Names
-- Expectation: No Results
SELECT
    genre_name,
    COUNT(*)
FROM silver.genres
GROUP BY genre_name
HAVING COUNT(*) > 1;

-- Check for NULL Genre Names
-- Expectation: No Results
SELECT genre_id, genre_name
FROM silver.genres
WHERE genre_name IS NULL;

-- Check for Unwanted Spaces in Genre Name
-- Expectation: No Results
SELECT genre_id, genre_name
FROM silver.genres
WHERE genre_name != TRIM(genre_name);

-- Check Total Genre Count
-- Expectation: 19 rows
SELECT COUNT(*) AS total_genres
FROM silver.genres;

-- ============================================================
-- Checking 'silver.movie_genres'
-- ============================================================

-- Check for NULLs in Composite Primary Key
-- Expectation: No Results
SELECT *
FROM silver.movie_genres
WHERE movie_id IS NULL OR genre_id IS NULL;

-- Check for Duplicate Composite Primary Keys
-- Expectation: No Results
SELECT
    movie_id,
    genre_id,
    COUNT(*)
FROM silver.movie_genres
GROUP BY movie_id, genre_id
HAVING COUNT(*) > 1;

-- Check Referential Integrity: All movie_ids exist in silver.movies
-- Expectation: No Results
SELECT DISTINCT mg.movie_id
FROM silver.movie_genres mg
LEFT JOIN silver.movies m ON mg.movie_id = m.id
WHERE m.id IS NULL;

-- Check Referential Integrity: All genre_ids exist in silver.genres
-- Expectation: No Results
SELECT DISTINCT mg.genre_id
FROM silver.movie_genres mg
LEFT JOIN silver.genres g ON mg.genre_id = g.genre_id
WHERE g.genre_id IS NULL;

-- Check Row Count
-- Expectation: 1,134,271 rows
SELECT COUNT(*) AS total_movie_genre_pairs
FROM silver.movie_genres;