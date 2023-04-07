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

with cte_a as 
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

--compare a to b; compare a specific a subtype to rest of subtypes compare ten weeks (are there two peaks per year?); connect with Tableau to visualize; get wider data range

--Self-Joins
--Correlated Subqueries
--Recursive CTEs
--https://www.sqlservertutorial.net/sql-server-basics/sql-server-recursive-cte/
