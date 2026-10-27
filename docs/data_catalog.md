# Data Catalog: Gold Layer

## Overview
The Gold layer is the business-level data model of the warehouse.
It is built as a **star schema**: two dimension views (`dim_customers`, `dim_products`)
and one fact view (`fact_sales`), ready for reporting and analytics.

- **Source:** Silver layer (cleaned and standardized CRM + ERP data)
- **Object type:** Views (no data is stored, always up to date with Silver)
- **Keys:** surrogate keys (`customer_key`, `product_key`) are generated in the Gold layer
  with `ROW_NUMBER()` and link the fact view to the dimensions

---

## 1. gold.dim_customers
**Purpose:** one row per customer, with CRM details enriched by ERP demographic and location data.
**Grain:** one row = one customer.
**Sources:** `silver.crm_cust_info`, `silver.erp_cust_az12`, `silver.erp_loc_a101`

| Column | Data Type | Description |
|---|---|---|
| customer_key | BIGINT | Surrogate key, unique for each customer. Used to join `fact_sales`. |
| customer_id | INT | Customer ID from the CRM system. |
| customer_number | NVARCHAR(50) | Business key from the CRM system (e.g. `AW00011000`). Used to link CRM and ERP data. |
| first_name | NVARCHAR(50) | Customer's first name, trimmed. |
| last_name | NVARCHAR(50) | Customer's last name, trimmed. |
| country | NVARCHAR(50) | Country of residence (from ERP), e.g. `Germany`, `United States`. `n/a` if unknown. |
| marital_status | NVARCHAR(50) | `Married`, `Single` or `n/a`. |
| gender | NVARCHAR(50) | `Male`, `Female` or `n/a`. CRM is the master source; ERP is used only when CRM has `n/a`. |
| create_date | DATE | Date the customer record was created in the CRM system. |
| birth_date | DATE | Customer's date of birth (from ERP). Future dates were set to NULL in Silver. |

---

## 2. gold.dim_products
**Purpose:** one row per current product, with category information.
**Grain:** one row = one product (current version only; historical versions are filtered out).
**Sources:** `silver.crm_prd_info`, `silver.erp_px_cat_g1v2`

| Column | Data Type | Description |
|---|---|---|
| product_key | BIGINT | Surrogate key, unique for each product. Used to join `fact_sales`. |
| product_id | INT | Product ID from the CRM system. |
| product_number | NVARCHAR(50) | Business key of the product (e.g. `BK-R93R-62`). Used to link sales records. |
| product_name | NVARCHAR(50) | Descriptive product name, e.g. `Mountain-100 Black- 38`. |
| category_id | NVARCHAR(50) | Category identifier (e.g. `BI_RB`), links the product to its category. |
| category | NVARCHAR(50) | High-level category, e.g. `Bikes`, `Components`. |
| subcategory | NVARCHAR(50) | More detailed classification inside the category, e.g. `Road Bikes`. |
| cost | INT | Cost of the product in whole currency units. `0` if missing in the source. |
| product_line | NVARCHAR(50) | `Mountain`, `Road`, `Touring`, `Other Sales` or `n/a`. |
| start_date | DATE | Date from which this product version is valid. |
| maintenance | NVARCHAR(50) | Whether the product needs maintenance: `Yes` or `No`. |

---

## 3. gold.fact_sales
**Purpose:** sales transactions for analysis, linked to customers and products.
**Grain:** one row = one order line (one product in one order).
**Source:** `silver.crm_sales_details`

| Column | Data Type | Description |
|---|---|---|
| order_number | NVARCHAR(50) | Unique sales order ID, e.g. `SO43697`. |
| product_key | BIGINT | Surrogate key, links to `gold.dim_products`. |
| customer_key | BIGINT | Surrogate key, links to `gold.dim_customers`. |
| order_date | DATE | Date the order was placed. |
| shipping_date | DATE | Date the order was shipped. |
| due_date | DATE | Date the payment was due. |
| sales_amount | INT | Total value of the line in whole currency units. Rule: `sales_amount = quantity * price` (recalculated in Silver when invalid). |
| quantity | INT | Number of units ordered. |
| price | INT | Price per unit in whole currency units. Derived from sales / quantity in Silver when invalid. |
