USE talentlens;
-- ============================================================
-- SECTION 1 — DATASET OVERVIEW
-- ============================================================

-- Query 1: Total number of jobs in the dataset
SELECT COUNT(*) AS Total_Jobs
FROM jobs;

-- Result: Total_Jobs = 1000

-- Query 2: Total jobs split by career path
SELECT
    Career_Path,
    COUNT(*) AS Total_Jobs,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM jobs), 1) AS Percentage
FROM jobs
GROUP BY Career_Path
ORDER BY Total_Jobs DESC;

-- Result:
-- Data Analytics = 600 jobs (60%)
-- UI/UX Design = 400 jobs (40%)

-- Query 3: Total unique companies, cities, and job titles
SELECT
    COUNT(DISTINCT Company) AS Unique_Companies,
    COUNT(DISTINCT Location) AS Unique_Cities,
    COUNT(DISTINCT Job_Title) AS Unique_Job_Roles
FROM jobs;

-- Result:
-- Unique Companies = 20
-- Unique Cities = 8
-- Unique Job Roles = 10

-- Query 4: Overall average, minimum, and maximum salary
SELECT
    ROUND(AVG(Salary_LPA), 2) AS Avg_Salary,
    MIN(Salary_LPA) AS Min_Salary,
    MAX(Salary_LPA) AS Max_Salary
FROM jobs;

-- Result:
-- Average Salary = 10.28 LPA
-- Minimum Salary = 4.00 LPA
-- Maximum Salary = 25.00 LPA

-- ============================================================
-- SECTION 2 — SALARY ANALYSIS
-- ============================================================

-- Query 5: Average salary by career path
SELECT
    Career_Path,
    COUNT(*) AS Total_Jobs,
    ROUND(AVG(Salary_LPA), 2) AS Avg_Salary_LPA,
    ROUND(MIN(Salary_LPA), 2) AS Min_Salary,
    ROUND(MAX(Salary_LPA), 2) AS Max_Salary
FROM jobs
GROUP BY Career_Path
ORDER BY Avg_Salary_LPA DESC;

-- Result:
-- UI/UX Design = Avg 10.51 LPA
-- Data Analytics = Avg 10.13 LPA

-- Query 6: Salary by career path and experience level
SELECT
    Career_Path,
    Experience,
    COUNT(*) AS Jobs_Count,
    ROUND(AVG(Salary_LPA), 2) AS Avg_Salary_LPA
FROM jobs
GROUP BY Career_Path, Experience
ORDER BY Career_Path, Avg_Salary_LPA;

-- Result:
-- Data Analytics:
--   0–2 Years = 6.10 LPA
--   1–3 Years = 10.80 LPA
--   3–5 Years = 18.20 LPA
--
-- UI/UX Design:
--   0–2 Years = 7.00 LPA
--   1–3 Years = 12.10 LPA
--   3–5 Years = 20.10 LPA

-- Query 7: Which career path pays more at each experience level?
SELECT
    Experience,
    ROUND(AVG(CASE WHEN Career_Path='Data Analytics' THEN Salary_LPA END),2) AS DA_Avg_Salary,
    ROUND(AVG(CASE WHEN Career_Path='UI/UX Design' THEN Salary_LPA END),2) AS UX_Avg_Salary,
    CASE
        WHEN AVG(CASE WHEN Career_Path='UI/UX Design' THEN Salary_LPA END)
           > AVG(CASE WHEN Career_Path='Data Analytics' THEN Salary_LPA END)
        THEN 'UI/UX Design pays more'
        ELSE 'Data Analytics pays more'
    END AS Higher_Paying_Path
FROM jobs
GROUP BY Experience
ORDER BY Experience;

-- Result:
-- UI/UX Design offers a higher average salary
-- than Data Analytics across all experience levels.

-- ============================================================
-- SECTION 3 — JOB ROLE ANALYSIS
-- ============================================================

-- Query 8: Most popular job roles by number of openings
SELECT
    Job_Title,
    Career_Path,
    COUNT(*) AS Total_Openings,
    ROUND(AVG(Salary_LPA),2) AS Avg_Salary_LPA
FROM jobs
GROUP BY Job_Title,Career_Path
ORDER BY Total_Openings DESC;

-- Result:
-- Reporting Analyst = 129 openings
-- Data Analyst = 125 openings
-- Business Analyst = 123 openings

