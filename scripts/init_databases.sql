/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates the schemas used in the
    datawarehouse database.

NOTE:
    The database 'datawarehouse' must already exist.
=============================================================
*/

CREATE SCHEMA IF NOT EXISTS bronze;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE SCHEMA IF NOT EXISTS gold;

