/*
================================================
Step 1b: Create Schemas and Bronze Table
================================================
Script Purpose:
    This script creates the bronze, silver, and gold schemas inside the
    'tmdb_warehouse' database, then creates the bronze.tmdb_movies table
    to store the raw CSV data.

    All columns are TEXT to avoid load failures from dirty or unexpected data.
    No transformations are applied here.

Connection: tmdb_warehouse
Previous Step: 01_create_database.sql (connected to 'postgres')
================================================
*/

-- Create Schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;

-- Create Bronze table for raw movie data
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