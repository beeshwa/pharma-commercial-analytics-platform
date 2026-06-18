-- ===================================================================================
-- Script Name : 06_create_analytics_layer.sql
-- Project     : Pharma Commercial Analytics Platform
-- Layer       : ANALYTICS
-- Purpose     : Create Analytics Layer Data Marts
--------------------------------------------------

-- Description:
-- 1. Create HCP_PERFORMANCE
-- 2. Create EXECUTIVE_KPI_SUMMARY
-- 3. Create STATE_PERFORMANCE
-- 4. Create SPECIALTY_PERFORMANCE
-- 5. Create PRODUCT_PERFORMANCE
-- 6. Create MONTHLY_TRENDS
-------------------------------------

-- ===================================================================================

USE DATABASE PHARMA_COMMERCIAL_ANALYTICS;

USE SCHEMA ANALYTICS;

USE WAREHOUSE TRANSFORM_WH;

-- ===================================================================================
-- SECTION 1 : HCP PERFORMANCE
-- Grain : One Row Per HCP
-- ===================================================================================

CREATE OR REPLACE TABLE ANALYTICS.HCP_PERFORMANCE AS

WITH ENROLLMENT_AGG AS
(
SELECT
HCP_ID
, COUNT(DISTINCT PATIENT_ID)                               AS TOTAL_ENROLLMENTS
, COUNT_IF(ENROLLMENT_STATUS='ACTIVE')                     AS ACTIVE_PATIENTS
, COUNT_IF(ENROLLMENT_STATUS='PENDING')                    AS PENDING_PATIENTS
, COUNT_IF(ENROLLMENT_STATUS='DISCONTINUED')               AS DISCONTINUED_PATIENTS
FROM CURATED.FACT_ENROLLMENT
GROUP BY HCP_ID
),

RX_AGG AS
(
SELECT
HCP_ID
, SUM(TOTAL_CLAIMS)                                        AS TOTAL_CLAIMS
, SUM(TOTAL_30DAY_FILLS)                                   AS TOTAL_30DAY_FILLS
, SUM(TOTAL_DRUG_COST)                                     AS TOTAL_DRUG_COST
, SUM(TOTAL_BENEFICIARIES)                                 AS TOTAL_BENEFICIARIES
, SUM(BRAND_TOTAL_CLAIMS)                                  AS BRAND_TOTAL_CLAIMS
, SUM(GENERIC_TOTAL_CLAIMS)                                AS GENERIC_TOTAL_CLAIMS
, SUM(OPIOID_CLAIMS)                                       AS OPIOID_CLAIMS
, SUM(ANTIBIOTIC_CLAIMS)                                   AS ANTIBIOTIC_CLAIMS
, AVG(AVG_BENEFICIARY_AGE)                                 AS AVG_BENEFICIARY_AGE
, AVG(BENE_AVG_RISK_SCORE)                                 AS AVG_RISK_SCORE
, SUM(BENE_FEMALE_COUNT)                                   AS FEMALE_BENEFICIARIES
, SUM(BENE_MALE_COUNT)                                     AS MALE_BENEFICIARIES
, SUM(BENE_RACE_WHITE_COUNT)                               AS WHITE_BENEFICIARIES
, SUM(BENE_RACE_BLACK_COUNT)                               AS BLACK_BENEFICIARIES
, SUM(BENE_RACE_HISPANIC_COUNT)                            AS HISPANIC_BENEFICIARIES
FROM CURATED.FACT_RX
GROUP BY HCP_ID
)

SELECT
  H.HCP_ID
