create or replace procedure bronze.load_bronze()
language plpgsql
as $$

DECLARE 
	start_time TIMESTAMP;
	end_time TIMESTAMP;
	batch_start_time TIMESTAMP;
	batch_end_time TIMESTAMP; 

BEGIN
	batch_start_time := clock_timestamp();
	RAISE NOTICE '================================================';
	RAISE NOTICE 'Loading Bronze Layer';
	RAISE NOTICE '================================================';

	RAISE NOTICE '------------------------------------------------';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE '------------------------------------------------';

	
	start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
	-- 1) bronze.crm_cust_info --
	truncate table bronze.crm_cust_info;
	
	RAISE NOTICE '>> Inserting Data Into: bronze.crm_cust_info';
	copy bronze.crm_cust_info
	from '/Users/g/Desktop/Documents/ProjectDE/data-warehouse-project/datasets/source_crm/cust_info.csv'
	delimiter ','
	csv header;

	end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
	RAISE NOTICE '------------------------------------------------';


	start_time := clock_timestamp();	

	RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
	-- 2) bronze.crm_prd_info --
	truncate table bronze.crm_prd_info;
	
	RAISE NOTICE '>> Inserting Data Into: bronze.crm_prd_info';
	copy bronze.crm_prd_info
	from '/Users/g/Desktop/Documents/ProjectDE/data-warehouse-project/datasets/source_crm/prd_info.csv'
	delimiter ','
	csv header;

	end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
	RAISE NOTICE '------------------------------------------------';

	
	start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
	-- 3) bronze.crm_sales_details --
	truncate table bronze.crm_sales_details;
	
	RAISE NOTICE '>> Inserting Data Into: bronze.crm_sales_details';
	copy bronze.crm_sales_details
	from '/Users/g/Desktop/Documents/ProjectDE/data-warehouse-project/datasets/source_crm/sales_details.csv'
	delimiter ','
	csv header;

	end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
	RAISE NOTICE '------------------------------------------------';

	
	RAISE NOTICE '------------------------------------------------';
	RAISE NOTICE 'Loading ERP Tables';
	RAISE NOTICE '------------------------------------------------';


	start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.erp_cust_az12';
	-- 4) bronze.erp_cust_az12 --
	truncate table bronze.erp_cust_az12;
	
	RAISE NOTICE '>> Inserting Data Into: bronze.erp_cust_az12';
	copy bronze.erp_cust_az12
	from '/Users/g/Desktop/Documents/ProjectDE/data-warehouse-project/datasets/source_erp/cust_az12.csv'
	delimiter ','
	csv header;

	end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
	RAISE NOTICE '------------------------------------------------';


	start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.erp_loc_a101';
	-- 5) bronze.erp_loc_a101 --
	truncate table bronze.erp_loc_a101;
	
	RAISE NOTICE '>> Inserting Data Into: bronze.erp_loc_a101';
	copy bronze.erp_loc_a101
	from '/Users/g/Desktop/Documents/ProjectDE/data-warehouse-project/datasets/source_erp/loc_a101.csv'
	delimiter ','
	csv header;

	end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
	RAISE NOTICE '------------------------------------------------';

	
	start_time := clock_timestamp();

	RAISE NOTICE '>> Truncating Table: bronze.erp_px_cat_g1v2';
	-- 6) bronze.erp_px_cat_g1v2 --
	truncate table bronze.erp_px_cat_g1v2;
	
	RAISE NOTICE '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
	copy bronze.erp_px_cat_g1v2
	from '/Users/g/Desktop/Documents/ProjectDE/data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv'
	delimiter ','
	csv header;

	end_time := clock_timestamp();
	RAISE NOTICE 'Load Duration: % seconds', ROUND(EXTRACT(EPOCH FROM end_time - start_time), 2);
	RAISE NOTICE '------------------------------------------------';

	batch_end_time := clock_timestamp();
	RAISE NOTICE '================================================';
	RAISE NOTICE 'Loading Bronze Layer Completed';
	RAISE NOTICE 'Total Batch Duration: % seconds', ROUND(EXTRACT(EPOCH FROM batch_end_time - batch_start_time), 2);
	RAISE NOTICE '================================================';

	
EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE '================================================';
		RAISE NOTICE 'Bronze Loading Failed';
		RAISE NOTICE 'Error: %', SQLERRM;
		RAISE NOTICE '================================================';
END;
$$;