--Q.1 Coffee Consumers Count
--How many people in each city are estimated to consume coffee, given that 25% of the population does?
SELECT city_name,
		ROUND (([population]*0.25)/1000000,2) AS Coffee_consumers_in_millions
FROM [dbo].[city]


--Q.2 Total Revenue from Coffee Sales
--What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
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

--Q.3 Sales Count for Each Product
--How many units of each coffee product have been sold?
SELECT P.product_id,
		P.product_name,
		COUNT(S.[sale_id]) AS Units_sold
FROM [dbo].[products] P
LEFT JOIN [dbo].[sales] S
ON P.product_id= S.product_id
GROUP BY P.product_id, P.product_name;

--Q.4 Average Sales Amount per City
--What is the average sales amount for all customers in each city?
SELECT CI.[city_name],
		AVG (S.[total]) AS Avg_Sales
FROM [dbo].[sales] S
LEFT JOIN [dbo].[customers] CU
ON S.customer_id = CU.customer_id
LEFT JOIN [dbo].[city] CI
ON CU.city_id = CI.city_id
GROUP BY CI.[city_name];

--Q.5 City Population and Coffee Consumers
--Provide a list of cities along with their populations and estimated coffee consumers.
SELECT [city_name],
		[population],
		([population]*0.25) AS estimated_coffee_consumers
FROM [dbo].[city];

--Q.6 Top Selling Products by City
--What are the top 3 selling products in each city based on sales volume?
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

--Q.7 Customer Segmentation by City
--How many unique customers are there in each city who have purchased coffee products?

SELECT DISTINCT 
		CI.[city_id], 
		CI.city_name,
		COUNT(CU.[customer_id]) AS no_customers_by_city
FROM [dbo].[customers] CU
LEFT JOIN [dbo].[city] CI
ON CU.city_id = CI.city_id
GROUP BY CI.[city_id], CI.city_name;


--Q.8 Average Sale vs Rent
--Find each city and their average sale per customer and avg rent per customer
-- Q.8 Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer
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


--Q.9 Monthly Sales Growth
--Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
-- Q.9 Optimized Monthly Sales Growth by City
WITH monthly_sales AS (
    SELECT 
        ci.city_name,
        MONTH(s.sale_date) AS month,
        YEAR(s.sale_date) AS year,
        SUM(s.total) AS total_sales
    FROM sales AS s
    JOIN customers AS c
        ON c.customer_id = s.customer_id
    JOIN city AS ci
        ON ci.city_id = c.city_id
    GROUP BY ci.city_name, YEAR(s.sale_date), MONTH(s.sale_date)
),
sales_with_lag AS (
    SELECT
        city_name,
        month,
        year,
        total_sales AS current_month_sales,
        LAG(total_sales) OVER (PARTITION BY city_name ORDER BY year, month) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    city_name,
    month,
    year,
    current_month_sales,
    previous_month_sales,
    ROUND(
        (current_month_sales - previous_month_sales) * 100.0 / NULLIF(previous_month_sales, 0), 2
    ) AS growth_percentage
FROM sales_with_lag
WHERE previous_month_sales IS NOT NULL
ORDER BY city_name, year, month;

--Q.10 Market Potential Analysis
--Identify top 3 city based on highest sales, return city name, total sale, total rent, 
--total customers, estimated coffee consumer
WITH city_sales AS (
    SELECT 
        ci.city_name,
        SUM(s.total) AS total_sales,
        SUM(ci.estimated_rent) AS total_rent,
        COUNT(DISTINCT c.customer_id) AS total_customers,
        ROUND(ci.population * 0.25, 0) AS estimated_coffee_consumers
    FROM sales AS s
    JOIN customers AS c
        ON s.customer_id = c.customer_id
    JOIN city AS ci
        ON c.city_id = ci.city_id
    GROUP BY ci.city_name, ci.population
),
ranked_cities AS (
    SELECT 
        city_name,
        total_sales,
        total_rent,
        total_customers,
        estimated_coffee_consumers,
        RANK() OVER (ORDER BY total_sales DESC) AS rank_by_sales
    FROM city_sales
)
SELECT 
    city_name,
    total_sales,
    total_rent,
    total_customers,
    estimated_coffee_consumers
FROM ranked_cities
WHERE rank_by_sales <= 3
ORDER BY total_sales DESC;

