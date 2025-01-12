# COFFEE-SALES-analysis-using-SQL
![Coffee Image](https://github.com/nphan91/COFFEE-SALES-analysis-using-SQL/blob/main/Coffee%20Image.png)

## Coffee Consumers Count
How many people in each city are estimated to consume coffee, given that 25% of the population does?
```sql
SELECT city_name,
		ROUND (([population]*0.25)/1000000,2) AS Coffee_consumers_in_millions
FROM [dbo].[city]
```