, H.FIRST_NAME
, H.LAST_NAME
, H.CREDENTIALS
, H.PROVIDER_SEX
, H.CLASSIFICATION
, H.SPECIALIZATION
, H.STATE
, H.REGION
, COALESCE(E.TOTAL_ENROLLMENTS,0)                              AS TOTAL_ENROLLMENTS
, COALESCE(E.ACTIVE_PATIENTS,0)                                AS ACTIVE_PATIENTS
, COALESCE(E.PENDING_PATIENTS,0)                               AS PENDING_PATIENTS
, COALESCE(E.DISCONTINUED_PATIENTS,0)                          AS DISCONTINUED_PATIENTS
, COALESCE(R.TOTAL_CLAIMS,0)                                   AS TOTAL_CLAIMS
, COALESCE(R.TOTAL_30DAY_FILLS,0)                              AS TOTAL_30DAY_FILLS
, COALESCE(R.TOTAL_DRUG_COST,0)                                AS TOTAL_DRUG_COST
, COALESCE(R.TOTAL_BENEFICIARIES,0)                            AS TOTAL_BENEFICIARIES
, COALESCE(R.BRAND_TOTAL_CLAIMS,0)                             AS BRAND_TOTAL_CLAIMS
, COALESCE(R.GENERIC_TOTAL_CLAIMS,0)                           AS GENERIC_TOTAL_CLAIMS
, COALESCE(R.OPIOID_CLAIMS,0)                                  AS OPIOID_CLAIMS
, COALESCE(R.ANTIBIOTIC_CLAIMS,0)                              AS ANTIBIOTIC_CLAIMS
, R.AVG_BENEFICIARY_AGE
, R.AVG_RISK_SCORE
, COALESCE(R.FEMALE_BENEFICIARIES,0)                           AS FEMALE_BENEFICIARIES
, COALESCE(R.MALE_BENEFICIARIES,0)                             AS MALE_BENEFICIARIES
, COALESCE(R.WHITE_BENEFICIARIES,0)                            AS WHITE_BENEFICIARIES
, COALESCE(R.BLACK_BENEFICIARIES,0)                            AS BLACK_BENEFICIARIES
, COALESCE(R.HISPANIC_BENEFICIARIES,0)                         AS HISPANIC_BENEFICIARIES
FROM CURATED.DIM_HCP H
LEFT JOIN ENROLLMENT_AGG E
ON H.HCP_ID = E.HCP_ID
LEFT JOIN RX_AGG R
ON H.HCP_ID = R.HCP_ID;

-- ===================================================================================
-- SECTION 2 : EXECUTIVE KPI SUMMARY
-- Grain : Single Row
-- ===================================================================================

CREATE OR REPLACE TABLE ANALYTICS.EXECUTIVE_KPI_SUMMARY AS
SELECT


  SUM(TOTAL_ENROLLMENTS)                                       AS TOTAL_ENROLLMENTS
, SUM(ACTIVE_PATIENTS)                                         AS ACTIVE_PATIENTS
, SUM(PENDING_PATIENTS)                                        AS PENDING_PATIENTS
, SUM(DISCONTINUED_PATIENTS)                                   AS DISCONTINUED_PATIENTS

, COUNT(DISTINCT HCP_ID)                                       AS TOTAL_TARGET_HCPS

, SUM(TOTAL_CLAIMS)                                             AS TOTAL_CLAIMS
, SUM(TOTAL_30DAY_FILLS)                                        AS TOTAL_30DAY_FILLS
, SUM(TOTAL_DRUG_COST)                                          AS TOTAL_DRUG_COST
, SUM(TOTAL_BENEFICIARIES)                                      AS TOTAL_BENEFICIARIES

, AVG(AVG_BENEFICIARY_AGE)                                      AS AVG_BENEFICIARY_AGE
, AVG(AVG_RISK_SCORE)                                           AS AVG_RISK_SCORE


FROM ANALYTICS.HCP_PERFORMANCE;

-- ===================================================================================
-- SECTION 3 : STATE PERFORMANCE
-- Grain : STATE + REGION
-- ===================================================================================

CREATE OR REPLACE TABLE ANALYTICS.STATE_PERFORMANCE AS
SELECT

  STATE
, REGION

, SUM(TOTAL_ENROLLMENTS)                                       AS TOTAL_ENROLLMENTS
, SUM(ACTIVE_PATIENTS)                                         AS ACTIVE_PATIENTS
, SUM(DISCONTINUED_PATIENTS)                                   AS DISCONTINUED_PATIENTS

, COUNT(DISTINCT HCP_ID)                                       AS TOTAL_HCPS

, SUM(TOTAL_CLAIMS)                                            AS TOTAL_CLAIMS
, SUM(TOTAL_DRUG_COST)                                         AS TOTAL_DRUG_COST
, SUM(TOTAL_BENEFICIARIES)                                     AS TOTAL_BENEFICIARIES

