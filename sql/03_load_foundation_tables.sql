-- ===================================================================================
-- Script Name : 03_load_foundation_tables.sql
-- Project     : Pharma Commercial Analytics Platform
-- Layer       : FOUNDATION
-- Purpose     : Load Foundation Tables from S3
--
-- Description:
-- 1. Load Taxonomy Data
-- 2. Load RX Data
-- 3. Load HCP Master Data
-- 4. Load Enrollment Data
--
-- ===================================================================================

USE DATABASE PHARMA_COMMERCIAL_ANALYTICS;

USE SCHEMA FOUNDATION;

USE WAREHOUSE INGEST_WH;

-- ===================================================================================
-- LOAD TAXONOMY
-- ===================================================================================

COPY INTO FOUNDATION.F_TAXONOMY
FROM @LANDING.STG_TAXONOMY
FILE_FORMAT = (
    FORMAT_NAME = LANDING.CSV_FF
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = CONTINUE;

-- ===================================================================================
-- LOAD RX
-- ===================================================================================

COPY INTO FOUNDATION.F_RX
FROM @LANDING.STG_RX
FILE_FORMAT = (
    FORMAT_NAME = LANDING.CSV_FF
	ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = CONTINUE;

-- ===================================================================================
-- LOAD HCP MASTER
-- ===================================================================================

COPY INTO FOUNDATION.F_HCP_MASTER
FROM @LANDING.STG_HCP
FILE_FORMAT = (
    FORMAT_NAME = LANDING.CSV_FF
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = CONTINUE;

-- ===================================================================================
-- LOAD ENROLLMENT
-- ===================================================================================

COPY INTO FOUNDATION.F_ENROLLMENT
FROM @LANDING.STG_ENROLLMENT
FILE_FORMAT = (
    FORMAT_NAME = LANDING.CSV_FF
)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
ON_ERROR = CONTINUE;

-- ===================================================================================
-- VALIDATION
-- ===================================================================================

SELECT COUNT(*) AS TAXONOMY_COUNT
FROM FOUNDATION.F_TAXONOMY;

SELECT COUNT(*) AS RX_COUNT
FROM FOUNDATION.F_RX;

SELECT COUNT(*) AS HCP_COUNT
FROM FOUNDATION.F_HCP_MASTER;

SELECT COUNT(*) AS ENROLLMENT_COUNT
FROM FOUNDATION.F_ENROLLMENT;

-- ===================================================================================
-- END OF SCRIPT
-- ===================================================================================