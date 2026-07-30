CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    v_start_time TIMESTAMP;
    v_end_time TIMESTAMP;
    v_batch_start TIMESTAMP;
    v_batch_end TIMESTAMP;
BEGIN
    v_batch_start := CLOCK_TIMESTAMP();

    RAISE NOTICE '================================================';
    RAISE NOTICE 'Loading Bronze Layer';
    RAISE NOTICE '================================================';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';

    v_start_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    RAISE NOTICE '>> Inserting Data: bronze.crm_cust_info';
    COPY bronze.crm_cust_info
    FROM 'C:\project dwh\datasets\source_crm\cust_info.csv'
    DELIMITER ',' CSV HEADER;
    v_end_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    v_start_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    RAISE NOTICE '>> Inserting Data: bronze.crm_prd_info';
    COPY bronze.crm_prd_info
    FROM 'C:\project dwh\datasets\source_crm\prd_info.csv'
    DELIMITER ',' CSV HEADER;
    v_end_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    v_start_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    RAISE NOTICE '>> Inserting Data: bronze.crm_sales_details';
    COPY bronze.crm_sales_details
    FROM 'C:\project dwh\datasets\source_crm\sales_details.csv'
    DELIMITER ',' CSV HEADER;
    v_end_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

    v_start_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Truncating Table: bronze.erp_CUST_AZ12';
    TRUNCATE TABLE bronze.erp_CUST_AZ12;
    RAISE NOTICE '>> Inserting Data: bronze.erp_CUST_AZ12';
    COPY bronze.erp_CUST_AZ12
    FROM 'C:\project dwh\datasets\source_erp\CUST_AZ12.csv'
    DELIMITER ',' CSV HEADER;
    v_end_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    v_start_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Truncating Table: bronze.erp_LOC_A101';
    TRUNCATE TABLE bronze.erp_LOC_A101;
    RAISE NOTICE '>> Inserting Data: bronze.erp_LOC_A101';
    COPY bronze.erp_LOC_A101
    FROM 'C:\project dwh\datasets\source_erp\LOC_A101.csv'
    DELIMITER ',' CSV HEADER;
    v_end_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    v_start_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Truncating Table: bronze.erp_PX_CAT_G1V2';
    TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;
    RAISE NOTICE '>> Inserting Data: bronze.erp_PX_CAT_G1V2';
    COPY bronze.erp_PX_CAT_G1V2
    FROM 'C:\project dwh\datasets\source_erp\PX_CAT_G1V2.csv'
    DELIMITER ',' CSV HEADER;
    v_end_time := CLOCK_TIMESTAMP();
    RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

    v_batch_end := CLOCK_TIMESTAMP();
    RAISE NOTICE '================================================';
    RAISE NOTICE 'Bronze Layer Loaded Successfully';
    RAISE NOTICE 'Total Duration: % seconds', EXTRACT(EPOCH FROM (v_batch_end - v_batch_start));
    RAISE NOTICE '================================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '================================================';
        RAISE NOTICE 'ERROR DURING LOADING BRONZE LAYER';
        RAISE NOTICE 'Error: %', SQLERRM;
        RAISE NOTICE '================================================';
END;
$$;

CALL bronze.load_bronze();
