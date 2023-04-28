SELECT * FROM flunet_table;

--Comparing totals of "a" subtypes by year 
SELECT iso_year,
    SUM(ah1) AS ah1_sum,
	SUM(ah1n12009) AS ah1n12009_sum,
	SUM(ah3) AS ah3_sum,
	SUM(ah5) AS ah5_sum,
	SUM(anotsubtyped) AS anotsubtyped_sum
FROM flunet_table
GROUP BY iso_year
ORDER BY iso_year;


--Comparing totals of a and b subtypes by country/area/territory
SELECT countryareaterritory,
    SUM(inf_a) AS sum_all_a_subtypes,
	SUM(inf_b) AS sum_all_b_subtypes
FROM flunet_table
GROUP BY countryareaterritory
HAVING SUM(inf_a) > 0
ORDER BY sum_all_a_subtypes DESC
LIMIT 20;
	

--Finding the weeks of the year where infections are most prevalent
SELECT iso_week,
    SUM(inf_a) AS sum_all_a_subtypes,
	SUM(inf_b) AS sum_all_b_subtypes
FROM flunet_table
GROUP BY iso_week
HAVING SUM(inf_a) > 0
ORDER BY sum_all_a_subtypes DESC
LIMIT 10;


--Comparing the week with highest prevalence across the WHO regions for subtype_a
WITH cte_a AS 
(SELECT 
    whoregion, 
    iso_week,
    SUM(inf_a) AS sum_all_a_subtypes
FROM flunet_table
GROUP BY whoregion, iso_week
HAVING SUM(inf_a) > 0
ORDER BY sum_all_a_subtypes DESC)

, cte_b AS 
(SELECT 
     whoregion, 
 	 MAX(sum_all_a_subtypes) as highest_weekly_total
FROM cte_a 
GROUP BY whoregion)

SELECT cte_b.*, cte_a.iso_week
FROM cte_b
LEFT JOIN cte_a
ON cte_a.sum_all_a_subtypes = cte_b.highest_weekly_total
ORDER BY cte_b.whoregion ASC;


--Compare top 5 weeks relative to region for subtype_a
/** 
Least efficient solution: UNION, typing out each whoregion, e.g.:

SELECT 
    whoregion, 
    iso_week,
    SUM(inf_a) AS sum_all_a_subtypes
FROM flunet_table
WHERE whoregion = 'AMR'
GROUP BY whoregion, iso_week
HAVING SUM(inf_a) > 0
ORDER BY sum_all_a_subtypes DESC
LIMIT 10

UNION

SELECT 
    whoregion, 
    iso_week,
    SUM(inf_a) AS sum_all_a_subtypes
FROM flunet_table
WHERE whoregion = 'EUR'
GROUP BY whoregion, iso_week
HAVING SUM(inf_a) > 0
ORDER BY sum_all_a_subtypes DESC
LIMIT 10

etc.;  **/


--Refactored: Using window functions to perform calculations across sets of rows

WITH cte_a AS 
(SELECT 
    whoregion, 
    iso_week,
    SUM(inf_a) AS sum_all_a_subtypes
FROM flunet_table
GROUP BY whoregion, iso_week
HAVING SUM(inf_a) > 0
ORDER BY sum_all_a_subtypes DESC)

SELECT ranked_weeks.* FROM
(SELECT cte_a.*,
  RANK() OVER (PARTITION BY whoregion ORDER BY sum_all_a_subtypes DESC)
  FROM cte_a) ranked_weeks 
WHERE RANK <=5;


-- Same for subtype b 

WITH cte_b AS 
(SELECT 
    whoregion, 
    iso_week,
    SUM(inf_b) AS sum_all_b_subtypes
FROM flunet_table
GROUP BY whoregion, iso_week
HAVING SUM(inf_b) > 0
ORDER BY sum_all_b_subtypes DESC)