-- Query 9: Top 5 highest paying job roles
SELECT
    Job_Title,
    Career_Path,
    COUNT(*) AS Openings,
    ROUND(AVG(Salary_LPA),2) AS Avg_Salary_LPA
FROM jobs
GROUP BY Job_Title,Career_Path
ORDER BY Avg_Salary_LPA DESC
LIMIT 5;

-- Result:
-- Product Designer = 11.02 LPA
-- UX Designer = 10.96 LPA
-- UX Researcher = 10.80 LPA
-- (Top 5 highest-paying roles displayed)

-- Query 10: Rank all job roles by average salary
SELECT
    Job_Title,
    Career_Path,
    ROUND(AVG(Salary_LPA),2) AS Avg_Salary,
    RANK() OVER(ORDER BY AVG(Salary_LPA) DESC) AS Overall_Rank,
    RANK() OVER(
        PARTITION BY Career_Path
        ORDER BY AVG(Salary_LPA) DESC
    ) AS Rank_Within_Path
FROM jobs
GROUP BY Job_Title,Career_Path
ORDER BY Overall_Rank;

-- Result:
-- Displays overall salary ranking
-- and ranking within each career path.

-- ============================================================
-- SECTION 4 — LOCATION ANALYSIS
-- ============================================================

-- Query 11: Job count and average salary by city
SELECT
    Location,
    COUNT(*) AS Total_Jobs,
    ROUND(AVG(Salary_LPA),2) AS Avg_Salary_LPA,
    ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM jobs),1) AS Job_Share_Pct
FROM jobs
GROUP BY Location
ORDER BY Total_Jobs DESC;

-- Result:
-- Bengaluru = 259 jobs (25.9%)
-- Hyderabad = 185 jobs
-- Pune = 147 jobs

-- Query 12: Top salary cities
SELECT
    Location,
    COUNT(*) AS Total_Jobs,
    ROUND(AVG(Salary_LPA),2) AS Avg_Salary_LPA
FROM jobs
GROUP BY Location
ORDER BY Avg_Salary_LPA DESC;

-- Result:
-- Pune = 10.83 LPA
-- Gurugram = 10.46 LPA
-- Bengaluru = 10.33 LPA

-- Query 13: Best cities for Data Analytics vs UI/UX by job count
SELECT
    Location,
    SUM(CASE WHEN Career_Path='Data Analytics' THEN 1 ELSE 0 END) AS DA_Jobs,
    SUM(CASE WHEN Career_Path='UI/UX Design' THEN 1 ELSE 0 END) AS UX_Jobs,
    COUNT(*) AS Total_Jobs
FROM jobs
GROUP BY Location
ORDER BY Total_Jobs DESC;

-- Result:
-- Displays Data Analytics jobs,
-- UI/UX Design jobs,
-- and total jobs available in each city.

-- ============================================================
-- SECTION 5 — COMPANY ANALYSIS
-- ============================================================

-- Query 14: Top companies by total job count
SELECT
    Company,
    COUNT(*) AS Total_Jobs,
    ROUND(AVG(Salary_LPA),2) AS Avg_Salary_LPA,
    SUM(CASE WHEN Career_Path='Data Analytics' THEN 1 ELSE 0 END) AS DA_Jobs,
    SUM(CASE WHEN Career_Path='UI/UX Design' THEN 1 ELSE 0 END) AS UX_Jobs
FROM jobs
GROUP BY Company
ORDER BY Total_Jobs DESC
LIMIT 10;

-- Result:
-- Accenture = 74 jobs
-- Infosys = 70 jobs
-- EY = 68 jobs
-- KPMG = 62 jobs

-- Query 15: Companies with highest average salary
SELECT
    Company,
    COUNT(*) AS Total_Jobs,
    ROUND(AVG(Salary_LPA),2) AS Avg_Salary_LPA
FROM jobs
GROUP BY Company
HAVING COUNT(*) >= 20
ORDER BY Avg_Salary_LPA DESC
LIMIT 5;

-- Result:
-- Displays the Top 5 companies
-- with the highest average salary
-- among companies having at least 20 job postings.

-- Query 16: Rank companies by job count using WINDOW FUNCTION

SELECT
    Company,
    COUNT(*) AS Total_Jobs,
    ROUND(AVG(Salary_LPA), 2) AS Avg_Salary,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS Company_Rank
FROM jobs
GROUP BY Company
ORDER BY Company_Rank;

-- Result: Companies ranked by total job openings.
-- Accenture = Rank 1, Infosys = Rank 2, followed by EY and KPMG.

