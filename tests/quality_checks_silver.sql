/*
==============================================================
Quality Checks: Silver Layer
==============================================================
Run after loading the silver layer. Queries marked
"Expectation: No results" must return no rows.
*/
use DataWarehouse;
go

-- ====================================
-- Checking silver.crm_cust_info
-- ====================================
-- Check for Nulls or Duplicates in Primary key
-- Expectation: No results
select
	cst_id,
	count(*) as c
from silver.crm_cust_info
group by cst_id
having count(*) > 1 or cst_id is null

-- Expectation: No results
select
	cst_firstname
from silver.crm_cust_info
where cst_firstname != trim(cst_firstname)

-- Data Standardization & Consistency
select
	distinct cst_gndr
from silver.crm_cust_info

select
	distinct cst_marital_status
from silver.crm_cust_info

-- ====================================
-- Checking silver.crm_prd_info
-- ====================================
-- Check for Nulls or Duplicates in Primary key
-- Expectation: No results
select
	prd_id,
	count(*) as c
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is null

-- Check for unwanted spaces
-- Expectation: No results
select
	prd_nm
from silver.crm_prd_info
where prd_nm != trim(prd_nm)

-- Checking for Nulls or Negative numbers
-- Expectation: No results
select
	prd_cost
from silver.crm_prd_info
where prd_cost < 0 or prd_cost is null

-- Data Standardization & Consistency
select
	distinct prd_line
from silver.crm_prd_info

-- Check for Invalid Date Orders
-- Expectation: No results
select *
from silver.crm_prd_info
where prd_end_dt < prd_start_dt

use DataWarehouse;
go
-- Check for Invalid Dates
select
	nullif(sls_order_dt, 0) as sls_order_dt,
	sls_ship_dt
from bronze.crm_sales_details
where
	sls_order_dt <= 0 or 
	len(sls_order_dt) != 8 or
	sls_order_dt > 20500101 or
	sls_order_dt < 19000101

-- Check for Invalid Date Orders
select 
	*
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

-- Check Data Consistency, Between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must not be Null, Zero or Negative
select distinct
	sls_sales,
	sls_quantity,
	sls_price
from silver.crm_sales_details
where 
	sls_sales != sls_quantity * sls_price or
	sls_sales is null or sls_quantity is null or sls_price is null or
	sls_sales <= 0 or sls_quantity <= 0 or sls_price <= 0

-- Identify Out-of-Range dates
select distinct
	bdate
from silver.erp_cust_az12
where bdate < '1926-01-01' or bdate > getdate() -- Expectation: very old dates are kept on purpose, only future dates are removed

-- Data Standardization & Consistency
select distinct
	case
		when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'
		when upper(trim(gen)) in ('M', 'MALE') then 'Male'
		else 'n/a'
	end as gen
from silver.erp_cust_az12

-- erp
-- Data Standardization & Consistency
select distinct 
	case 
		when trim(cntry) = 'DE' then 'Germany'
		when trim(cntry) in ('US', 'USA') then 'United States'
		when trim(cntry) = '' or cntry is null then 'n/a'
		else trim(cntry)
	end as cntry
from silver.erp_loc_a101
order by cntry

-- Check for unwanted Spaces
select
	* 
from silver.erp_px_cat_g1v2
where cat != trim(cat) or subcat != trim(subcat) or maintenance != trim(maintenance)

-- Data Standardization & Consistency
select distinct
	maintenance 
from silver.erp_px_cat_g1v2