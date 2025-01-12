# COFFEE-SALES-analysis-using-SQL
![Coffee Image](https://github.com/nphan91/COFFEE-SALES-analysis-using-SQL/blob/main/Coffee%20Image.png)

## 1. Coffee Consumers Count
How many people in each city are estimated to consume coffee, given that 25% of the population does?
```sql
SELECT city_name,
		ROUND (([population]*0.25)/1000000,2) AS Coffee_consumers_in_millions
FROM [dbo].[city]
```
## 2. Total Revenue from Coffee Sales
What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
```sql
SELECT CI.[city_name],
SUM (S.[total]) AS Coffee_Sales
FROM [dbo].[sales] S
JOIN [dbo].[customers] CU
ON S.customer_id= CU.customer_id
JOIN [dbo].[city] CI
ON CI.city_id= CU.city_id
WHERE DATEPART(QUARTER, S.[sale_date]) = '4' AND
YEAR(S.[sale_date])= '2023'
GROUP BY CI.[city_name];
```
## 3. Sales Count for Each Product
How many units of each coffee product have been sold?
```sql
SELECT P.product_id,
		P.product_name,
		COUNT(S.[sale_id]) AS Units_sold
FROM [dbo].[products] P
LEFT JOIN [dbo].[sales] S
ON P.product_id= S.product_id
GROUP BY P.product_id, P.product_name;
```
## 4. Average Sales Amount per City
What is the average sales amount per customer in each city?
```sql
