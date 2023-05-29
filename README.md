# FluNet
**Work in progress**

Table of contents:
- [CTEs](#ctes)
- [Window Functions](#window-functions)
- [Correlated Subqueries](#correlated-subqueries)
- [CASE WHEN](#case-when)
- [Date-Time Functions](#date-time-functions)
- [User-defined Scalar Functions](#user-defined-scalar-functions)
- [Calculating Running Totals with CUBE and ROLLUP](#calculating-running-totals-with-cube-and-rollup)
- [Pivots](#pivots)
- [Calculating Delta Values with LEAD and LAG](#calculating-delta-values-with-lead-and-lag)
- [RANK](#rank)
- [EXCEPT versus NOT IN](#except-versus-not-in)


## Goal 

The goal of this project is to serve as a teaching tool for SQL students by demonstrating and explaining intermediate-level SQL concepts (using PostgreSQL).

## About the data

The dataset consists of World Health Organization FluNet data through 3/13/23. The dataset is <a href="https://www.who.int/tools/flunet">available here.</a>

The data dictionary is also <a href="https://app.powerbi.com/view?r=eyJrIjoiNjViM2Y4NjktMjJmMC00Y2NjLWFmOWQtODQ0NjZkNWM1YzNmIiwidCI6ImY2MTBjMGI3LWJkMjQtNGIzOS04MTBiLTNkYzI4MGFmYjU5MCIsImMiOjh9">available here,</a> and it can be found as an image file stored in this repository.

### A quick look

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/1089a5ee-cf41-4b32-9309-ec15a6c82f33)

In general, the data provides information about the number of confirmed cases of two flu strains (A and B) and the subtypes of the confirmed cases relative to country and date (by week). We are able to filter to find the number of the total cases of the A strain (inf_a) for Algeria in the first week of 2022, for example, and compare that to relative frequencies of other countries and in other weeks. We are also able to compare the relative prevalence of strain subtypes.

### Sample query

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/7be3ee72-53aa-4812-a5ab-bd22292861a1" height="250">

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/05a51ca6-5d2e-4ea7-8ebb-2b98dd2b943e)

For example, we can group by the week of the year (i.e., 1-52) to determine which weeks of the year have the highest prevalence of subtype A (and check out the relative frequencies of subtype B at the same time).  

[Back to top](#FluNet)

## Demonstrating Concepts

### CTEs

<img src="https://github.com/d-wiltshire/FluNet/assets/100863488/d9ca1808-c224-4a56-a452-9efbe10b7067" height="450">



[Back to top](#FluNet)

#### Recursive CTEs

Resources: 
* https://www.sqlservertutorial.net/sql-server-basics/sql-server-recursive-cte/
* https://builtin.com/data-science/recursive-sql

[Back to top](#FluNet)

### Window Functions
Window functions are a preferred way to perform calculations across sets of rows. For example, if you wanted to find the top N weeks of the year for subtype A prevalence for each WHO Region, you could use a series of UNION statements, e.g.

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/c25b7e93-c4ab-4cec-abab-f8302e5872c0)
 
This would require you to repeat this code for every WHO Region, specifying the region by typing it out. It's better practice to automate rather than typing out by hand, and you can accomplish this with window functions that rank by partition, e.g.:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/b4f88ba5-d9c1-4d89-8cdb-b18edd1de775)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/d0dd7d98-e96b-4881-823e-a9286afa9e1c)


You can also use window functions to calculate a running total (more info here: https://learnsql.com/blog/what-is-a-running-total-and-how-to-compute-it-in-sql/), here specified only for totals from Algeria:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/a8034c74-5938-4d62-a35c-c2e4561b669e)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/3d3b75a4-d468-4277-8206-84e50d148d39)

Adding PARTITION BY to this code allows you to view all the running totals, ordered by country:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/9befbdb7-8eaf-4338-8fef-09de9788583d)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/9a82be33-969b-4d9b-898a-09210e463ce4)


[Back to top](#FluNet)

### Correlated Subqueries
For correlated subqueries, the query must be re-executed for every row, which increases query runtime.

The following example uses a correlated subquery to identify the weeks for each country where the inf_a levels are higher than average. For every row in the outer query, the subquery computes the average inf_a for the given country and compares it to the inf_a at that row in the outer query. 

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/44853ddb-8862-4c31-8885-14ee1d692e9b)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/8fc78ab6-8455-4f9d-be20-afa2691c9758)

On my machine, this query took over 26 seconds to complete. To compare, the previous query (using PARTITION BY, above) took only 86 msec. 


[Back to top](#FluNet)

### CASE WHEN
CASE WHEN allows you to pull different information in SELECT statements depending on certain parameters you set. In the example below, when the week of the year is in the first quarter, the statement will return "Q1" in a new column; when iso_week is in the second quarter of the year, the statement will return "Q2", and so on, where inf_a is over 100.

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/b11563f6-f2ca-41de-99b0-653da3b6bb18)

The main part of the query, under the CTE, then counts the number of rows per quarter and country and sorts them in descending order. The result is that we see the calendar quarters with the highest number of weeks with high levels of inf_a. It's no surprise that Q1 and Q4 (i.e., flu season!) have the most weeks with high incidences of inf_a.

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/30741f55-4570-4705-ac95-915c944d524e)

Using CASE WHEN to hard-code information isn't the most elegant way to gain this information, however. Using the date-time EXTRACT function to extract the quarter makes the process simpler, as seen below.


[Back to top](#FluNet)

### Date-Time Functions

The previous query can be rewritten in the following way:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/25927ac4-abda-4832-8761-dfb516a8ea2f)



Keep in mind that date-time functions are especially specific to the SQL you are using; PostgreSQL differs from MySQL, SQL Server, etc. 
More on PostgreSQL date-time functions can be found here: https://www.sqlshack.com/working-with-date-and-time-functions-in-postgresql/, and here: https://www.postgresql.org/docs/current/functions-datetime.html

EXTRACT(field FROM source), used with quarter above, can also be used with day, month, year, day of week (DOW), etc.:

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/97b3a1c5-6726-4899-b4ae-4b476476b418)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/9f0f39bc-7c55-46a7-9589-b759802e49d6)


[Back to top](#FluNet)

### User-defined Scalar Functions
>> delete this section?


[Back to top](#FluNet)

### Calculating Running Totals with CUBE and ROLLUP

CUBE and ROLLUP can be used to identify running totals
More here: https://docs.oracle.com/cd/F49540_01/DOC/server.815/a68003/rollup_c.htm

[Back to top](#FluNet)

### Pivots


[Back to top](#FluNet)

### Calculating Delta Values with LEAD and LAG



[Back to top](#FluNet)

### RANK



[Back to top](#FluNet)

### EXCEPT versus NOT IN

EXCEPT will return the rows from the first query that do not appear in the result set of the second query (compare the function of union, intersect). In this example, we're looking for the rows (relative to country and date) where the inf_a total is higher than 100, and the ah1n12009 figure comprises less than 50% of that inf_a total. EXCEPT excludes the rows in which ah1n12009 comprises more than 50% of the total.

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/f277b43c-8cd4-44b9-9159-ea88e01d6229)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/80a7ac49-762a-4d21-9e2d-e36751bd5b18)



[Back to top](#FluNet)
