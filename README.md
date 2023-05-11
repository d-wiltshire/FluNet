# FluNet
**Work in progress**

## Goal 

The goal of this project is to serve as a teaching tool for intermediate SQL students by demonstrating and explaining SQL concepts (using PostgreSQL).

## About the data

The dataset consists of World Health Organization FluNet data through 3/13/23. The dataset is <a href="https://www.who.int/tools/flunet">available here.</a>

The data dictionary is also <a href="https://app.powerbi.com/view?r=eyJrIjoiNjViM2Y4NjktMjJmMC00Y2NjLWFmOWQtODQ0NjZkNWM1YzNmIiwidCI6ImY2MTBjMGI3LWJkMjQtNGIzOS04MTBiLTNkYzI4MGFmYjU5MCIsImMiOjh9">available here,</a> and it can be found as an image file stored in this repository.

### A quick look

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/1089a5ee-cf41-4b32-9309-ec15a6c82f33)

In general, the data provides information about the number of confirmed cases of two flu strains (A and B) and the subtypes of the confirmed cases relative to country and date (by week). We are able to filter to find the number of the total cases of the A strain (inf_a) for Algeria in the first week of 2022, for example, and compare that to relative frequencies of other countries and in other weeks. We are also able to compare the relative prevalence of strain subtypes.



## Sample Functions

### CTEs

![image](https://github.com/d-wiltshire/FluNet/assets/100863488/d9ca1808-c224-4a56-a452-9efbe10b7067)


#### Recursive CTEs

Resources: 
* https://www.sqlservertutorial.net/sql-server-basics/sql-server-recursive-cte/
* https://builtin.com/data-science/recursive-sql

### Window Functions


*Note idiosyncrasies of Postgres relative to MySQL, etc.
