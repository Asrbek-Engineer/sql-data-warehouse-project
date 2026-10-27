/*
==============================================================
Quality Checks: Gold Layer
==============================================================
Script Purpose:
	Validates the integrity of the gold layer:
	- Uniqueness of surrogate keys in the dimension views.
	- Referential integrity between the fact and dimension views.

Usage Notes:
	- Run after the silver layer is loaded.
	- Queries marked "Expectation: No results" must return no rows.
==============================================================
*/
use DataWarehouse;
go

-- Check uniqueness of surrogate keys
-- Expectation: No results
select customer_key, count(*) from gold.dim_customers group by customer_key having count(*) > 1;
select product_key, count(*) from gold.dim_products group by product_key having count(*) > 1;

-- Check referential integrity: every fact row must find its dimensions
-- Expectation: No results
select *
from gold.fact_sales as f
left join gold.dim_customers as c on c.customer_key = f.customer_key
left join gold.dim_products as p on p.product_key = f.product_key
where c.customer_key is null or p.product_key is null;