# Data Dictionary for Gold Layer

## Overview

The Gold Layer is the analytics-ready representation of the TMDB Data Warehouse, structured to support analytical and reporting use cases. It consists of three pre-computed, pre-joined tables derived from the Silver Layer that are designed to answer specific business questions about movie popularity, genres, ratings, and release patterns.

**Source:** Silver Layer (`silver.movies`, `silver.genres`, `silver.movie_genres`)  
**Row counts:** `gold.movie_metrics` (1,338,874) · `gold.genre_metrics` (1,134,271) · `gold.release_metrics` (1,338,874)

---

## 1. gold.movie_metrics

- **Purpose:** Stores pre-computed performance metrics for every released movie. Designed to answer questions about popularity, ratings, profitability, and runtime at the individual movie level.
- **Source Table:** `silver.movies`
- **Business Questions:** Q1 (highest popularity scores), Q3 (average runtime of popular movies), Q5 (relationship between ratings and popularity)

| Column Name      | Data Type | Description                                                                                      |
|------------------|-----------|--------------------------------------------------------------------------------------------------|
| movie_id         | INTEGER   | Primary key. Unique numerical identifier for each movie, sourced from TMDB.                      |
| title            | TEXT      | The movie's release title. May be NULL for movies with incomplete metadata in the source data.   |
| vote_average     | NUMERIC   | Average user rating on a 0–10 scale as recorded on TMDB.                                         |
| vote_count       | INTEGER   | Total number of user votes submitted on TMDB. NULL if no votes were recorded.                    |
| runtime          | INTEGER   | Movie duration in minutes. NULL if unreported or invalid (≤ 0) in source data.                  |
| popularity       | NUMERIC   | TMDB popularity score based on platform engagement metrics such as views and watchlist adds.     |
| budget           | BIGINT    | Reported production budget in USD. NULL if unreported or zero in source data.                    |
| revenue          | BIGINT    | Reported box office revenue in USD. NULL if unreported or zero in source data.                   |
| profit           | BIGINT    | Derived column. Calculated as `revenue - budget`. NULL if either budget or revenue is NULL.      |
| popularity_tier  | TEXT      | Derived column. Categorizes movies by popularity score into: `Unscored`, `Low` (≤ 10), `Medium` (≤ 50), `High` (≤ 100), `Blockbuster` (> 100). |
| vote_reliability | NUMERIC   | Derived column. Calculated as `vote_count × vote_average`. Higher values indicate a more reliable and well-reviewed film. NULL if either input is NULL. |

> **Note:** Popularity score reflects TMDB platform engagement and does not solely indicate film quality or legitimacy. Adult content films may appear in higher popularity tiers due to search volume on the TMDB platform.

---

## 2. gold.genre_metrics

- **Purpose:** Stores movie-genre pair relationships enriched with popularity data. Designed to support analysis of which genres are most common among popular movies. One row per movie-genre pair.
- **Source Tables:** `silver.movie_genres`, `silver.movies`, `silver.genres`
- **Business Questions:** Q2 (most common genres among popular movies)

| Column Name | Data Type | Description                                                                                        |
|-------------|-----------|----------------------------------------------------------------------------------------------------|
| movie_id    | INTEGER   | Part of composite primary key. References the movie in `silver.movies`.                            |
| genre_id    | INTEGER   | Part of composite primary key. References the genre in `silver.genres`.                            |
| title       | TEXT      | The movie's release title. May be NULL for movies with incomplete metadata in the source data.     |
| genre_name  | TEXT      | Human-readable genre label (e.g., `Action`, `Drama`, `Comedy`). 19 unique genres total.           |
| popularity  | NUMERIC   | TMDB popularity score for the movie, sourced from `silver.movies`.                                 |

> **Note:** A movie can belong to multiple genres, so a single movie may appear in multiple rows. To filter for popular movies, use `WHERE popularity > 100` (equivalent to the `Blockbuster` tier).

---

## 3. gold.release_metrics

- **Purpose:** Stores release timing data for every movie enriched with derived date components and popularity score. Designed to support analysis of how release timing correlates with movie popularity.
- **Source Table:** `silver.movies`
- **Business Questions:** Q4 (release timing patterns)

| Column Name     | Data Type | Description                                                                                         |
|-----------------|-----------|-----------------------------------------------------------------------------------------------------|
| movie_id        | INTEGER   | Primary key. Unique numerical identifier for each movie, sourced from TMDB.                         |
| title           | TEXT      | The movie's release title. May be NULL for movies with incomplete metadata in the source data.      |
| release_date    | DATE      | Full release date of the movie. NULL if missing or outside valid range (before 1888 or after 2025). |
| release_year    | INTEGER   | Derived column. Year extracted from `release_date` using `EXTRACT(YEAR FROM release_date)`.         |
| release_month   | INTEGER   | Derived column. Month (1–12) extracted from `release_date` using `EXTRACT(MONTH FROM release_date)`.|
| release_quarter | INTEGER   | Derived column. Quarter (1–4) derived from `release_month`. NULL if `release_date` is NULL.         |
| popularity      | NUMERIC   | TMDB popularity score for the movie, sourced from `silver.movies`.                                  |

> **Quarter Mapping:**  
> `Q1` = January–March · `Q2` = April–June · `Q3` = July–September · `Q4` = October–December
