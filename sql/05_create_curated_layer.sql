-- ===================================================================================
-- Script Name : 05_create_curated_layer.sql
-- Project     : Pharma Commercial Analytics Platform
-- Layer       : CURATED
-- Purpose     : Create Curated Layer Objects
---------------------------------------------

-- Description:
-- 1. Create DIM_HCP
-- 2. Create DIM_PRODUCT
-- 3. Create FACT_ENROLLMENT
-- 4. Create FACT_RX
--------------------

-- ===================================================================================

USE DATABASE PHARMA_COMMERCIAL_ANALYTICS;

USE SCHEMA CURATED;

USE WAREHOUSE TRANSFORM_WH;

-- ===================================================================================
-- SECTION 1 : DIM_HCP
-- ===================================================================================




CREATE OR REPLACE TABLE CURATED.DIM_HCP AS
SELECT
  H.NPI                                            AS HCP_ID
, REPLACE(H."Provider Last Name (Legal Name)",'',NULL)             AS LAST_NAME
, REPLACE(H."Provider First Name",'',NULL)                         AS FIRST_NAME
, COALESCE(REPLACE(H."Provider Credential Text",'',NULL),'NA')     AS CREDENTIALS
, H."Provider Sex Code"                            AS PROVIDER_SEX
, H."Healthcare Provider Taxonomy Code_1"          AS TAXONOMY_CODE
, T."Classification"                               AS CLASSIFICATION
, COALESCE(T."Specialization" ,'Other')            AS SPECIALIZATION
, H."Provider First Line Business Mailing Address"                 AS MAILING_ADDRESS_LINE1
, H."Provider Second Line Business Mailing Address"                AS MAILING_ADDRESS_LINE2
, H."Provider Business Mailing Address City Name"                  AS MAILING_CITY
, H."Provider Business Mailing Address State Name"                 AS MAILING_STATE
, H."Provider Business Mailing Address Postal Code"                AS MAILING_POSTAL_CODE
, H."Provider Business Mailing Address Telephone Number"           AS MAILING_TELEPHONE
,H. "Provider Organization Name (Legal Business Name)" AS ORGANIZATION_NAME
, H."Provider First Line Business Practice Location Address"       AS PRACTICE_ADDRESS_LINE1
, H."Provider Second Line Business Practice Location Address"      AS PRACTICE_ADDRESS_LINE2
, H."Provider Business Practice Location Address City Name"        AS PRACTICE_CITY
, H."Provider Business Practice Location Address State Name"       AS PRACTICE_STATE
, H."Provider Business Practice Location Address Postal Code"      AS PRACTICE_POSTAL_CODE
, H."Provider Business Practice Location Address Telephone Number" AS PRACTICE_TELEPHONE
, H."Provider Business Mailing Address State Name" AS STATE
, TARGET.REGION
FROM FOUNDATION.F_HCP_MASTER H
LEFT JOIN FOUNDATION.F_TAXONOMY T
ON H."Healthcare Provider Taxonomy Code_1" = T."Code"
LEFT JOIN CURATED.DIM_TARGET_HCP TARGET
ON H.NPI = TARGET.HCP_ID
where "Provider First Name" <> '';

COMMENT ON TABLE CURATED.DIM_HCP IS
'Curated HCP Dimension enriched with taxonomy and region information.';

-- ===================================================================================
-- SECTION 2 : DIM_PRODUCT
-- ===================================================================================

CREATE OR REPLACE TABLE CURATED.DIM_PRODUCT
(
PRODUCT_ID      NUMBER
, PRODUCT_NAME    STRING
);

INSERT INTO CURATED.DIM_PRODUCT
VALUES
(1,'Product_A')
, (2,'Product_B')
, (3,'Product_C');

COMMENT ON TABLE CURATED.DIM_PRODUCT IS
'Curated Product Dimension.';

-- ===================================================================================
-- SECTION 3 : FACT_ENROLLMENT
-- ===================================================================================

CREATE OR REPLACE TABLE CURATED.FACT_ENROLLMENT AS
SELECT
E.PATIENT_ID
, E.ENROLLMENT_DATE
, E.HCP_ID
, P.PRODUCT_ID
, E.PRODUCT_NAME
, E.STATE
, E.REGION
, E.ENROLLMENT_STATUS
, E.SOURCE_SYSTEM
FROM FOUNDATION.F_ENROLLMENT E
LEFT JOIN CURATED.DIM_PRODUCT P
ON E.PRODUCT_NAME = P.PRODUCT_NAME;

COMMENT ON TABLE CURATED.FACT_ENROLLMENT IS
'Enrollment fact table.';

-- ===================================================================================
-- SECTION 4 : FACT_RX
-- ===================================================================================
--------------------------------------------------------------------------------------