SELECT ranked_weeks.* 
FROM
(SELECT cte_b.*,
  RANK() OVER (PARTITION BY whoregion ORDER BY sum_all_b_subtypes DESC)
  FROM cte_b) ranked_weeks 
WHERE RANK <=5;


--Find top 5 countryareaterritory where ah3 subtype is most frequently the only A subtype found (i.e., where ah3 = inf_a) and where a positive number of cases was found (i.e., not zero)

WITH cte_a as 
(SELECT countryareaterritory,
	CONCAT(iso_year, iso_week) AS year_week,
	ah3, 
	inf_a
FROM flunet_table
WHERE ah3 = inf_a
AND ah3 > 0)

SELECT countryareaterritory, COUNT(year_week)
FROM cte_a
GROUP BY countryareaterritory
ORDER BY COUNT(year_week) DESC
LIMIT 5;


--Window functions: calculating running total
--https://learnsql.com/blog/what-is-a-running-total-and-how-to-compute-it-in-sql/
SELECT iso_sdate,
  inf_a,
  SUM(inf_a) OVER (ORDER BY iso_sdate) AS running_total
FROM flunet_table
WHERE countryareaterritory = 'Algeria';

--Also using PARTITION BY to view all countries
SELECT countryareaterritory,
  iso_sdate,
  inf_a,
  SUM(inf_a) 
  OVER (PARTITION BY countryareaterritory ORDER BY iso_sdate) AS running_total
FROM flunet_table
ORDER BY countryareaterritory, iso_sdate;



--compare a to b; compare number of positive cases to total number tested; compare a specific a subtype to rest of subtypes compare ten weeks (are there two peaks per year?); connect with Tableau to visualize; get wider data range

--Self-Joins

--Correlated Subqueries
--For correlated subqueries, the query must be re-executed for every row, which increases query runtime.

--Using a correlated subquery weeks for each country where the inf_a levels are higher than average 
SELECT countryareaterritory, iso_sdate, iso_week, inf_a
FROM flunet_table main
WHERE inf_a >
                (SELECT AVG(inf_a)
                 FROM flunet_table sub
                 WHERE sub.countryareaterritory = main.countryareaterritory
                 GROUP BY countryareaterritory)
ORDER BY countryareaterritory;

--Recursive CTEs
--https://www.sqlservertutorial.net/sql-server-basics/sql-server-recursive-cte/


--CASE WHEN
--Identifying which countries/quarters of the year have high incidences of inf_a
WITH cte_a AS(
SELECT countryareaterritory country,
		CASE 
			WHEN iso_week BETWEEN 1 AND 13 THEN 'Q1'
   			WHEN iso_week BETWEEN 14 AND 26 THEN 'Q2'
   			WHEN iso_week BETWEEN 27 AND 39 THEN 'Q3'
   			ELSE 'Q4'
	    END AS quarter
	FROM flunet_table
	WHERE inf_a > 100
)

SELECT country, quarter, COUNT(quarter)
FROM cte_a 
GROUP BY country, quarter
HAVING COUNT(quarter) > 10
ORDER BY COUNT(quarter) DESC, country;

--Date-time functions:
--Refactoring the previous code with QUARTER() date-time function:
WITH cte_a AS(
SELECT countryareaterritory country,
	EXTRACT(quarter FROM iso_sdate) as quarter
FROM flunet_table
WHERE inf_a > 100
)

SELECT country, quarter, COUNT(quarter)
FROM cte_a 
GROUP BY country, quarter
HAVING COUNT(quarter) > 10
ORDER BY COUNT(quarter) DESC, country;

--Date-time functions are specific to the SQL you are using; PostgreSQL differs from MySQL, SQL Server, etc. 
--More on PostgreSQL date-time functions here: https://www.sqlshack.com/working-with-date-and-time-functions-in-postgresql/

--Additional examples of PostgreSQL date-time functions



--User-defined functions (scalar functions)


--Join to unrelated table? Other tables from this org?


--Calculating running totals with CUBE and ROLLUP:
--CUBE
--Similar to ROLLUP

