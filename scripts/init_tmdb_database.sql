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