-- ============================================================
-- SECTION 6 — SKILLS ANALYSIS
-- ============================================================
 
-- Query 17: Demand for each skill across all 1000 jobs

SELECT 'Excel' AS Skill,
       SUM(Excel) AS Jobs_Requiring,
       ROUND(SUM(Excel) * 100.0 / COUNT(*), 1) AS Demand_Pct
FROM jobs
UNION ALL
SELECT 'SQL',
       SUM(`SQL`),
       ROUND(SUM(`SQL`) * 100.0 / COUNT(*), 1)
FROM jobs
UNION ALL
SELECT 'Power BI',
       SUM(PowerBI),
       ROUND(SUM(PowerBI) * 100.0 / COUNT(*), 1)
FROM jobs
UNION ALL
SELECT 'Python',
       SUM(Python),
       ROUND(SUM(Python) * 100.0 / COUNT(*), 1)
FROM jobs
UNION ALL
SELECT 'Tableau',
       SUM(Tableau),
       ROUND(SUM(Tableau) * 100.0 / COUNT(*), 1)
FROM jobs
UNION ALL
SELECT 'Statistics',
       SUM(Statistics),
       ROUND(SUM(Statistics) * 100.0 / COUNT(*), 1)
FROM jobs
UNION ALL
SELECT 'Dashboarding',
       SUM(Dashboarding),
       ROUND(SUM(Dashboarding) * 100.0 / COUNT(*), 1)
FROM jobs
UNION ALL
SELECT 'Figma',
       SUM(Figma),
       ROUND(SUM(Figma) * 100.0 / COUNT(*), 1)
FROM jobs
UNION ALL
SELECT 'Wireframing',
       SUM(Wireframing),
       ROUND(SUM(Wireframing) * 100.0 / COUNT(*), 1)
FROM jobs
UNION ALL
SELECT 'User Research',
       SUM(User_Research),
       ROUND(SUM(User_Research) * 100.0 / COUNT(*), 1)
FROM jobs

ORDER BY Jobs_Requiring DESC;

-- Result: Excel = 672 (67.2%), SQL = 547 (54.7%), Power BI = 472 (47.2%) were the most demanded skills.

-- Query 18: Skill demand split by career path (DA vs UI/UX)

SELECT
    Career_Path,
    ROUND(AVG(Excel) * 100, 1) AS Excel_Pct,
    ROUND(AVG(`SQL`) * 100, 1) AS SQL_Pct,
    ROUND(AVG(PowerBI) * 100, 1) AS PowerBI_Pct,
    ROUND(AVG(Python) * 100, 1) AS Python_Pct,
    ROUND(AVG(Tableau) * 100, 1) AS Tableau_Pct,
    ROUND(AVG(Figma) * 100, 1) AS Figma_Pct,
    ROUND(AVG(Wireframing) * 100, 1) AS Wireframing_Pct,
    ROUND(AVG(User_Research) * 100, 1) AS UserResearch_Pct
FROM jobs
GROUP BY Career_Path;

-- Result: Data Analytics highly demands Excel (91%) and SQL (85%), while UI/UX Design highly demands Figma (97%) and Wireframing (89%).

-- Query 19: Top skill combinations

SELECT
    SUM(CASE WHEN `SQL`=1 AND Excel=1 THEN 1 ELSE 0 END) AS SQL_AND_Excel,
    SUM(CASE WHEN `SQL`=1 AND PowerBI=1 THEN 1 ELSE 0 END) AS SQL_AND_PowerBI,
    SUM(CASE WHEN Excel=1 AND Dashboarding=1 THEN 1 ELSE 0 END) AS Excel_AND_Dashboarding,
    SUM(CASE WHEN Figma=1 AND Wireframing=1 THEN 1 ELSE 0 END) AS Figma_AND_Wireframing,
    SUM(CASE WHEN Figma=1 AND User_Research=1 THEN 1 ELSE 0 END) AS Figma_AND_UserResearch
FROM jobs;

-- Result: SQL + Excel = 475, SQL + Power BI = 377, Excel + Dashboarding = 439, Figma + Wireframing = 343.

-- Query 20: Average salary for jobs WITH vs WITHOUT each skill

SELECT
    'Figma' AS Skill,
    ROUND(AVG(CASE WHEN Figma=1 THEN Salary_LPA END),2) AS Avg_With_Skill,
    ROUND(AVG(CASE WHEN Figma=0 THEN Salary_LPA END),2) AS Avg_Without_Skill
