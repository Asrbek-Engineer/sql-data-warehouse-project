/*
==============================================================
Load Silver Layer (bronze -> silver) - draft
==============================================================
Will be wrapped into the procedure silver.load_silver.
*/
use DataWarehouse;
go

truncate table silver.crm_cust_info;
insert into silver.crm_cust_info (
	cst_id,
	cst_key, 
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr, 
	cst_create_date
)

select 
	cst_id,
	cst_key,
	trim(cst_firstname) as cst_firstname,
	trim(cst_lastname) as cst_lastname,
	case upper(trim(cst_marital_status))
		when 'S' then 'Single'
		when 'M' then 'Married'
		else 'n/a'
	end as cst_marital_status, -- Normalize marital status values to readable format
	case upper(trim(cst_gndr))
		when 'F' then 'Female'
		when 'M' then 'Male'
		else 'n/a'
	end as cst_gndr, -- Normalize gender values to readable format
	cst_create_date
from (
	select
		*,
		row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
	from bronze.crm_cust_info
	where cst_id is not null
)t where flag_last = 1; -- Select the most recent record per customer

truncate table silver.crm_prd_info;
insert into silver.crm_prd_info (
	prd_id,
	cat_id,
	prd_key, 
	prd_nm, 
	prd_cost, 
	prd_line, 
	prd_start_dt, 
	prd_end_dt
)

select
	prd_id, 
	replace(substring(prd_key, 1, 5), '-', '_') as cat_id, -- Extract category ID
	substring(prd_key, 7, len(prd_key)) as prd_key, -- Extract product key
	prd_nm, 
	isnull(prd_cost, 0) as prd_cost, -- Handling Nulls
	case upper(trim(prd_line))
		when 'M' then 'Mountain'
		when 'R' then 'Road'
		when 'S' then 'Other Sales'
		when 'T' then 'Touring'
		else 'n/a'
	end as prd_line, -- Map product line codes to descriptive values
	prd_start_dt, 
	-- Calculate end date as one day before the next start date
	dateadd(day, -1, lead(prd_start_dt) over(partition by prd_key order by prd_start_dt)) as prd_end_dt
from bronze.crm_prd_info;
