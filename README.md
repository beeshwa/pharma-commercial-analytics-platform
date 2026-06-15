# **Pharma Commercial Analytics Platform**
## **Overview**

This project demonstrates the design and implementation of a production-style Data Engineering solution on Snowflake for pharmaceutical commercial analytics.

The platform ingests healthcare provider (HCP), patient enrollment, and prescription datasets from AWS S3 into Snowflake, applies automated transformations using Streams and Tasks, and delivers business-ready metrics for reporting and analysis.

## **Business Problem**

Pharmaceutical organizations rely on multiple data sources to track commercial performance. This project centralizes provider, enrollment, and prescription data to provide insights into:

Total Enrollments
New Enrollments
Total TRx
Total NRx
HCPs with New Enrollments
Territory Performance
Specialty Performance


## **Architecture**


Source Files
     │
     ▼
AWS S3
     │
     ▼
Snowflake Stage
     │
     ▼
Snowpipe
     │
     ▼
RAW Layer
     │
     ▼
Streams & Tasks
     │
     ▼
CURATED Layer
     │
     ▼
MART Layer
     │
     ▼
Tableau Dashboard


## **Technology Stack**

  Snowflake
  AWS S3
  Snowpipe
  Streams
  Storage Integration
  File Format
  Tasks
  SQL
  Tableau
  GitHub
  

## **Data Layers**
   **RAW Layer**

      Stores source files in their original format.

   **CURATED Layer**

      Applies cleansing, standardization, and business rules.

   **MART Layer**

      Provides reporting-ready datasets and KPI calculations.

## **Project Goals**
    Build a scalable cloud-native data pipeline
    Demonstrate Snowflake Data Engineering concepts
    Implement automated ingestion and transformation workflows
    Deliver pharma commercial analytics KPIs

## **Future Enhancements**
    dbt Integration
    Data Quality Framework
    CI/CD Pipeline
    Snowpark Transformations
    Monitoring & Alerting