FROM jobs
UNION ALL
SELECT
    'SQL',
    ROUND(AVG(CASE WHEN `SQL`=1 THEN Salary_LPA END),2),
    ROUND(AVG(CASE WHEN `SQL`=0 THEN Salary_LPA END),2)
FROM jobs
UNION ALL
SELECT
    'Python',
    ROUND(AVG(CASE WHEN Python=1 THEN Salary_LPA END),2),
    ROUND(AVG(CASE WHEN Python=0 THEN Salary_LPA END),2)
FROM jobs;

-- Result: Figma jobs average 10.44 LPA, SQL jobs 10.12 LPA and Python jobs 10.02 LPA.

-- ============================================================
-- SECTION 7 — SALARY PERCENTILES (ADVANCED)
-- ============================================================
 
-- Query 21: Salary percentiles across all jobs using SUBQUERY

SELECT
    'P25 (Bottom 25%)' AS Percentile,
    MIN(Salary_LPA) AS Salary_Threshold
FROM (
    SELECT
        Salary_LPA,
        ROW_NUMBER() OVER (ORDER BY Salary_LPA) AS rn,
        COUNT(*) OVER () AS total
    FROM jobs
) ranked
WHERE rn <= total * 0.25
UNION ALL
SELECT
    'P50 (Median)',
    MIN(Salary_LPA)
FROM (
    SELECT
        Salary_LPA,
        ROW_NUMBER() OVER (ORDER BY Salary_LPA) AS rn,
        COUNT(*) OVER () AS total
    FROM jobs
) ranked
WHERE rn <= total * 0.50
UNION ALL
SELECT
    'P75 (Top 25%)',
    MIN(Salary_LPA)
FROM (
    SELECT
        Salary_LPA,
        ROW_NUMBER() OVER (ORDER BY Salary_LPA) AS rn,
        COUNT(*) OVER () AS total
    FROM jobs
) ranked
WHERE rn <= total * 0.75
UNION ALL
SELECT
    'P90 (Top 10%)',
    MIN(Salary_LPA)
FROM (
    SELECT
        Salary_LPA,
        ROW_NUMBER() OVER (ORDER BY Salary_LPA) AS rn,
        COUNT(*) OVER () AS total
    FROM jobs
) ranked
WHERE rn <= total * 0.90;

-- Result: P25 = 6.50 LPA, P50 = 8.60 LPA, P75 = 13.00 LPA, P90 = 18.52 LPA.

-- ============================================================
-- SECTION 8 — CTE (COMMON TABLE EXPRESSION) QUERIES
-- ============================================================
 
-- Query 22: Find above-average salary jobs using CTE

WITH avg_salary AS (
    SELECT AVG(Salary_LPA) AS overall_avg
    FROM jobs
)
SELECT
    j.Job_Title,
    j.Career_Path,
    j.Company,
    j.Location,
    j.Salary_LPA,
    ROUND(a.overall_avg,2) AS Overall_Average,
    ROUND(j.Salary_LPA-a.overall_avg,2) AS Above_Avg_By
FROM jobs j
CROSS JOIN avg_salary a
WHERE j.Salary_LPA>a.overall_avg
ORDER BY j.Salary_LPA DESC
LIMIT 20;

-- Result: Displays the Top 20 jobs with salaries higher than the overall average salary.

-- Query 23: Salary growth between experience levels using CTE

WITH salary_by_exp AS (
SELECT
    Career_Path,
    Experience,
    ROUND(AVG(Salary_LPA),2) AS Avg_Salary,
    COUNT(*) AS Job_Count
FROM jobs
GROUP BY Career_Path,Experience
)
SELECT
Career_Path,
Experience,
Avg_Salary,
Job_Count,
LAG(Avg_Salary)
OVER(
PARTITION BY Career_Path
ORDER BY Experience
) AS Previous_Salary,
ROUND(
(Avg_Salary-
LAG(Avg_Salary)
OVER(
PARTITION BY Career_Path
ORDER BY Experience
))
*100/
NULLIF(
LAG(Avg_Salary)
OVER(
PARTITION BY Career_Path
ORDER BY Experience
),0)
,1) AS Growth_Percentage
FROM salary_by_exp
ORDER BY Career_Path,Experience;

-- Result: Shows salary growth percentage between experience levels for each career path.

-- Query 24: Identify the top hiring company in each city using CTE

