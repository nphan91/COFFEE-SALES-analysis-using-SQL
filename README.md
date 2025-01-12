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
What is the average sales amount for all customers in each city?
```sql
SELECT CI.[city_name],
		AVG (S.[total]) AS Avg_Sales
FROM [dbo].[sales] S
LEFT JOIN [dbo].[customers] CU
ON S.customer_id = CU.customer_id
LEFT JOIN [dbo].[city] CI
ON CU.city_id = CI.city_id
GROUP BY CI.[city_name];
```
## 5. City Population and Coffee Consumers
Provide a list of cities along with their populations and estimated coffee consumers.
```sql
SELECT [city_name],
		[population],
		([population]*0.25) AS estimated_coffee_consumers
FROM [dbo].[city];
```
## 6. Top Selling Products by City
What are the top 3 selling products in each city based on sales volume?
```sql
WITH RankedProducts AS (
SELECT CI.[city_name],
		P.[product_name],
		SUM(S.[total]) AS Sales_Volumn,
		ROW_NUMBER() OVER (PARTITION BY CI.[city_name] ORDER BY SUM(S.[total]) DESC) AS 'Rank' 
FROM [dbo].[products] P
JOIN [dbo].[sales] S
ON P.product_id = S.product_id
JOIN [dbo].[customers] CU
ON CU.customer_id = S.customer_id
JOIN [dbo].[city] CI
ON CI.[city_id] = CU.city_id
GROUP BY CI.[city_name], P.[product_name]
)
SELECT [city_name],
		[product_name],
		Sales_Volumn
FROM RankedProducts
WHERE Rank <= 3
ORDER BY [city_name], Sales_Volumn DESC;
```
## 7. Customer Segmentation by City
How many unique customers are there in each city who have purchased coffee products?
```sql
SELECT DISTINCT 
		CI.[city_id], 
		CI.city_name,
		COUNT(CU.[customer_id]) AS no_customers_by_city
FROM [dbo].[customers] CU
LEFT JOIN [dbo].[city] CI
ON CU.city_id = CI.city_id
GROUP BY CI.[city_id], CI.city_name;
```
## 8. Average Sale vs Rent
Find each city and their average sale per customer and avg rent per customer
```sql
WITH city_table AS (
    SELECT 
        CI.city_name,
        SUM(S.total) AS total_revenue,
        COUNT(DISTINCT CU.customer_id) AS total_customers,
        ROUND(
            SUM(S.total) * 1.0 / COUNT(DISTINCT CU.customer_id), 2
        ) AS avg_sale_per_customer
    FROM 
        [dbo].[sales] S
    JOIN 
        [dbo].[customers] CU ON CU.customer_id = S.customer_id
    JOIN 
        [dbo].[city] CI ON CI.city_id = CU.city_id
    GROUP BY CI.city_name
)
SELECT 
    CT.city_name,
    CT.avg_sale_per_customer,
    CI.estimated_rent,
    ROUND(
        CI.estimated_rent * 1.0 / CT.total_customers, 2
    ) AS avg_rent_per_customer
FROM 
    city_table CT
JOIN 
    [dbo].[city] CI ON CT.city_name = CI.city_name
ORDER BY avg_sale_per_customer DESC;
```

