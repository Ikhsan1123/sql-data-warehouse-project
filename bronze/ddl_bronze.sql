create or replace  procedure load_bronze()
language plpgsql
as $$ 
DECLARE

    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
	v_batch_start TIMESTAMP;  -- добавить
    v_batch_end TIMESTAMP;    -- добавить
begin 
	v_batch_start := CLOCK_TIMESTAMP();

	RAISE NOTICE '=======================================';
	RAISE NOTICE 'Loading Bronze Layer';
	RAISE NOTICE '=============================================';

	RAISE NOTICE '--------------------------------------------';
	RAISE NOTICE 'Loading CRM Tables';
	RAISE NOTICE '--------------------------------------------';


	v_start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
	TRUNCATE table bronze.crm_cust_info;

	RAISE NOTICE '>> Inserting Data: bronze.crm_cust_info';
	COPY bronze.crm_cust_info
	FROM 'C:\project dwh\datasets\source_crm\cust_info.csv'
	DELIMITER ','
	CSV HEADER;
	v_end_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT (EPOCH FROM (v_end_time - v_start_time  ));


	v_start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';	
	truncate table bronze.crm_prd_info;

	RAISE NOTICE '>> Inserting Data: bronze.crm_cust_info';
	COPY bronze.crm_prd_info
	FROM 'C:\project dwh\datasets\source_crm\prd_info.csv'
	DELIMITER ','
	CSV HEADER;
	v_end_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT (EPOCH FROM (v_end_time - v_start_time  ));



	v_start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
	truncate table bronze.crm_sales_details;

	RAISE NOTICE '>> Inserting Data: bronze.crm_sales_details';
	COPY bronze.crm_sales_details
	FROM 'C:\project dwh\datasets\source_crm\sales_details.csv'
	DELIMITER ','
	CSV HEADER;
	v_end_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT (EPOCH FROM (v_end_time - v_start_time  ));



	RAISE NOTICE '=======================================';
	RAISE NOTICE 'Loading Bronze Layer';
	RAISE NOTICE '=============================================';

	RAISE NOTICE '--------------------------------------------';
	RAISE NOTICE 'Loading ERP Tables';
	RAISE NOTICE '--------------------------------------------';	
	


	v_start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Truncating Table: bronze.erp_CUST_AZ12';
	truncate table bronze.erp_CUST_AZ12;

	RAISE NOTICE '>> Inserting Data: bronze.crm_CUST_AZ12';
	COPY bronze.erp_CUST_AZ12
	FROM 'C:\project dwh\datasets\source_erp\CUST_AZ12.csv'
	DELIMITER ','
	CSV HEADER; 
	v_end_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT (EPOCH FROM (v_end_time - v_start_time  ));


	v_start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Truncating Table: bronze.erp_LOC_A101';
	truncate table bronze.erp_LOC_A101;

	RAISE NOTICE '>> Inserting Data: bronze.erp_LOC_A101';
	COPY bronze.erp_LOC_A101
	FROM 'C:\project dwh\datasets\source_erp\LOC_A101.csv'
	DELIMITER ','
	CSV HEADER; 
	v_end_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT (EPOCH FROM (v_end_time - v_start_time  ));


	v_start_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Truncating Table: bronze.erp_PX_CAT_G1V2';
	truncate table bronze.erp_PX_CAT_G1V2;

	RAISE NOTICE '>> Inserting Data: bronze.erp_PX_CAT_G1V2';
	copy bronze.erp_PX_CAT_G1V2
	from 'C:\project dwh\datasets\source_erp\PX_CAT_G1V2.csv'
	delimiter ','
	csv header;
	v_end_time := CLOCK_TIMESTAMP();
	RAISE NOTICE '>> Load Duration: % seconds', EXTRACT (EPOCH FROM (v_end_time - v_start_time  ));

	v_batch_end := CLOCK_TIMESTAMP();
	RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer is Completed';
    RAISE NOTICE 'Total Load Duration: % seconds', EXTRACT(EPOCH FROM (v_batch_end - v_batch_start));
    RAISE NOTICE '================================================';

	EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '================================================';
        RAISE NOTICE 'ERROR DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'Error: %', SQLERRM;
        RAISE NOTICE '================================================';
end;
$$;

call bronze.load_bronze()
