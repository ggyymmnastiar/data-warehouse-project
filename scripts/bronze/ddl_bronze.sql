/*
=============================================================
DDL Script: Create Bronze Tables
=============================================================
Script Purpose:
    This script creates tables in the 'bronze' schema,
    representing the raw layer of the data warehouse.
    These tables store data as-is from the source systems
    (CRM and ERP) without any transformation.

    Run this script on the 'datawarehouse' database.
=============================================================
*/


-- =============================================================
-- SOURCE: CRM (Customer Relationship Management)
-- =============================================================

-- Drop and recreate table: bronze.crm_cust_info
-- Source file: source_crm/cust_info.csv
-- Contains raw customer master data from CRM system

DROP TABLE IF EXISTS bronze.crm_cust_info;

create table bronze.crm_cust_info (
	cst_id 				INT,
	cst_key 			VARCHAR(50),
	cst_firstname 		VARCHAR(50),
	cst_lastname 		VARCHAR(50),
	cst_marital_status 	VARCHAR(50),
	cst_gndr 			VARCHAR(50),
	cst_create_date 	DATE 
);

DROP TABLE IF EXISTS bronze.crm_prd_info;

create table bronze.crm_prd_info (
	prd_id 			INT,
	prd_key 		VARCHAR(50),
	prd_nm 			VARCHAR(50),
	prd_cost 		INT,
	prd_line 		VARCHAR(50),
	prd_start_dt 	timestamp,
	prd_end_dt		timestamp
);


DROP TABLE IF EXISTS bronze.crm_sales_details;

create table bronze.crm_sales_details (
	sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);

DROP TABLE IF EXISTS bronze.erp_cust_az12;

create table bronze.erp_cust_az12 (
	cid 	VARCHAR(50),
	bdate 	DATE,
	gen 	VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_loc_a101;

create table bronze.erp_loc_a101 ( 
	cid 	VARCHAR(50),
	cntry 	VARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

create table bronze.erp_px_cat_g1v2 (
	id 			VARCHAR(50),
	cat 		VARCHAR(50),
	subcat 		VARCHAR(50),
	maintenance VARCHAR(50)
);