WITH company_city_rank AS (
SELECT
Company,
Location,
COUNT(*) AS Job_Count,
RANK() OVER(
PARTITION BY Location
ORDER BY COUNT(*) DESC
) AS City_Rank
FROM jobs
GROUP BY Company,Location
)
SELECT
Location,
Company AS Top_Hiring_Company,
Job_Count
FROM company_city_rank
WHERE City_Rank=1
ORDER BY Job_Count DESC;

-- Result: Displays the top hiring company for each city based on total job openings.

-- Query 25: Career fit score for a user with SQL, Excel and Power BI skills

WITH user_skills AS (
SELECT
1 AS `SQL`,
1 AS Excel,
1 AS PowerBI,
0 AS Python,
0 AS Figma
),
matching_jobs AS (
SELECT
j.Job_ID,
j.Job_Title,
j.Career_Path,
j.Salary_LPA,
(j.`SQL`*u.`SQL`+
j.Excel*u.Excel+
j.PowerBI*u.PowerBI) AS Skills_Matched,
(j.`SQL`+
j.Excel+
j.PowerBI+
j.Python+
j.Figma) AS Total_Skills
FROM jobs j
CROSS JOIN user_skills u
WHERE Career_Path='Data Analytics'
)
SELECT
Job_Title,
Career_Path,
COUNT(*) AS Matching_Jobs,
ROUND(AVG(Salary_LPA),2) AS Avg_Salary,
ROUND(
COUNT(*)*100/
(
SELECT COUNT(*)
FROM jobs
WHERE Career_Path='Data Analytics'
)
,1) AS Match_Percentage
FROM matching_jobs
WHERE Skills_Matched>=2
GROUP BY Job_Title,Career_Path
ORDER BY Matching_Jobs DESC;

-- Result: Shows matching Data Analytics jobs for users with SQL, Excel and Power BI skills.

-- ============================================================
-- SECTION 9 — WINDOW FUNCTION QUERIES
-- ============================================================
 
-- Query 26: Rank all jobs by salary using Window Functions

SELECT
Job_ID,
Job_Title,
Career_Path,
Company,
Salary_LPA,

RANK() OVER(
PARTITION BY Career_Path
ORDER BY Salary_LPA DESC
) AS Rank_In_Career,

DENSE_RANK() OVER(
ORDER BY Salary_LPA DESC
) AS Overall_Rank,

NTILE(4) OVER(
ORDER BY Salary_LPA
) AS Salary_Quartile
FROM jobs
ORDER BY Career_Path,Rank_In_Career
LIMIT 30;

-- Result: Displays salary ranking and quartile for the top 30 jobs.

-- Query 28: Salary percentile ranking using Window Function

SELECT
Job_ID,
Job_Title,
Career_Path,
Salary_LPA,
ROUND(
PERCENT_RANK()
OVER(
ORDER BY Salary_LPA
)*100
,1) AS Salary_Percentile
FROM jobs
ORDER BY Salary_Percentile DESC
LIMIT 20;

-- Result: Displays salary percentile rankings for the highest-paying jobs.

-- ============================================================
-- SECTION 10 — KEY INSIGHT QUERIES (PORTFOLIO HIGHLIGHTS)
-- ============================================================
 
-- Query 29: Full career intelligence summary

SELECT
Career_Path,
COUNT(*) AS Total_Jobs,
ROUND(AVG(Salary_LPA),2) AS Avg_Salary,
MIN(Salary_LPA) AS Entry_Level_Salary,
MAX(Salary_LPA) AS Highest_Salary,
ROUND(AVG(Excel)*100,1) AS Excel_Demand,
ROUND(AVG(`SQL`)*100,1) AS SQL_Demand,
ROUND(AVG(Figma)*100,1) AS Figma_Demand,
ROUND(AVG(Python)*100,1) AS Python_Demand
FROM jobs
GROUP BY Career_Path
ORDER BY Avg_Salary DESC;

-- Result: Compares Data Analytics and UI/UX Design based on jobs, salary and skill demand.

-- Query 30: Jobs requiring the highest number of skills

SELECT
Job_Title,
Career_Path,
Company,
Location,
Salary_LPA,
(
`SQL`+
Excel+
PowerBI+
Python+
Tableau+
Statistics+
Dashboarding+
Figma+
Wireframing+
User_Research
) AS Total_Skills_Required
FROM jobs
ORDER BY Total_Skills_Required DESC,
Salary_LPA DESC
LIMIT 10;

-- Result: Displays the Top 10 jobs requiring the highest number of technical and professional skills.