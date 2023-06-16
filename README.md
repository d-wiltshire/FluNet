# FluNet

## Goal 

The goal of this project is to serve as a teaching tool for SQL students by demonstrating intermediate-level SQL concepts (using PostgreSQL).

## Table of contents
- [CTEs](#ctes)
- [Window Functions](#window-functions)
- [Correlated Subqueries](#correlated-subqueries)
- [CASE WHEN](#case-when)
- [Date-Time Functions](#date-time-functions)
- [User-defined Scalar Functions](#user-defined-scalar-functions)
- [Using ROLLUP and CUBE for subtotals and totals](#Using-ROLLUP-and-CUBE-for-subtotals-and-totals)
- [Calculating Delta Values with LEAD and LAG](#calculating-delta-values-with-lead-and-lag)
- [RANK](#rank)
- [EXCEPT versus NOT IN](#except-versus-not-in)


## About the data

The dataset consists of World Health Organization FluNet data through 3/13/23. The dataset is <a href="https://www.who.int/tools/flunet">available here.</a>

The data dictionary is also <a href="https://app.powerbi.com/view?r=eyJrIjoiNjViM2Y4NjktMjJmMC00Y2NjLWFmOWQtODQ0NjZkNWM1YzNmIiwidCI6ImY2MTBjMGI3LWJkMjQtNGIzOS04MTBiLTNkYzI4MGFmYjU5MCIsImMiOjh9">available here,</a> and it can be found as an image file stored in this repository.

### A quick look

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/1089a5ee-cf41-4b32-9309-ec15a6c82f33)

In general, the data provides information about the number of confirmed cases of two flu strains (A and B) and the subtypes of the confirmed cases relative to country and date (by week). We are able to filter to find the number of the total cases of the A strain (inf_a) for Algeria in the first week of 2022, for example, and compare that to relative frequencies of other countries and in other weeks. We are also able to compare the relative prevalence of strain subtypes.

### Sample query

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/7be3ee72-53aa-4812-a5ab-bd22292861a1" height="200">

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/05a51ca6-5d2e-4ea7-8ebb-2b98dd2b943e)

For example, we can group by the week of the year (i.e., 1-52) to determine which weeks of the year have the highest prevalence of subtype A (and check out the relative frequencies of subtype B at the same time).  

[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/5afb9ada-d07c-4d27-8785-221bbec2544b)


## Demonstrating Concepts

### CTEs

CTEs, or Common Table Expressions, allow you to use a result set in another query. They have similar use cases to views, temp tables, and subqueries. CTEs improve the readability of code over subqueries, they're beneficial in cases where you may not have permissions to create views or other objects, and they allow you to perform multi-level aggregations (like taking the lowest out of a set of average scores).

In the query below, the first CTE creates a result set with the region, week of the year, and the sum of all the "Type A" totals from that week and region. (This dataset contains multiple years' worth of data, so the inf_a figure is summed over multiple years.) The second CTE takes the region and the sum total from the highest week per region from the first CTE. Then, the two CTEs are merged to identify the week of the year for each region with the highest total of inf_a cases.

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/d9ca1808-c224-4a56-a452-9efbe10b7067" height="500">

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/6f765b57-a722-4555-b9f9-ff6495272708)


Learn about recursive CTEs here:
* https://www.sqlservertutorial.net/sql-server-basics/sql-server-recursive-cte/
* https://builtin.com/data-science/recursive-sql

[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/71eb1327-5c74-4128-9d4f-38fafc9fce6b)


### Window Functions
Window functions are a preferred way to perform calculations across sets of rows. For example, if you wanted to find the top N weeks of the year for subtype A prevalence for each WHO Region, you could use a series of UNION statements, e.g.

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/c25b7e93-c4ab-4cec-abab-f8302e5872c0" height="250">
 
This would require you to repeat this code for every WHO Region, specifying the region by typing it out. It's better practice to automate rather than typing out by hand, and you can accomplish this with window functions that rank by partition, e.g.:

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/b4f88ba5-d9c1-4d89-8cdb-b18edd1de775" height="300">

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/d0dd7d98-e96b-4881-823e-a9286afa9e1c)


You can also use window functions to calculate a running total (more info here: https://learnsql.com/blog/what-is-a-running-total-and-how-to-compute-it-in-sql/), here specified only for totals from Algeria:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/363083d9-dbef-4cf4-b47e-949e3192b27a)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/f6552f8c-7f9b-4317-b11a-d6cb87f44092)


Adding PARTITION BY to this code allows you to view all the running totals, ordered by country:



<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/9befbdb7-8eaf-4338-8fef-09de9788583d" height="180">

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/9a82be33-969b-4d9b-898a-09210e463ce4" height="400">


[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/bc91116e-de80-47c1-98cf-60a2804da309)


### Correlated Subqueries
For correlated subqueries, the query must be re-executed for every row, which increases query runtime.

The following example uses a correlated subquery to identify the weeks for each country where the inf_a levels are higher than average. For every row in the outer query, the subquery computes the average inf_a for the given country and compares it to the inf_a at that row in the outer query. 

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/44853ddb-8862-4c31-8885-14ee1d692e9b" height="180">

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/8fc78ab6-8455-4f9d-be20-afa2691c9758" height="200">

On my machine, this query took over 26 seconds to complete. To compare, the previous query (using PARTITION BY, above) took only 86 msec. 


[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/62f6103e-bc09-4ed8-adb0-e4fc3a2e7c66)


### CASE WHEN
CASE WHEN allows you to pull different information in SELECT statements depending on certain parameters you set. In the example below, when the week of the year is in the first quarter, the statement will return "Q1" in a new column; when iso_week is in the second quarter of the year, the statement will return "Q2", and so on, where inf_a is over 100.

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/b11563f6-f2ca-41de-99b0-653da3b6bb18" height="400">

The main part of the query, under the CTE, then counts the number of rows per quarter and country and sorts them in descending order. The result is that we see the calendar quarters with the highest number of weeks with high levels of inf_a. It's no surprise that Q1 and Q4 (i.e., flu season!) have the most weeks with high incidences of inf_a.

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/30741f55-4570-4705-ac95-915c944d524e" height="300">

Using CASE WHEN to hard-code information isn't the most elegant way to gain this information, however. Using the date-time EXTRACT function to extract the quarter makes the process simpler, as seen below.


[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/e28fdc7d-dd6a-47b8-afa8-68c403b1d88a)

### Date-Time Functions

The previous query can be rewritten in the following way:

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/25927ac4-abda-4832-8761-dfb516a8ea2f" height="300">



Keep in mind that date-time functions are especially specific to the SQL you are using; PostgreSQL differs from MySQL, SQL Server, etc. 
More on PostgreSQL date-time functions can be found here: https://www.sqlshack.com/working-with-date-and-time-functions-in-postgresql/, and here: https://www.postgresql.org/docs/current/functions-datetime.html

EXTRACT(), used with quarter above, can also be used with day, month, year, day of week (DOW), etc., in the following way:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/97b3a1c5-6726-4899-b4ae-4b476476b418)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/9f0f39bc-7c55-46a7-9589-b759802e49d6)


[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/c75f2a15-cb98-4b90-b676-f47196c78d25)


### User-defined Scalar Functions

Scalar functions are functions that return one row per row of data (unlike aggregate functions, which aggregate multiple rows into one value). Scalar functions can be built-in or user-defined. For example, ROUND() is a built-in scalar function that rounds each given value to a specified number of decimal places. 

Users can define their own scalar functions and call these functions to transform their data. In this example, we create a function called "ishigh" that takes one parameter, an integer. If the integer is over 100, the function will return "YES", and if the integer is not, the function will return "NO". In the query below, we apply this function to the inf_a value to create a new field called "ishigh".

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/61a2ab7d-58f9-4384-8d2d-392293ad5c7e)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/ac32f5db-7934-4cd9-b3a2-a0f3b2424d7c)


Resources:
* https://www.postgresql.org/docs/current/xfunc-sql.html
* https://builtin.com/software-engineering-perspectives/sql-functions
* https://www.sqlservercentral.com/articles/postgresql-user-defined-functions

[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/b434a42b-d91a-4c58-9c18-1ae267040382)

### Using ROLLUP and CUBE for subtotals and totals

ROLLUP and CUBE can be used to show subtotals and totals in new rows. Both are extensions of the GROUP BY clause. 

Note: COALESCE() in the queries below can be used to substitute a more meaningful phrase (like "TOTAL") instead of the default display value for subtotal/total rows (a null value).

ROLLUP will produce subtotals and totals, and it assumes a hierarchy of inputs based on the order in which you name them in the ROLLUP statement. The "bigger" item (here the WHO Region) comes first, and ROLLUP will then offer us the subtotal for each country, each WHO Region, and a total for all WHO Regions.

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/b0a8db1f-d11a-48a5-93e9-9bfb08a8295d)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/01b8ef5b-8102-4d18-8e82-b35d9b8c25f8)


CUBE offers the functionality of ROLLUP, and in addition, it will offer subtotals for all other groupings of columns listed in the GROUP BY clause. In this example, the extra functionality of CUBE is not helpful, because there are no other meaningful types of groupings in this dataset using these two fields (beyond grouping countries into regions and regions into a whole). CUBE does produce additional outputs here, "grouping" each country by itself, but this duplicates the information found at the top of the result set. Please see the Resources below for situations in which CUBE can provide helpful cross-dimensional aggregations.

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/511aed12-91cc-450c-975d-7108e98a3af9)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/ee6313b3-1eb6-4e05-9daf-2928b93ac4c1)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/55add0e4-483f-4b9f-afbf-64b9330bc86e)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/a266dbd4-5905-44c3-a5f3-4550f8889299)




