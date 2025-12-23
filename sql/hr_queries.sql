/* ======================================================
   HR ANALYTICS PROJECT – SQL QUERIES
   Author: Syed Saad Hassan
   Database: MySQL
   Description: Data merging, KPI calculation, and
   attrition analysis for HR analytics project
   ====================================================== */

/* ======================
   DATABASE SETUP
   ====================== */
CREATE DATABASE hr_project;
USE hr_project;

/* ======================
   DATA VALIDATION
   ====================== */
SELECT COUNT(*) AS cnt_hr1 FROM hr_01;
SELECT COUNT(*) AS cnt_hr2 FROM hr_02;

SELECT * FROM hr_01 LIMIT 5;
SELECT * FROM hr_02 LIMIT 5;

/* ======================
   DATA MERGING
   ====================== */
CREATE TABLE hr_merged AS
SELECT
  EmployeeNumber AS EmployeeID,
  Department,
  JobRole,
  Gender,
  Attrition,
  MonthlyIncome,
  YearsAtCompany,
  YearsSinceLastPromotion,
  HourlyRate,
  WorkLifeBalance,
  TotalWorkingYears
FROM hr_01
LEFT JOIN hr_02
  ON EmployeeNumber = EmployeeID;

SELECT COUNT(*) FROM hr_merged;
SELECT * FROM hr_merged LIMIT 10;

/* ======================
   INDEXING & OPTIMIZATION
   ====================== */
ALTER TABLE hr_merged
MODIFY Department VARCHAR(100);

ALTER TABLE hr_merged
ADD INDEX idx_department (Department(100));

ALTER TABLE hr_merged
ADD INDEX idx_emp (EmployeeID);

DESCRIBE hr_merged;

/* ======================
   BASIC METRICS
   ====================== */
-- Total employees
SELECT COUNT(*) AS total_employees
FROM hr_merged;

-- Active employees (not attrited)
SELECT COUNT(*) AS active_employees
FROM hr_merged
WHERE LOWER(Attrition) = 'no';

/* ======================
   KPI 1: ATTRITION RATE
   ====================== */
-- Overall attrition rate
SELECT
  ROUND(
    100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS overall_attrition_pct
FROM hr_merged;

-- Attrition rate by department
SELECT
  Department,
  COUNT(*) AS total_employees,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
  ROUND(
    100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS attrition_pct
FROM hr_merged
GROUP BY Department
ORDER BY attrition_pct DESC;

/* ======================
   KPI 2: AVG HOURLY RATE
   ====================== */
SELECT
  COUNT(*) AS cnt,
  ROUND(AVG(HourlyRate), 2) AS avg_hourly_rate
FROM hr_merged
WHERE Gender = 'Male'
  AND JobRole LIKE '%Research Scientist%';

/* ======================
   KPI 3: ATTRITION VS INCOME
   ====================== */
SELECT
  CASE
    WHEN MonthlyIncome < 30000 THEN '<30k'
    WHEN MonthlyIncome BETWEEN 30000 AND 49999 THEN '30k-49k'
    WHEN MonthlyIncome BETWEEN 50000 AND 99999 THEN '50k-99k'
    ELSE '100k+'
  END AS income_bucket,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
  ROUND(
    100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS attrition_pct,
  ROUND(AVG(MonthlyIncome), 2) AS avg_income
FROM hr_merged
GROUP BY income_bucket
ORDER BY income_bucket;

/* ======================
   KPI 4: EXPERIENCE METRICS
   ====================== */
SELECT
  Department,
  COUNT(*) AS total,
  ROUND(AVG(YearsAtCompany), 2) AS avg_years_at_company,
  ROUND(AVG(TotalWorkingYears), 2) AS avg_total_working_years
FROM hr_merged
GROUP BY Department
ORDER BY avg_years_at_company DESC;

/* ======================
   KPI 5: JOB ROLE vs WLB
   ====================== */
SELECT
  JobRole,
  WorkLifeBalance,
  COUNT(*) AS cnt,
  ROUND(
    100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS attrition_pct
FROM hr_merged
GROUP BY JobRole, WorkLifeBalance
ORDER BY JobRole, WorkLifeBalance;

/* ======================
   KPI 6: PROMOTION DELAY
   ====================== */
SELECT
  YearsSinceLastPromotion,
  COUNT(*) AS total,
  SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS attrited,
  ROUND(
    100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*),
    2
  ) AS attrition_pct
FROM hr_merged
GROUP BY YearsSinceLastPromotion
ORDER BY YearsSinceLastPromotion;
