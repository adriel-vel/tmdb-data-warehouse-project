/*
===============================================================================
Quality Checks - Gold Layer
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'gold' layer. It includes checks for:
    - NULL or duplicate primary keys
    - Row count validation against silver layer
    - Derived column correctness (profit, popularity_tier, vote_reliability)
    - Invalid or unexpected values in computed columns
    - Data consistency between gold and silver layers

Usage Notes:
    - Run these checks after loading the Gold Layer.
    - Every check includes an expectation comment.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ============================================================
-- Checking 'gold.movie_metrics'
-- ============================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    movie_id,
    COUNT(*)
FROM gold.movie_metrics
GROUP BY movie_id
HAVING COUNT(*) > 1 OR movie_id IS NULL;

-- Check Row Count Against Silver
-- Expectation: Counts should be equal, difference should be 0
SELECT
    (SELECT COUNT(*) FROM silver.movies) AS silver_count,
    (SELECT COUNT(*) FROM gold.movie_metrics) AS gold_count,
    (SELECT COUNT(*) FROM silver.movies) -
    (SELECT COUNT(*) FROM gold.movie_metrics) AS difference;

-- Check Profit Calculation Correctness (profit = revenue - budget)
-- Expectation: No Results
SELECT
    movie_id,
    title,
    budget,
    revenue,
    profit,
    (revenue - budget) AS expected_profit
FROM gold.movie_metrics
WHERE budget IS NOT NULL
  AND revenue IS NOT NULL
  AND profit != (revenue - budget);

-- Check Profit is NULL When Budget or Revenue is NULL
-- Expectation: No Results
SELECT movie_id, title, budget, revenue, profit
FROM gold.movie_metrics
WHERE (budget IS NULL OR revenue IS NULL)
  AND profit IS NOT NULL;

-- Check Vote Reliability Calculation Correctness (vote_reliability = vote_count * vote_average)
-- Expectation: No Results
SELECT
    movie_id,
    title,
    vote_count,
    vote_average,
    vote_reliability,
    ROUND(vote_count * vote_average, 3) AS expected_reliability
FROM gold.movie_metrics
WHERE vote_count IS NOT NULL
  AND vote_average IS NOT NULL
  AND vote_reliability != ROUND(vote_count * vote_average, 3);

-- Check Vote Reliability is NULL When vote_count or vote_average is NULL
-- Expectation: No Results
SELECT movie_id, title, vote_count, vote_average, vote_reliability
FROM gold.movie_metrics
WHERE (vote_count IS NULL OR vote_average IS NULL)
  AND vote_reliability IS NOT NULL;

-- Check Popularity Tier Only Contains Valid Values
-- Expectation: Only 'Unscored', 'Low', 'Medium', 'High', 'Blockbuster'
SELECT DISTINCT popularity_tier
FROM gold.movie_metrics
WHERE popularity_tier NOT IN ('Unscored', 'Low', 'Medium', 'High', 'Blockbuster')
   OR popularity_tier IS NULL;

-- Check Popularity Tier Boundaries Are Correctly Applied
-- Expectation: No Results
SELECT movie_id, title, popularity, popularity_tier
FROM gold.movie_metrics
WHERE (popularity IS NULL     AND popularity_tier != 'Unscored')
   OR (popularity <= 10       AND popularity_tier != 'Low'        AND popularity IS NOT NULL)
   OR (popularity > 10  AND popularity <= 50  AND popularity_tier != 'Medium')
   OR (popularity > 50  AND popularity <= 100 AND popularity_tier != 'High')
   OR (popularity > 100       AND popularity_tier != 'Blockbuster');

-- Check Popularity Tier Distribution
-- Expectation: Low ~1,101,940 | Medium ~14,890 | High ~636 | Blockbuster ~312 | Unscored ~221,096
SELECT
    popularity_tier,
    COUNT(*) AS count
FROM gold.movie_metrics
GROUP BY popularity_tier
ORDER BY count DESC;

-- Check for Negative Popularity Values
-- Expectation: No Results
SELECT movie_id, title, popularity
FROM gold.movie_metrics
WHERE popularity < 0;

-- ============================================================
-- Checking 'gold.genre_metrics'
-- ============================================================

-- Check for NULLs in Composite Primary Key
-- Expectation: No Results
SELECT *
FROM gold.genre_metrics
WHERE movie_id IS NULL OR genre_id IS NULL;

-- Check for Duplicate Composite Primary Keys
-- Expectation: No Results
SELECT
    movie_id,
    genre_id,
    COUNT(*)
FROM gold.genre_metrics
GROUP BY movie_id, genre_id
HAVING COUNT(*) > 1;

-- Check Row Count Against Silver Bridge Table
-- Expectation: Counts should be equal, difference should be 0
SELECT
    (SELECT COUNT(*) FROM silver.movie_genres) AS silver_count,
    (SELECT COUNT(*) FROM gold.genre_metrics)  AS gold_count,
    (SELECT COUNT(*) FROM silver.movie_genres) -
    (SELECT COUNT(*) FROM gold.genre_metrics)  AS difference;

-- Check All 19 Genres Are Present
-- Expectation: 19 rows
SELECT COUNT(DISTINCT genre_name) AS total_genres
FROM gold.genre_metrics;

-- Check for NULL Genre Names
-- Expectation: No Results
SELECT *
FROM gold.genre_metrics
WHERE genre_name IS NULL;

-- Check for NULL Titles and Trace Back to Silver
-- Expectation: Any NULL titles should also be NULL in silver.movies
SELECT
    gm.movie_id,
    gm.title   AS gold_title,
    m.title    AS silver_title
FROM gold.genre_metrics gm
LEFT JOIN silver.movies m ON gm.movie_id = m.id
WHERE gm.title IS NULL
  AND m.title IS NOT NULL;

-- Check Popularity Values Match Silver
-- Expectation: No Results
SELECT
    gm.movie_id,
    gm.popularity   AS gold_popularity,
    m.popularity    AS silver_popularity
FROM gold.genre_metrics gm
LEFT JOIN silver.movies m ON gm.movie_id = m.id
WHERE gm.popularity != m.popularity;

-- ============================================================
-- Checking 'gold.release_metrics'
-- ============================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    movie_id,
    COUNT(*)
FROM gold.release_metrics
GROUP BY movie_id
HAVING COUNT(*) > 1 OR movie_id IS NULL;

-- Check Row Count Against Silver
-- Expectation: Counts should be equal, difference should be 0
SELECT
    (SELECT COUNT(*) FROM silver.movies)         AS silver_count,
    (SELECT COUNT(*) FROM gold.release_metrics)  AS gold_count,
    (SELECT COUNT(*) FROM silver.movies) -
    (SELECT COUNT(*) FROM gold.release_metrics)  AS difference;

-- Check Release Quarter Only Contains Valid Values (1, 2, 3, 4, or NULL)
-- Expectation: No Results
SELECT DISTINCT release_quarter
FROM gold.release_metrics
WHERE release_quarter NOT IN (1, 2, 3, 4)
  AND release_quarter IS NOT NULL;

-- Check Release Quarter Matches Release Month
-- Expectation: No Results
SELECT movie_id, title, release_month, release_quarter
FROM gold.release_metrics
WHERE (release_month BETWEEN 1  AND 3  AND release_quarter != 1)
   OR (release_month BETWEEN 4  AND 6  AND release_quarter != 2)
   OR (release_month BETWEEN 7  AND 9  AND release_quarter != 3)
   OR (release_month BETWEEN 10 AND 12 AND release_quarter != 4);

-- Check Release Quarter is NULL When Release Date is NULL
-- Expectation: No Results
SELECT movie_id, title, release_date, release_quarter
FROM gold.release_metrics
WHERE release_date IS NULL
  AND release_quarter IS NOT NULL;

-- Check Release Year Matches Release Date
-- Expectation: No Results
SELECT movie_id, title, release_date, release_year
FROM gold.release_metrics
WHERE release_date IS NOT NULL
  AND release_year != EXTRACT(YEAR FROM release_date);

-- Check Release Month Matches Release Date
-- Expectation: No Results
SELECT movie_id, title, release_date, release_month
FROM gold.release_metrics
WHERE release_date IS NOT NULL
  AND release_month != EXTRACT(MONTH FROM release_date);

-- Check Quarter Distribution
-- Expectation: Q1 ~369,617 | Q2 ~221,885 | Q3 ~212,670 | Q4 ~260,019 | NULL ~274,683
SELECT
    release_quarter,
    COUNT(*) AS count
FROM gold.release_metrics
GROUP BY release_quarter
ORDER BY release_quarter ASC NULLS LAST;