Resources:
* https://docs.oracle.com/cd/F49540_01/DOC/server.815/a68003/rollup_c.htm
* https://www.sqltutorial.org/sql-rollup/ 
* https://www.sqlservercentral.com/articles/the-difference-between-rollup-and-cube

[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/b434a42b-d91a-4c58-9c18-1ae267040382)


### Calculating Delta Values with LEAD and LAG

LEAD() and LAG() allow you to refer to a future or previous row relative to a given row. For example, if you would like to compare a value to that same value in the previous row to find the change, you can use LAG(). LEAD() and LAG() are also window functions.

The following example returns the date, the inf_a number, and the inf_a number from the most recent previous date (i.e., the row before, when the data is organized by date). You can specify a different offset (for example, if you wanted to compare the inf_a figure from two days before), but since we haven't specified one here, we are using the default offset, which is 1.

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/946581c2-13b0-47ce-bd06-5dee5d911b4a)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/377023a6-3a42-43af-9ff6-9523cac3e5b3)


LEAD() works similarly to LAG(), but it references a future row rather than a previous row:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/57018de8-c885-44de-abb8-69beb6c61f2d)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/b6635226-2cf3-4dd4-a5ab-4f7d1a8c9491)

[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/b434a42b-d91a-4c58-9c18-1ae267040382)

