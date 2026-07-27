/*
 =============================================================
 DDL Script: Create Silver Tables
 =============================================================
 Script Purpose:
 This script creates tables in the 'silver' schema,
 representing the cleansed and standardized layer of
 the data warehouse.
 
 These tables store cleaned, validated, and standardized
 data after transformation from the Bronze layer.
 
 Run this script on the 'datawarehouse' database.
 =============================================================
 */
-- =============================================================
-- SOURCE: CRM (Customer Relationship Management)
-- =============================================================
-- Drop and recreate table: silver.crm_cust_info
-- Source: bronze.crm_cust_info
-- Contains cleaned customer master data
DROP TABLE IF EXISTS silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_marital_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);
-- Drop and recreate table: silver.crm_prd_info
-- Source: bronze.crm_prd_info
-- Contains cleaned product master data
DROP TABLE IF EXISTS silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt TIMESTAMP,
    prd_end_dt TIMESTAMP
);
-- Drop and recreate table: silver.crm_sales_details
-- Source: bronze.crm_sales_details
-- Contains cleaned sales transaction data
DROP TABLE IF EXISTS silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details (
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);
-- =============================================================
-- SOURCE: ERP (Enterprise Resource Planning)
-- =============================================================
-- Drop and recreate table: silver.erp_cust_az12
-- Source: bronze.erp_cust_az12
-- Contains cleaned customer demographic data
DROP TABLE IF EXISTS silver.erp_cust_az12;
CREATE TABLE silver.erp_cust_az12 (
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);
-- Drop and recreate table: silver.erp_loc_a101
-- Source: bronze.erp_loc_a101
-- Contains cleaned customer location data
DROP TABLE IF EXISTS silver.erp_loc_a101;
CREATE TABLE silver.erp_loc_a101 (
    cid VARCHAR(50),
    cntry VARCHAR(50)
);
-- Drop and recreate table: silver.erp_px_cat_g1v2
-- Source: bronze.erp_px_cat_g1v2
-- Contains cleaned product category data
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;
CREATE TABLE silver.erp_px_cat_g1v2 (
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);