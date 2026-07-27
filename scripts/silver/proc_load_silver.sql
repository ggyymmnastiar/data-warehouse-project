CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$

DECLARE 
	start_time TIMESTAMP;
	end_time TIMESTAMP;
	batch_start_time TIMESTAMP;
	batch_end_time TIMESTAMP; 

BEGIN
	RAISE NOTICE '================================================';
	RAISE NOTICE 'Loading Silver Layer';
	RAISE NOTICE '================================================';

	RAISE NOTICE '------------------------------------------------';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE '------------------------------------------------';

	-- 1) LOAD CRM_CUST_INFO
	RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
	TRUNCATE TABLE silver.crm_cust_info;

	RAISE NOTICE '>> Inserting Data Into: silver.crm_cust_info';
	INSERT INTO silver.crm_cust_info (
	    cst_id,
	    cst_key,
	    cst_firstname,
	    cst_lastname,
	    cst_marital_status,
	    cst_gndr,
	    cst_create_date
	)
	
	SELECT
	    cst_id,
	    cst_key,
	    TRIM(cst_firstname),
	    TRIM(cst_lastname),
	
	    CASE
	        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
	        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
	        ELSE 'n/a'
	    END AS cst_marital_status,
	
	    CASE
	        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
	        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
	        ELSE 'n/a'
	    END AS cst_gndr,
	
	    cst_create_date
	
	FROM (
	    SELECT
	        *,
	        ROW_NUMBER() OVER (
	            PARTITION BY cst_id
	            ORDER BY cst_create_date DESC
	        ) AS flag_last
	    FROM bronze.crm_cust_info
	    WHERE cst_id IS NOT NULL
	) customer_rank
	
	WHERE flag_last = 1;
	
	-- 2) LOAD CRM_PRD_INFO
	TRUNCATE TABLE silver.crm_prd_info;
	INSERT INTO silver.crm_prd_info (
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
	)
	
	SELECT
		prd_id,
		
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
		
		SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,
		
		prd_nm,
		
		COALESCE(prd_cost, 0) AS prd_cost,
		
		CASE 
			WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
			WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
			WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
			WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line,
		
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		
		CAST(
			LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt ASC) - INTERVAL '1 day'
			AS DATE) AS prd_end_dt
		
	FROM 
		BRONZE.CRM_PRD_INFO;
	
	-- 3) LOAD CRM_SALES_DETAILS
	TRUNCATE TABLE silver.crm_sales_details;
	INSERT INTO silver.crm_sales_details (
	    sls_ord_num,
	    sls_prd_key,
	    sls_cust_id,
	    sls_order_dt,
	    sls_ship_dt,
	    sls_due_dt,
	    sls_sales,
	    sls_quantity,
	    sls_price
	)
	
	SELECT 
	    sls_ord_num,
	    sls_prd_key,
	    sls_cust_id,
	    
	    CASE 
	    	WHEN sls_order_dt <= 0 OR LENGTH(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL
	    	ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)  
	    END AS sls_order_dt,
	    	
	    CASE 
	    	WHEN sls_ship_dt <= 0 OR LENGTH(CAST(sls_ship_dt AS VARCHAR)) != 8 THEN NULL
	    	ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
	    END AS sls_ship_dt,
	    
	    CASE 
	    	WHEN sls_due_dt <= 0 OR LENGTH(CAST(sls_due_dt AS VARCHAR)) != 8 THEN NULL
	    	ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
	    END AS sls_due_dt,
	
	    CASE 
	    	WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price)
	    	ELSE sls_sales
	    END AS sls_sales,
	    
	    sls_quantity,
	    
	    CASE 
	    	WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
	    	ELSE sls_price
	    END AS sls_price
	    
	FROM 
		bronze.CRM_SALES_DETAILS; 
	
	-- 4) LOAD ERP_CUST_AZ12
	TRUNCATE TABLE SILVER.ERP_CUST_AZ12;
	INSERT INTO SILVER.ERP_CUST_AZ12 (
		cid,
	    bdate,
	    gen	
	) 
	
	SELECT
		CASE 
			WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
			ELSE cid
		END AS cid,
		
		CASE 
			WHEN bdate > CURRENT_DATE THEN NULL
			ELSE bdate
		END AS bdate,
		
		CASE 
			WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'    
			WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
			ELSE 'n/a'
		END AS gen
	FROM 
		BRONZE.ERP_CUST_AZ12;
	
	
	-- 5) Load ERP_LOC_A101
	TRUNCATE TABLE SILVER.ERP_LOC_A101;	
	INSERT INTO SILVER.ERP_LOC_A101 (
		cid,
		cntry
	)
	SELECT  
		REPLACE(cid, '-', '') AS cid,
		CASE
			WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
			WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'n/a'
			ELSE TRIM(cntry)
		END AS cntry	
		
	FROM 
		BRONZE.ERP_LOC_A101;		
	
	
	-- 6) Load ERP_PX_CAT_G1V2
	TRUNCATE TABLE SILVER.ERP_PX_CAT_G1V2; 
	INSERT INTO SILVER.ERP_PX_CAT_G1V2 (
		id, 				
	    cat, 			
	    subcat, 			
	    maintenance
	)
	
	SELECT 	
		id, 				
	    cat, 			
	    subcat, 			
	    maintenance
	FROM
		BRONZE.ERP_PX_CAT_G1V2;
	
END;
$$;