-- Foundation RX contains provider-level metrics.
-- We standardize it into an analytics-friendly fact table.
-----------------------------------------------------------

-- ===================================================================================

CREATE OR REPLACE TABLE CURATED.FACT_RX AS
SELECT
  PRSCRBR_NPI :: VARCHAR(10)                       AS HCP_ID
, "Prscrbr_Last_Org_Name"                          AS PRESCRIBER_LAST_NAME
, "Prscrbr_First_Name"                             AS PRESCRIBER_FIRST_NAME
, "Prscrbr_MI"                                     AS PRESCRIBER_MI
, "Prscrbr_Crdntls"                                AS PRESCRIBER_CREDENTIALS
, "Prscrbr_Ent_Cd"                                 AS PRESCRIBER_ENTITY_CODE
, "Prscrbr_St1"                                    AS PRESCRIBER_STREET1
, "Prscrbr_St2"                                    AS PRESCRIBER_STREET2
, "Prscrbr_City"                                   AS PRESCRIBER_CITY
, "Prscrbr_State_Abrvtn"                           AS PRESCRIBER_STATE
, "Prscrbr_State_FIPS"                             AS PRESCRIBER_STATE_FIPS
, "Prscrbr_zip5"                                   AS PRESCRIBER_ZIP5
, "Prscrbr_RUCA"                                   AS PRESCRIBER_RUCA
, "Prscrbr_RUCA_Desc"                              AS PRESCRIBER_RUCA_DESC
, "Prscrbr_Cntry"                                  AS PRESCRIBER_COUNTRY
, "Prscrbr_Type"                                   AS PRESCRIBER_TYPE
, "Prscrbr_Type_src"                               AS PRESCRIBER_TYPE_SRC
, "Tot_Clms"                                       AS TOTAL_CLAIMS
, "Tot_30day_Fills"                                AS TOTAL_30DAY_FILLS
, "Tot_Drug_Cst"                                   AS TOTAL_DRUG_COST
, "Tot_Day_Suply"                                  AS TOTAL_DAY_SUPPLY
, "Tot_Benes"                                      AS TOTAL_BENEFICIARIES
, "GE65_Sprsn_Flag"                                AS GE65_SUPPRESSION_FLAG
, "GE65_Tot_Clms"                                  AS GE65_TOTAL_CLAIMS
, "GE65_Tot_30day_Fills"                           AS GE65_TOTAL_30DAY_FILLS
, "GE65_Tot_Drug_Cst"                              AS GE65_TOTAL_DRUG_COST
, "GE65_Tot_Day_Suply"                             AS GE65_TOTAL_DAY_SUPPLY
, "GE65_Bene_Sprsn_Flag"                           AS GE65_BENE_SUPPRESSION_FLAG
, "GE65_Tot_Benes"                                 AS GE65_TOTAL_BENEFICIARIES
, "Brnd_Sprsn_Flag"                                AS BRAND_SUPPRESSION_FLAG
, "Brnd_Tot_Clms"                                  AS BRAND_TOTAL_CLAIMS
, "Brnd_Tot_Drug_Cst"                              AS BRAND_TOTAL_DRUG_COST
, "Gnrc_Sprsn_Flag"                                AS GENERIC_SUPPRESSION_FLAG
, "Gnrc_Tot_Clms"                                  AS GENERIC_TOTAL_CLAIMS
, "Gnrc_Tot_Drug_Cst"                              AS GENERIC_TOTAL_DRUG_COST
, "Othr_Sprsn_Flag"                                AS OTHER_SUPPRESSION_FLAG
, "Othr_Tot_Clms"                                  AS OTHER_TOTAL_CLAIMS
, "Othr_Tot_Drug_Cst"                              AS OTHER_TOTAL_DRUG_COST
, "MAPD_Sprsn_Flag"                                AS MAPD_SUPPRESSION_FLAG
, "MAPD_Tot_Clms"                                  AS MAPD_TOTAL_CLAIMS
, "MAPD_Tot_Drug_Cst"                              AS MAPD_TOTAL_DRUG_COST
, "PDP_Sprsn_Flag"                                 AS PDP_SUPPRESSION_FLAG
, "PDP_Tot_Clms"                                   AS PDP_TOTAL_CLAIMS
, "PDP_Tot_Drug_Cst"                               AS PDP_TOTAL_DRUG_COST
, "LIS_Sprsn_Flag"                                 AS LIS_SUPPRESSION_FLAG
, "LIS_Tot_Clms"                                   AS LIS_TOTAL_CLAIMS
, "LIS_Drug_Cst"                                   AS LIS_DRUG_COST
, "NonLIS_Sprsn_Flag"                              AS NONLIS_SUPPRESSION_FLAG
, "NonLIS_Tot_Clms"                                AS NONLIS_TOTAL_CLAIMS
, "NonLIS_Drug_Cst"                                AS NONLIS_DRUG_COST
, "Opioid_Tot_Clms"                                AS OPIOID_CLAIMS
, "Opioid_Tot_Drug_Cst"                            AS OPIOID_DRUG_COST
, "Opioid_Tot_Suply"                               AS OPIOID_TOTAL_SUPPLY
, "Opioid_Tot_Benes"                               AS OPIOID_TOTAL_BENEFICIARIES
, "Opioid_Prscrbr_Rate"                            AS OPIOID_PRESCRIBER_RATE
, "Opioid_LA_Tot_Clms"                             AS OPIOID_LA_TOTAL_CLAIMS
, "Opioid_LA_Tot_Drug_Cst"                         AS OPIOID_LA_DRUG_COST
, "Opioid_LA_Tot_Suply"                            AS OPIOID_LA_TOTAL_SUPPLY
, "Opioid_LA_Tot_Benes"                            AS OPIOID_LA_TOTAL_BENEFICIARIES
, "Opioid_LA_Prscrbr_Rate"                         AS OPIOID_LA_PRESCRIBER_RATE
, "Antbtc_Tot_Clms"                                AS ANTIBIOTIC_CLAIMS
, "Antbtc_Tot_Drug_Cst"                            AS ANTIBIOTIC_DRUG_COST
, "Antbtc_Tot_Benes"                               AS ANTIBIOTIC_TOTAL_BENEFICIARIES
, "Antpsyct_GE65_Sprsn_Flag"                       AS ANTIPSYCHOTIC_GE65_SUPPRESSION_FLAG
, "Antpsyct_GE65_Tot_Clms"                         AS ANTIPSYCHOTIC_GE65_TOTAL_CLAIMS
, "Antpsyct_GE65_Tot_Drug_Cst"                     AS ANTIPSYCHOTIC_GE65_DRUG_COST
, "Antpsyct_GE65_Bene_Suprsn_Flag"                 AS ANTIPSYCHOTIC_GE65_BENE_SUPPRESSION_FLAG
, "Antpsyct_GE65_Tot_Benes"                        AS ANTIPSYCHOTIC_GE65_TOTAL_BENEFICIARIES
, "Bene_Avg_Age"                                   AS AVG_BENEFICIARY_AGE
, "Bene_Age_LT_65_Cnt"                             AS BENE_AGE_LT_65_COUNT
, "Bene_Age_65_74_Cnt"                             AS BENE_AGE_65_74_COUNT
, "Bene_Age_75_84_Cnt"                             AS BENE_AGE_75_84_COUNT
, "Bene_Age_GT_84_Cnt"                             AS BENE_AGE_GT_84_COUNT
, "Bene_Feml_Cnt"                                  AS BENE_FEMALE_COUNT
, "Bene_Male_Cnt"                                  AS BENE_MALE_COUNT
, "Bene_Race_Wht_Cnt"                              AS BENE_RACE_WHITE_COUNT
, "Bene_Race_Black_Cnt"                            AS BENE_RACE_BLACK_COUNT
, "Bene_Race_Api_Cnt"                              AS BENE_RACE_API_COUNT
, "Bene_Race_Hspnc_Cnt"                            AS BENE_RACE_HISPANIC_COUNT
, "Bene_Race_Natind_Cnt"                           AS BENE_RACE_NATIND_COUNT
, "Bene_Race_Othr_Cnt"                             AS BENE_RACE_OTHER_COUNT
, "Bene_Dual_Cnt"                                  AS BENE_DUAL_COUNT
, "Bene_Ndual_Cnt"                                 AS BENE_NDUAL_COUNT
, "Bene_Avg_Risk_Scre"                             AS BENE_AVG_RISK_SCORE
, FILE_NAME
, LOAD_TS
FROM FOUNDATION.F_RX;

COMMENT ON TABLE CURATED.FACT_RX IS
'Prescription fact table derived from Medicare Part D data.';

-- ===================================================================================
-- SECTION 5 : VALIDATION
-- ===================================================================================

SELECT COUNT(*) AS DIM_HCP_COUNT
FROM CURATED.DIM_HCP;

SELECT COUNT(*) AS DIM_PRODUCT_COUNT
FROM CURATED.DIM_PRODUCT;

SELECT COUNT(*) AS FACT_ENROLLMENT_COUNT
FROM CURATED.FACT_ENROLLMENT;

SELECT COUNT(*) AS FACT_RX_COUNT
FROM CURATED.FACT_RX;

-- ===================================================================================
-- END OF SCRIPT
-- ===================================================================================