SELECT
   COALESCE(whoregion, '-') region,
   COALESCE(countryareaterritory, 'TOTAL') country,
   SUM(inf_b) inf_b
FROM flunet_table
GROUP BY CUBE(whoregion, countryareaterritory)
ORDER BY whoregion, countryareaterritory;


--ROLLUP
--https://www.sqltutorial.org/sql-rollup/ ; ROLLUP is combined with GROUP BY to create a new line showing totals/subtotals

SELECT 
    COALESCE(whoregion, 'All WHO Regions') as whoregion,
	countryareaterritory, 
	SUM(inf_a)
FROM flunet_table
GROUP BY ROLLUP (whoregion, countryareaterritory)
ORDER BY whoregion, countryareaterritory;

--Indexes, clustered and non-clustered

--Pivots

--Triggers

--Calculating delta values with LEAD, LAG (window function?)
--https://www.postgresqltutorial.com/postgresql-window-function/postgresql-lag-function/
--https://www.postgresqltutorial.com/postgresql-window-function/postgresql-lead-function/
/**
THIS DOES NOT WORK
SELECT iso_sdate, 
	inf_a, 
	CASE WHEN LEAD(inf_a) OVER (ORDER BY iso_sdate DESC) = 0 
	   THEN 1
	   ELSE LEAD(inf_a) OVER (ORDER BY iso_sdate DESC)
	END AS previous_day_amount,
	((( inf_a - LEAD(inf_a) OVER (ORDER BY iso_sdate DESC)) / (LEAD(inf_a) OVER (ORDER BY iso_sdate DESC)) * 100)
	
FROM flunet_table
WHERE countryareaterritory = 'Algeria'
ORDER BY iso_sdate ASC;
**/
	 
SELECT iso_sdate, 
	inf_a, 
	LAG(inf_a) OVER (ORDER BY iso_sdate) AS previous_day_amount
FROM flunet_table
WHERE countryareaterritory = 'Algeria'
ORDER BY iso_sdate;
--is this identical to LEAD desc(above?)
	 
	 
--Using a CTE for variance
--Note: CAST is needed here in the CTE because when Postgres divides two integers, the result will also be an integer with remainder discarded. Therefore we need to cast one as a non-integer. https://datacomy.com/sql/postgresql/division/
--In addition, Postgres does not support the use of ROUND with a double precision type, so we must cast as NUMERIC to use ROUND. https://pgsql-sql.postgresql.narkive.com/835yQ640/sql-error-function-round-double-precision-integer-does-not-exist
--The double colon :: is a Postgres-specific alternative to CAST as type https://stackoverflow.com/questions/15537709/what-does-do-in-postgresql
WITH cte_a AS (
SELECT iso_sdate, 
	inf_a, 
	CAST((LAG(inf_a) OVER (ORDER BY iso_sdate)) AS FLOAT) AS previous_day_amount

FROM flunet_table
WHERE countryareaterritory = 'Algeria'
ORDER BY iso_sdate)

SELECT iso_sdate,
inf_a,
previous_day_amount,
(inf_a - previous_day_amount) AS variance,
ROUND((CASE WHEN previous_day_amount = 0 
	   THEN (inf_a - previous_day_amount)
	   ELSE ((inf_a - previous_day_amount)/previous_day_amount)
	END)::NUMERIC, 2) AS change

FROM cte_a;
--incorporate CASE WHEN from above for percentage change?
	   CAST(
            (CASE WHEN P.IsGun = 1 THEN CEILING(PQ.Price1Avg) ELSE PQ.Price1 END)
             AS NUMERIC(8,2))
	 
	 
/**
Except versus Not In.
Rank versus dense rank versus row number.
**/

--additional lists: https://softwareengineering.stackexchange.com/questions/181651/are-these-sql-concepts-for-beginners-intermediate-or-advanced-developers
--https://medium.com/dp6-us-blog/7-advanced-sql-concepts-you-need-to-know-45fa149ba0b0