, AVG(AVG_RISK_SCORE)                                          AS AVG_RISK_SCORE

FROM ANALYTICS.HCP_PERFORMANCE
GROUP BY STATE, REGION;

-- ===================================================================================
-- SECTION 4 : SPECIALTY PERFORMANCE
-- Grain : CLASSIFICATION + SPECIALIZATION
-- ===================================================================================

CREATE OR REPLACE TABLE ANALYTICS.SPECIALTY_PERFORMANCE AS
SELECT


  CLASSIFICATION
, SPECIALIZATION

, SUM(TOTAL_ENROLLMENTS)                                       AS TOTAL_ENROLLMENTS
, SUM(TOTAL_CLAIMS)                                            AS TOTAL_CLAIMS
, SUM(TOTAL_DRUG_COST)                                         AS TOTAL_DRUG_COST
, SUM(TOTAL_BENEFICIARIES)                                     AS TOTAL_BENEFICIARIES

, AVG(AVG_RISK_SCORE)                                          AS AVG_RISK_SCORE


FROM ANALYTICS.HCP_PERFORMANCE
GROUP BY
CLASSIFICATION
, SPECIALIZATION;

-- ===================================================================================
-- SECTION 5 : PRODUCT PERFORMANCE
-- Grain : PRODUCT
-- ===================================================================================

CREATE OR REPLACE TABLE ANALYTICS.PRODUCT_PERFORMANCE AS
SELECT

  PRODUCT_NAME
, COUNT(DISTINCT PATIENT_ID)                                   AS TOTAL_ENROLLMENTS
, COUNT_IF(ENROLLMENT_STATUS='ACTIVE')                         AS ACTIVE_PATIENTS
, COUNT_IF(ENROLLMENT_STATUS='PENDING')                        AS PENDING_PATIENTS
, COUNT_IF(ENROLLMENT_STATUS='DISCONTINUED')                   AS DISCONTINUED_PATIENTS
, COUNT(DISTINCT HCP_ID)                                       AS TOTAL_HCPS


FROM CURATED.FACT_ENROLLMENT
GROUP BY PRODUCT_NAME;

-- ===================================================================================
-- SECTION 6 : MONTHLY TRENDS
-- Grain : MONTH + PRODUCT + REGION
-- ===================================================================================

CREATE OR REPLACE TABLE ANALYTICS.MONTHLY_TRENDS AS
SELECT
  DATE_TRUNC('MONTH', ENROLLMENT_DATE)                         AS MONTH_START_DATE
, PRODUCT_NAME
, REGION
, COUNT(DISTINCT PATIENT_ID)                                   AS TOTAL_ENROLLMENTS
, COUNT_IF(ENROLLMENT_STATUS='ACTIVE')                         AS ACTIVE_PATIENTS
, COUNT(DISTINCT HCP_ID)                                       AS ACTIVE_HCPS
FROM CURATED.FACT_ENROLLMENT

GROUP BY
DATE_TRUNC('MONTH', ENROLLMENT_DATE)
, PRODUCT_NAME
, REGION;

-- ===================================================================================
-- SECTION 7 : VALIDATION
-- ===================================================================================

SELECT COUNT(*) AS HCP_PERFORMANCE_COUNT
FROM ANALYTICS.HCP_PERFORMANCE;

SELECT COUNT(*) AS EXECUTIVE_KPI_SUMMARY_COUNT
FROM ANALYTICS.EXECUTIVE_KPI_SUMMARY;

SELECT COUNT(*) AS STATE_PERFORMANCE_COUNT
FROM ANALYTICS.STATE_PERFORMANCE;

SELECT COUNT(*) AS SPECIALTY_PERFORMANCE_COUNT
FROM ANALYTICS.SPECIALTY_PERFORMANCE;

SELECT COUNT(*) AS PRODUCT_PERFORMANCE_COUNT
FROM ANALYTICS.PRODUCT_PERFORMANCE;

SELECT COUNT(*) AS MONTHLY_TRENDS_COUNT
FROM ANALYTICS.MONTHLY_TRENDS;

-- ===================================================================================
-- END OF SCRIPT
-- ===================================================================================
