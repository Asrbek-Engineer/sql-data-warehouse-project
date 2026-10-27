/*
==============================================================
DDL Script: Create Gold Views
==============================================================
Script Purpose:
	Creates the views of the 'gold' layer (star schema):
	dim_customers, dim_products and fact_sales.
	Each view combines and transforms data from the silver layer
	into clean, business-ready data.

Usage:
	Query the views directly for analytics and reporting.
==============================================================
*/
use DataWarehouse;
go

-- =============================================================
-- Create Dimension: gold.dim_customers
-- =============================================================
if object_id('gold.dim_customers', 'V') is not null
	drop view gold.dim_customers;
go

create view gold.dim_customers as
	select
		row_number() over(order by ci.cst_id) as customer_key,
		ci.cst_id as customer_id,
		ci.cst_key as customer_number,
		ci.cst_firstname as first_name,
		ci.cst_lastname as last_name,
		la.cntry as country,
		ci.cst_marital_status as marital_status,
		case
			when ci.cst_gndr != 'n/a' then ci.cst_gndr -- CRM is the Master for gender Info
			else coalesce(ca.gen, 'n/a')
		end as gender,
		ci.cst_create_date as create_date,
		ca.bdate as birth_date
	from silver.crm_cust_info as ci
	left join silver.erp_cust_az12 as ca
		on ci.cst_key = ca.cid
	left join silver.erp_loc_a101 as la
		on ci.cst_key = la.cid;
go

-- =============================================================
-- Create Dimension: gold.dim_products
-- =============================================================
if object_id('gold.dim_products', 'V') is not null
	drop view gold.dim_products;
go

create view gold.dim_products as
	select
		row_number() over(order by pn.prd_start_dt, pn.prd_key) as product_key,
		pn.prd_id as product_id,
		pn.prd_key as product_number,  
		pn.prd_nm as product_name,
		pn.cat_id as category_id,
		pc.cat as category,
		pc.subcat as subcategory,
		pn.prd_cost as cost,
		pn.prd_line as product_line, 
		pn.prd_start_dt as start_date, 
		pc.maintenance
	from silver.crm_prd_info as pn
	left join silver.erp_px_cat_g1v2 as pc
		on pn.cat_id = pc.id
	where pn.prd_end_dt is null -- Filter out all Historical data
go

-- =============================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================
if object_id('gold.fact_sales', 'V') is not null
	drop view gold.fact_sales;
go

create view gold.fact_sales as
	select
		sls_ord_num as order_number, 
		pr.product_key,
		cu.customer_key,
		sls_order_dt as order_date,
		sls_ship_dt as shipping_date, 
		sls_due_dt as due_date, 
		sls_sales as sales_amount, 
		sls_quantity as quantity,
		sls_price as price
	from silver.crm_sales_details as sd
	left join gold.dim_products as pr
		on sd.sls_prd_key = pr.product_number
	left join gold.dim_customers as cu
		on sd.sls_cust_id = cu.customer_id;
go