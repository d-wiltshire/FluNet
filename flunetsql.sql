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
WITH cte_a AS (SELECT whoregion, iso_week,
    SUM(inf_a) AS sum_all_a_subtypes
FROM flunet_table
GROUP BY whoregion, iso_week
HAVING SUM(inf_a) > 0
ORDER BY sum_all_a_subtypes DESC)

, cte_b AS (SELECT whoregion, MAX(sum_all_a_subtypes) as highest_weekly_total
FROM cte_a 
GROUP BY whoregion)

SELECT cte_b.*, cte_a.iso_week
from cte_b
left join cte_a
on cte_a.sum_all_a_subtypes = cte_b.highest_weekly_total
ORDER BY cte_b.whoregion ASC;


--Compare top 5 weeks relative to region 



