-- ===================================================================================
-- Script Name : 02_create_foundation_tables.sql
-- Project     : Pharma Commercial Analytics Platform
-- Layer       : FOUNDATION
-- Author      : Biswajit Nayak
-- Purpose     : Create Foundation Layer Tables
-----------------------------------------------

-- Description:
-- 1. Create F_RX using metadata-driven schema inference
-- 2. Create F_TAXONOMY using metadata-driven schema inference
-- 3. Create F_HCP_MASTER using metadata-driven schema inference
-- 4. Create F_ENROLLMENT using explicit DDL
-- 5. Add standard audit columns to all Foundation tables
---------------------------------------------------------

-- Prerequisites:
-- - Database PHARMA_COMMERCIAL_ANALYTICS exists
-- - Schemas LANDING and FOUNDATION exist
-- - Stages STG_HCP, STG_RX, STG_TAXONOMY, STG_ENROLLMENT exist
-- - File Format CSV_FF exists
-- ===================================================================================

USE DATABASE PHARMA_COMMERCIAL_ANALYTICS;

USE SCHEMA FOUNDATION;

-- ===================================================================================
-- SECTION 1 : CREATE FOUNDATION RX TABLE
-- ===================================================================================

CREATE OR REPLACE TABLE FOUNDATION.F_RX
USING TEMPLATE
(
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
FROM TABLE
(
INFER_SCHEMA
(
LOCATION => '@PHARMA_COMMERCIAL_ANALYTICS.LANDING.STG_RX',
FILE_FORMAT => 'PHARMA_COMMERCIAL_ANALYTICS.LANDING.CSV_FF'
)
)
);

COMMENT ON TABLE FOUNDATION.F_RX IS
'Foundation layer table containing Medicare Part D Prescriber data.';

-- ===================================================================================
-- SECTION 2 : CREATE FOUNDATION TAXONOMY TABLE
-- ===================================================================================

CREATE OR REPLACE TABLE FOUNDATION.F_TAXONOMY
USING TEMPLATE
(
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
FROM TABLE
(
INFER_SCHEMA
(
LOCATION => '@PHARMA_COMMERCIAL_ANALYTICS.LANDING.STG_TAXONOMY',
FILE_FORMAT => 'PHARMA_COMMERCIAL_ANALYTICS.LANDING.CSV_FF'
)
)
);

COMMENT ON TABLE FOUNDATION.F_TAXONOMY IS
'Foundation layer table containing Healthcare Provider Taxonomy data.';

-- ===================================================================================
-- SECTION 3 : CREATE FOUNDATION HCP MASTER TABLE
-- ===================================================================================
--------------------------------------------------------------------------------------

-- NOTE:
-- The NPPES source file is approximately 11 GB.
-- It is recommended to use a representative sample file during development
-- while running INFER_SCHEMA().
--------------------------------

-- ===================================================================================

CREATE OR REPLACE TABLE FOUNDATION.F_HCP_MASTER
USING TEMPLATE
(
SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
FROM TABLE
(
INFER_SCHEMA
(
LOCATION => '@PHARMA_COMMERCIAL_ANALYTICS.LANDING.STG_HCP',
FILE_FORMAT => 'PHARMA_COMMERCIAL_ANALYTICS.LANDING.CSV_FF'
)
)
);

COMMENT ON TABLE FOUNDATION.F_HCP_MASTER IS
'Foundation layer table containing NPPES Healthcare Provider Master data.';

-- ===================================================================================
-- SECTION 4 : CREATE FOUNDATION ENROLLMENT TABLE
-- ===================================================================================
--------------------------------------------------------------------------------------

## -- Enrollment data will be generated later in the project.

-- ===================================================================================

CREATE OR REPLACE TABLE FOUNDATION.F_ENROLLMENT
(
PATIENT_ID          STRING
, ENROLLMENT_DATE     DATE
, HCP_ID              STRING
, TERRITORY           STRING
, REGION              STRING
, SOURCE_SYSTEM       STRING
);

COMMENT ON TABLE FOUNDATION.F_ENROLLMENT IS
'Foundation layer table containing patient enrollment data.';

-- ===================================================================================
-- SECTION 5 : ADD STANDARD AUDIT COLUMNS
-- ===================================================================================

ALTER TABLE FOUNDATION.F_RX
ADD COLUMN IF NOT EXISTS FILE_NAME STRING;

ALTER TABLE FOUNDATION.F_RX
ADD COLUMN IF NOT EXISTS LOAD_TS TIMESTAMP_NTZ;

ALTER TABLE FOUNDATION.F_TAXONOMY
ADD COLUMN IF NOT EXISTS FILE_NAME STRING;

ALTER TABLE FOUNDATION.F_TAXONOMY
ADD COLUMN IF NOT EXISTS LOAD_TS TIMESTAMP_NTZ;

ALTER TABLE FOUNDATION.F_HCP_MASTER
ADD COLUMN IF NOT EXISTS FILE_NAME STRING;

ALTER TABLE FOUNDATION.F_HCP_MASTER
ADD COLUMN IF NOT EXISTS LOAD_TS TIMESTAMP_NTZ;

ALTER TABLE FOUNDATION.F_ENROLLMENT
ADD COLUMN IF NOT EXISTS FILE_NAME STRING;

ALTER TABLE FOUNDATION.F_ENROLLMENT
ADD COLUMN IF NOT EXISTS LOAD_TS TIMESTAMP_NTZ;

-- ===================================================================================
-- SECTION 6 : VALIDATION
-- ===================================================================================

SHOW TABLES IN SCHEMA FOUNDATION;

DESC TABLE FOUNDATION.F_RX;

DESC TABLE FOUNDATION.F_TAXONOMY;

DESC TABLE FOUNDATION.F_HCP_MASTER;

DESC TABLE FOUNDATION.F_ENROLLMENT;

-- ===================================================================================
-- END OF SCRIPT
-- ===================================================================================
