-- ===================================================================================
-- Script Name : 04_generate_enrollment_data.sql
-- Project     : Pharma Commercial Analytics Platform
-- Layer       : FOUNDATION
-- Purpose     : Generate Synthetic Patient Enrollment Data
-----------------------------------------------------------

-- Description:
-- 1. Create Target HCP Universe (50,000 HCPs)
-- 2. Generate 1,000,000 Enrollment Records
-- 3. Use Real NPIs and States from NPPES
-- 4. Simulate Product Adoption and Enrollment Status
-----------------------------------------------------

-- ===================================================================================

USE DATABASE PHARMA_COMMERCIAL_ANALYTICS;

USE WAREHOUSE TRANSFORM_WH;

-- ===================================================================================
-- STEP 1 : CREATE TARGET HCP UNIVERSE
-- ===================================================================================

CREATE OR REPLACE TABLE CURATED.DIM_TARGET_HCP AS
SELECT
      NPI AS HCP_ID
    , "Provider Business Mailing Address State Name" AS STATE
    , CASE
          WHEN STATE IN ('ME','NH','VT','MA','RI','CT','NY','NJ','PA')
               THEN 'NORTHEAST'

          WHEN STATE IN ('IL','IN','MI','OH','WI','IA','KS','MN','MO','NE','ND','SD')
               THEN 'MIDWEST'

          WHEN STATE IN ('DE','FL','GA','MD','NC','SC','VA','DC','WV','AL','KY','MS','TN','AR','LA','OK','TX')
               THEN 'SOUTH'

          ELSE 'WEST'
      END AS REGION
FROM FOUNDATION.F_HCP_MASTER
WHERE UPPER("Provider Business Mailing Address State Name") IN
(
'AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA',
'HI','ID','IL','IN','IA','KS','KY','LA','ME','MD',
'MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ',
'NM','NY','NC','ND','OH','OK','OR','PA','RI','SC',
'SD','TN','TX','UT','VT','VA','WA','WV','WI','WY',
'DC'
) AND "Provider First Name" <> ''
QUALIFY ROW_NUMBER() OVER (ORDER BY RANDOM()) <= 50000;

-- ===================================================================================
-- STEP 2 : CREATE ENROLLMENT TABLE
-- ===================================================================================

CREATE OR REPLACE TABLE FOUNDATION.F_ENROLLMENT
(
      PATIENT_ID          STRING
    , ENROLLMENT_DATE     DATE
    , HCP_ID             STRING
    , PRODUCT_NAME       STRING
    , STATE              STRING
    , REGION              STRING
    , ENROLLMENT_STATUS  STRING
    , SOURCE_SYSTEM      STRING
);

-- ===================================================================================
-- STEP 3 : GENERATE 1 MILLION ENROLLMENT RECORDS
-- ===================================================================================
--------------------------------------------------------------------------------------

-- Product Distribution
-- Product_A = 50%
-- Product_B = 30%
-- Product_C = 20%
------------------

-- Status Distribution
-- ACTIVE       = 75%
-- PENDING      = 15%
-- DISCONTINUED = 10%
---------------------

-- ===================================================================================

INSERT INTO FOUNDATION.F_ENROLLMENT
    (PATIENT_ID, ENROLLMENT_DATE, HCP_ID, PRODUCT_NAME, STATE,REGION, ENROLLMENT_STATUS, SOURCE_SYSTEM)
SELECT
'PAT' || LPAD(SEQ4()::STRING, 10, '0')                           AS PATIENT_ID

, DATEADD(
      DAY,
      -UNIFORM(0, 730, RANDOM()),
      CURRENT_DATE()
  )                                                                AS ENROLLMENT_DATE

, H.HCP_ID

, CASE
      WHEN RANDOM() % 100 < 50 THEN 'Product_A'
      WHEN RANDOM() % 100 < 80 THEN 'Product_B'
      ELSE 'Product_C'
  END                                                              AS PRODUCT_NAME

, H.STATE
, H.REGION
, CASE
      WHEN RANDOM() % 100 < 75 THEN 'ACTIVE'
      WHEN RANDOM() % 100 < 90 THEN 'PENDING'
      ELSE 'DISCONTINUED'
  END                                                              AS ENROLLMENT_STATUS

, 'CRM'                                                            AS SOURCE_SYSTEM

FROM
(
SELECT *
FROM CURATED.DIM_TARGET_HCP
) H

CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 20));

-- ===================================================================================
-- STEP 4 : VALIDATION
-- ===================================================================================

SELECT COUNT(*) AS TOTAL_ENROLLMENTS
FROM FOUNDATION.F_ENROLLMENT;

SELECT PRODUCT_NAME,
COUNT(*) AS ENROLLMENTS
FROM FOUNDATION.F_ENROLLMENT
GROUP BY PRODUCT_NAME
ORDER BY ENROLLMENTS DESC;

SELECT ENROLLMENT_STATUS,
COUNT(*) AS ENROLLMENTS
FROM FOUNDATION.F_ENROLLMENT
GROUP BY ENROLLMENT_STATUS
ORDER BY ENROLLMENTS DESC;

SELECT STATE,
COUNT(*) AS ENROLLMENTS
FROM FOUNDATION.F_ENROLLMENT
GROUP BY STATE
ORDER BY ENROLLMENTS DESC
LIMIT 20;

-- ===================================================================================
-- END OF SCRIPT
-- ===================================================================================
