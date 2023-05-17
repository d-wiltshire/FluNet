# FluNet
**Work in progress**

>>>ADD table of contents with links down the page for demonstrated concepts in Goal section

- [CTEs](###-ctes)
- [Window Functions](###-window-functions)

## Goal 

The goal of this project is to serve as a teaching tool for intermediate SQL students by demonstrating and explaining SQL concepts (using PostgreSQL).

## About the data

The dataset consists of World Health Organization FluNet data through 3/13/23. The dataset is <a href="https://www.who.int/tools/flunet">available here.</a>

The data dictionary is also <a href="https://app.powerbi.com/view?r=eyJrIjoiNjViM2Y4NjktMjJmMC00Y2NjLWFmOWQtODQ0NjZkNWM1YzNmIiwidCI6ImY2MTBjMGI3LWJkMjQtNGIzOS04MTBiLTNkYzI4MGFmYjU5MCIsImMiOjh9">available here,</a> and it can be found as an image file stored in this repository.

### A quick look

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/1089a5ee-cf41-4b32-9309-ec15a6c82f33)

In general, the data provides information about the number of confirmed cases of two flu strains (A and B) and the subtypes of the confirmed cases relative to country and date (by week). We are able to filter to find the number of the total cases of the A strain (inf_a) for Algeria in the first week of 2022, for example, and compare that to relative frequencies of other countries and in other weeks. We are also able to compare the relative prevalence of strain subtypes.

### Sample query

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/7be3ee72-53aa-4812-a5ab-bd22292861a1)

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/05a51ca6-5d2e-4ea7-8ebb-2b98dd2b943e)

For example, we can group by the week of the year (i.e., 1-52) to determine which weeks of the year have the highest prevalence of subtype A (and check out the relative frequencies of subtype B at the same time).  


## Demonstrating Concepts

### CTEs

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/d9ca1808-c224-4a56-a452-9efbe10b7067)


#### Recursive CTEs

Resources: 
* https://www.sqlservertutorial.net/sql-server-basics/sql-server-recursive-cte/
* https://builtin.com/data-science/recursive-sql

### Window Functions



### Correlated Subqueries



### CASE WHEN



### Date-Time functions



### User-defined scalar functions




### Calculating running totals with CUBE and ROLLUP




### Pivots


### Calculating delta values with LEAD and LAG


### RANK



### EXCEPT versus NOT IN
