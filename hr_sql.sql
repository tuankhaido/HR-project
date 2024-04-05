Create database hr;
use hr;
SELECT * FROM hr_data;

-- Create new column Age
ALTER TABLE hr_data
ADD age int

UPDATE hr_data
SET age = DATEDIFF(YEAR,birthdate,GETDATE());

-- 1.	What's the age distribution in the company?
-- age distribution
SELECT MIN(age) as Youngest, MAX(age) as Oldest FROM hr_data;
-- age group distribution by gender 
WITH AgeGroups AS (
  SELECT 
    CASE
      WHEN age >= 21 AND age <= 30 THEN '21-30'
      WHEN age >= 31 AND age <= 40 THEN '31-40'
      WHEN age >= 41 AND age <= 50 THEN '41-50'
      WHEN age > 50 THEN '50+'
    END AS AgeGroup, 
	gender,
	termdate
  FROM hr_data
)
SELECT 
  AgeGroup, gender,
  COUNT(AgeGroup) AS Count
FROM AgeGroups
WHERE termdate is null
GROUP BY AgeGroup, gender ORDER BY AgeGroup ASC;

--2.What's the gender breakdown in the company?
SELECT
gender, COUNT(gender) as Count
FROM hr_data WHERE termdate is null
GROUP BY gender order by gender;

--3.How does gender vary across departments and job titles?
--department
SELECT
department, gender, COUNT(gender) as Count
FROM hr_data WHERE termdate is null
GROUP BY department, gender order by department, gender ASC;
--jobtiltle
SELECT
department, jobtitle, gender, COUNT(gender) as Count
FROM hr_data WHERE termdate is null
GROUP BY department, jobtitle, gender order by  department, jobtitle, gender ASC;

--4.What's the race distribution in the company?

SELECT
race, COUNT(race) as Count
FROM hr_data WHERE termdate is null
GROUP BY race order by Count DESC;

-- 5.How many employees work at HQ vs remote
SELECT
location,  count(*) as count
FROM hr_data 
WHERE termdate is null 
GROUP BY location
order by count;

-- 6.Whats the distribution of employees across different states?
SELECT
location_state, COUNT(location_state) as Count
FROM hr_data WHERE termdate is null
GROUP BY location_state order by Count DESC;

--7.Which department has the highest turnover rate?
-- rời/ tổng số
WITH Terminates AS (
SELECT department, count(*) as Terminate
FROM hr_data
WHERE termdate is not null 
GROUP BY department
),
Totals AS (
SELECT department, count(*) as Total
FROM hr_data
GROUP BY department
)
SELECT t.department, Total, Terminate, Round((Cast(Terminate as float)/Total), 4)*100 as Turnover_rate  
FROM Terminates t join Totals tt on t.department = tt.department
ORDER BY turnover_rate DESC;

--8.Which age has the highest turnover rate?
WITH Terminates AS (
SELECT age, count(*) as Terminate
FROM hr_data
WHERE termdate is not null 
GROUP BY age
),
Totals AS (
SELECT age, count(*) as Total
FROM hr_data
GROUP BY age
)
SELECT t.age, Total, Terminate, Round((Cast(Terminate as float)/Total), 4)*100 as Turnover_rate  
FROM Terminates t join Totals tt on t.age = tt.age
ORDER BY age ASC;
--9.Which race has the highest turnover rate?
WITH Terminates AS (
SELECT race, count(*) as Terminate
FROM hr_data
WHERE termdate is not null 
GROUP BY race
),
Totals AS (
SELECT race, count(*) as Total
FROM hr_data
GROUP BY race
)
SELECT t.race, Total, Terminate, Round((Cast(Terminate as float)/Total), 4)*100 as Turnover_rate  
FROM Terminates t join Totals tt on t.race = tt.race
ORDER BY turnover_rate DESC;

--10.Which gender has the highest turnover rate?
WITH Terminates AS (
SELECT gender, count(*) as Terminate
FROM hr_data
WHERE termdate is not null 
GROUP BY gender
),
Totals AS (
SELECT gender, count(*) as Total
FROM hr_data
GROUP BY gender
)
SELECT t.gender, Total, Terminate, Round((Cast(Terminate as float)/Total), 4)*100 as Turnover_rate  
FROM Terminates t join Totals tt on t.gender = tt.gender
ORDER BY turnover_rate DESC;

--11.What's the average length of employment in the company?
SELECT
 AVG(DATEDIFF(YEAR, hire_date,termdate)) as Average_tenure
FROM hr_data 
WHERE termdate is not null;
--12.How have employee hire counts varied over time?
WITH Terminates AS (
SELECT YEAR(hire_date) AS Hire_year, count(*) as Terminate
FROM hr_data
WHERE termdate is not null 
GROUP BY YEAR(hire_date) 
),
Hires AS (
SELECT YEAR(hire_date) AS Hire_year, count(*) as Hire
FROM hr_data
GROUP BY YEAR(hire_date) 
)
SELECT
 t.Hire_year,
 Hire,
 Terminate,
 Hire - terminate AS Net_change,
 (Round(CAST(Hire-Terminate AS FLOAT)/Hire, 2)) * 100 AS Percent_hire_change
 FROM Terminates t join Hires h on t.Hire_year = h.Hire_year
 ORDER BY Percent_hire_change ASC;

