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