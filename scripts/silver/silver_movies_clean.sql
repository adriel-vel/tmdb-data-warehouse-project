/*
================================================================s==================================
Clean silver tables AFTER initalize from (init_silver_tables.sql) and load from (silver_movies.sql)
================s================================================s=================================
*/

/* Update statements to clean the silver.movies table by setting invalid or unrealistic values to NULL */
UPDATE silver.movies
SET runtime = NULL
WHERE runtime <= 0;

UPDATE silver.movies
SET budget = NULL
WHERE budget = 0;

UPDATE silver.movies
SET revenue = NULL
WHERE revenue <= 0;

UPDATE silver.movies
SET vote_count = NULL
WHERE vote_count = 0;

UPDATE silver.movies
SET popularity = NULL
WHERE popularity = 0;

UPDATE silver.movies
SET release_date = NULL
WHERE release_date < '1888-01-01' OR release_date > '2025-12-31';

