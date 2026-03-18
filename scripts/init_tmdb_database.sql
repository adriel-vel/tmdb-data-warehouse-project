/*
================================================
Create Database and Schemas
================================================
Script Purpose:
	This script creates a new database named 'tmdb_warehouse' after checking if it exists within the users databases.
	If the database exists, it is dropped and recreated as well with setting up the three schemas: bronze, silver, and gold.

WARNING:
	Running this script will drop the entire 'tmdb_warehouse' database if it exists.
	All data in the database will be permanently deleted. Proceed with caution and ensure
	you have proper backups before running this script.
*/


-- Drops and recreate the 'tmdb_warehouse' database
DROP DATABASE IF EXISTS tmdb_warehouse;

-- This will create the 'tmdb_warehouse' database
CREATE DATABASE tmdb_warehouse;

-- Create Schemas (Make sure you changed connection to 'tmdb_warehouse' before running lines below)
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

/*
================================================
Create Database and Schemas
================================================
Table Purpose:
	Stores the raw movie data exactly as it appears in the source CSV.
	All columns are TEXT to avoid load failures from dity or unexpected data.
	No transformations are applied here.
*/

CREATE TABLE IF NOT EXISTS bronze.tmdb_movies(
    id                    TEXT,
    title                 TEXT,
    vote_average          TEXT,
    vote_count            TEXT,
    status                TEXT,
    release_date          TEXT,
    revenue               TEXT,
    runtime               TEXT,
    adult                 TEXT,
    backdrop_path         TEXT,
    budget                TEXT,
    homepage              TEXT,
    imdb_id               TEXT,
    original_language     TEXT,
    original_title        TEXT,
    overview              TEXT,
    popularity            TEXT,
    poster_path           TEXT,
    tagline               TEXT,
    genres                TEXT,
    production_companies  TEXT,
    production_countries  TEXT,
    spoken_languages      TEXT,
    keywords              TEXT
);