#### Calculating Variance with LEAD and LAG

You can also use these window functions to calculate variance. The example below uses the previous code in a CTE to establish a result set with the current and previous day's amounts, and then, in the main query, uses those to calculate the difference and the variance between the two figures.

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/4645af8c-776e-427f-ba0e-90ca468fa2e3)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/2eea7f45-ae0d-41ae-8165-33631476097a)

A few notes on this code:
* CAST is needed here in the CTE because when Postgres divides two integers, the result will also be an integer with remainder discarded. Therefore we need to cast one as a non-integer. https://datacomy.com/sql/postgresql/division/
* In addition, Postgres does not support the use of ROUND with a double precision type, so we must cast as NUMERIC to use ROUND. https://pgsql-sql.postgresql.narkive.com/835yQ640/sql-error-function-round-double-precision-integer-does-not-exist
* The double colon :: is a Postgres-specific alternative to CAST. https://stackoverflow.com/questions/15537709/what-does-do-in-postgresql

Resources:
* https://www.postgresqltutorial.com/postgresql-window-function/postgresql-lag-function/
* https://www.postgresqltutorial.com/postgresql-window-function/postgresql-lead-function/


[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/34f173f1-d041-410b-95fb-aafd0258fa35)


### RANK
RANK() is also a window function. RANK() is very similar to ROW_NUMBER() and DENSE_RANK(), so similar that I will discuss only one of the three here. All three will create a "rank" or order the result set by another value. ROW_NUMBER() will create unique values for all rows, similar to an index, even if the value being used to "order" is duplicated. 

