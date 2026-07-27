-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
CREATE OR REPLACE VIEW gold.dim_customers AS 

SELECT
	ROW_NUMBER() OVER (ORDER BY ci.cst_id ASC) AS customer_key,		-- Surrogate Key
	ci.cst_id 					AS customer_id,
	ci.cst_key					AS customer_number,
	ci.cst_firstname			AS first_name,
	ci.cst_lastname				AS last_name,
	la.cntry 					AS country,
	ci.cst_marital_status		AS marital_status,
	CASE 
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr		-- CRM is the master data
		ELSE COALESCE(ca.gen, 'n/a')					-- Else return ERP gender
	END 						AS gender,
	ca.bdate					AS birthdate,
	ci.cst_create_date			AS create_date
	
FROM SILVER.CRM_CUST_INFO ci
LEFT JOIN SILVER.ERP_CUST_AZ12 ca
	ON ci.cst_key = ca.cid
LEFT JOIN SILVER.ERP_LOC_A101 la
	ON ci.cst_key = la.cid;
	
-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
CREATE OR REPLACE VIEW gold.dim_products AS 

SELECT
	ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_key) AS product_key,
	pi.prd_id 			AS product_id,
	pi.prd_key 			AS product_number,
	pi.prd_nm 			AS product_name,
	pi.prd_line 		AS product_line,
	pi.cat_id 			AS category_id,
	pc.cat 				AS category,
	pc.subcat 			AS subcategory,
	pc.maintenance 		AS maintenance,
	pi.prd_cost 		AS cost,
	pi.prd_start_dt 	AS start_date

FROM SILVER.CRM_PRD_INFO pi
LEFT JOIN SILVER.ERP_PX_CAT_G1V2 pc
	ON pi.cat_id = pc.id
	
WHERE pi.prd_end_dt IS NULL;		-- Filter for historical of products

-- =============================================================================
-- Create Fact Table: gold.facts_sales
-- =============================================================================
CREATE OR REPLACE VIEW gold.fact_sales AS

SELECT 
	sd.sls_ord_num 		AS order_number,
	cu.customer_key 	AS customer_key,
	pr.product_key 		AS product_key,
	sd.sls_order_dt 	AS order_date,
	sd.sls_ship_dt 		AS shipping_date,
	sd.sls_due_dt 		AS due_date,
	sd.sls_sales 		AS sales_amount,
	sd.sls_quantity 	AS quantity,
	sd.sls_price 		AS price	
	
	
FROM SILVER.CRM_SALES_DETAILS sd
LEFT JOIN GOLD.DIM_PRODUCTS pr
	ON sd.sls_prd_key = pr.product_number
LEFT JOIN GOLD.DIM_CUSTOMERS cu
	ON sd.sls_cust_id = cu.customer_id;


