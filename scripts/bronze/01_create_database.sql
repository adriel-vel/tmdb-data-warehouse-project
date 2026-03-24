/*
================================================
Step 1a: Create Database
================================================
Script Purpose:
    This script drops and recreates the 'tmdb_warehouse' database.
    Run this while connected to the 'postgres' database (or any existing database).

WARNING:
    Running this script will drop the entire 'tmdb_warehouse' database if it exists.
    All data in the database will be permanently deleted. Proceed with caution and ensure
    you have proper backups before running this script.

Connection: postgres
Next Step:  Connect to 'tmdb_warehouse', then run 02_create_schemas.sql
================================================
*/

-- Drops and recreate the 'tmdb_warehouse' database
DROP DATABASE IF EXISTS tmdb_warehouse;
CREATE DATABASE tmdb_warehouse;