With RANK(), rows with the same value are ranked with the same number. We can see this toward the bottom of the result set here:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/fdcdaaa0-a4d2-4a0b-b768-46faf7d3fe60)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/f95303d1-b77f-4edc-a0fa-17d0d6b1d078)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/0e52084f-571c-4541-b6a2-7fcafab63799)

In the above code, the CTE identifies the highest value for inf_a for each country. The main query then ranks that result set so that we can see these highest values ranked against one another.

In the illustration above, with RANK(), when a value used to order the set is duplicated, the "rank" skips a number. We can see this illustrated with the 141st rank above; since there are two countries with the same value for max_inf_a, there is no country listed at rank 142. This would not be true with DENSE_RANK; with DENSE_RANK(), identical values will receive the same rank, but the following rank will not be "skipped".

In short, you can use RANK(), ROW_NUMBER(), or DENSE_RANK() to create rankings for your data. To choose among them, you just need to decide how you want to treat your duplicate values vis-à-vis the ranking system.


Resources:
* https://www.postgresqltutorial.com/postgresql-window-function/postgresql-rank-function/
* https://www.postgresqltutorial.com/postgresql-window-function/postgresql-dense_rank-function/
* https://www.postgresqltutorial.com/postgresql-window-function/postgresql-row_number/
* https://www.eversql.com/rank-vs-dense_rank-vs-row_number-in-postgresql/

[Back to top](#FluNet)

![whitespace-small2](https://github.com/d-wiltshire/FluNet/assets/100863488/a4873a8d-a404-4324-9e9d-db9db3fb2b2d)


### EXCEPT versus NOT IN

EXCEPT will return the rows from the first query that do not appear in the result set of the second query (compare the use of union and intersect).

In this example, we're looking for the rows (relative to country and date) where the inf_a total is higher than 100, and the ah1n12009 figure comprises less than 50% of that inf_a total. EXCEPT excludes the rows in which ah1n12009 comprises more than 50% of the total.

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/8d4e5f9f-945f-4bb1-b624-bfb8623433df)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/1a21a3e0-5910-4383-98aa-fce94c9921e8)


We can rewrite this with a subquery and NOT IN:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/c850a5db-054d-464d-9bd8-dac2a77440ac)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/e0281392-9a26-4ae7-9e93-7741bcd01246)



Although these queries appear to return the same results in this case, there are subtle differences between the functioning of EXCEPT and NOT IN. 

In the NOT IN example above, the subquery simply creates a list of inf_a values. That list will include any inf_a value where (inf_a < ah1n12009 x 2) in a given row. In a dataset with many rows like this one, we may have identical inf_a values but for different dates and different countries (e.g., an inf_a value of 150 for the United States on 11-21-2022 and for France on 08-10-2022). If "150" is added to the list of inf_a values to be excluded from the final result set, we may be ultimately excluding too much data. I have limited this example to values in Argentina in order to create a result set small enough where unintended duplication is less likely, but this shoudn't be relied on in real-world situations.

Please consider https://stackoverflow.com/questions/7125291/postgresql-not-in-versus-except-performance-difference-edited-2 and discussion, especially regarding indexing.




Resources:
* https://www.essentialsql.com/sql-union-intersect-except/


[Back to top](#FluNet)
