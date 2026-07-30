CREATE OR REPLACE PROCEDURE silver.load_silver()
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
    RAISE NOTICE 'Loading SILVER Layer';
    RAISE NOTICE '================================================';

    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading CRM Tables';
    RAISE NOTICE '------------------------------------------------';
 v_start_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Truncating Table: silver.crm_cust_info';
truncate table silver.crm_cust_info;
RAISE NOTICE '>> Inserting Data INTO: silver.crm_cust_info';
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_material_status,
    cst_gndr,
    cst_create_date
)

select 
cst_id,
cst_key,
trim(cst_firstname) as cst_first_name,
trim(cst_lastname) as cst_last_name,
case when UPPER(TRIM(cst_material_status))= 'S' then 'Single'
	 when UPPER(TRIM (cst_material_status))= 'M' then 'Married'
else 'n/a'
end cst_material_status,
case when UPPER(TRIM(cst_gndr))= 'F' then 'Female'
	 when UPPER(TRIM (cst_gndr))= 'M' then 'Male'
else 'n/a'
end cst_gndr,
cst_create_date
from (
select *,
row_number () over(partition by cst_id order by cst_create_date desc) as  flag_last
from bronze.crm_cust_info 
where cst_id is not null
) t where flag_last=1 ;
v_end_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));



v_start_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Truncating Table: silver.crm_prd_info';
truncate table silver.crm_prd_info;
RAISE NOTICE '>> Inserting Data INTO: silver.crm_prd_info';
insert into silver.crm_prd_info (
	prd_id,
    cat_id,
    prd_key ,
    prd_nm ,
    prd_cost ,
    prd_line ,
    prd_start_dt ,
    prd_end_dt 
)
SELECT
    prd_id,
    replace(SUBSTRING(prd_key, 1, 5),'-','_') as cat_id,
    SUBSTRING(prd_key,7,LENGTH(prd_key)) as prd_key,
    prd_nm,
    coalesce(prd_cost,0) as prd_cost,
    case when UPPER(TRIM(prd_line))='M' then 'Mountain'
    	 when upper (TRIM(prd_line))='R'then 'Road'
    	 when upper(TRIM(prd_line))='S' then ' other Sales'
   		 when upper(TRIM(prd_line))= 'T' then 'Touring'
   		 else 'n/a'
    end as prd_line,
    cast(prd_start_dt as DATE ) as prd_start_dt,
    cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt_test
FROM bronze.crm_prd_info;
v_end_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));



v_start_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Truncating Table: silver.crm_sales_details';
truncate table silver.crm_sales_details;
RAISE NOTICE '>> Inserting Data INTO: silver.crm_sales_details';
insert into silver.crm_sales_details (
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
select 
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE 
    WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS VARCHAR)) != 8 THEN NULL
    ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
END as sls_order_dt,
CASE 
    WHEN sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS VARCHAR)) != 8 THEN NULL
    ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
END as sls_ship_dt,
CASE 
    WHEN sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS VARCHAR)) != 8 THEN NULL
    ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
END as sls_due_dt,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 or sls_sales != sls_quantity  * abs(sls_price)
    	then sls_quantity * abs(sls_price)
    	else sls_sales
    end as sls_sales,
sls_quantity,
   	  	CASE WHEN sls_price IS NULL OR sls_price <= 0  
   	    then sls_sales / NULLIF(sls_quantity,0)
    	else sls_price
    end as sls_price
FROM bronze.crm_sales_details;
v_end_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));



    RAISE NOTICE '------------------------------------------------';
    RAISE NOTICE 'Loading ERP Tables';
    RAISE NOTICE '------------------------------------------------';

v_start_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Truncating Table: silver.erp_px_cat_g1v2';
truncate table silver.erp_px_cat_g1v2;
RAISE NOTICE '>> Inserting Data INTO: silver.erp_px_cat_g1v2';
insert into silver.erp_px_cat_g1v2   (
id,
cat,
subcat,
maintenance)
select
id,
cat,
subcat,
maintenance
from bronze.erp_px_cat_g1v2 ;
v_end_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));



v_start_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Truncating Table: silver.erp_loc_a101';
truncate table silver.erp_loc_a101;
RAISE NOTICE '>> Inserting Data INTO: silver.erp_loc_a101';
insert into silver.erp_loc_a101
(cid, cntry)
select 
replace (cid,'-','') cid,
case when TRIM (cntry) = 'DE' then 'Germany'
	 when TRIM(cntry) in ('US','USA') then 'United States'
	 when TRIM(cntry)='' or cntry is null then 'n/a'
	 else trim(cntry)
end as cntry
from bronze.erp_loc_a101;
v_end_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));




v_start_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Truncating Table: silver.erp_cust_az12';
truncate table silver.erp_cust_az12;
RAISE NOTICE '>> Inserting Data INTO: silver.erp_cust_az12';
insert into silver.erp_cust_az12 (cid,bdate,gen)
select
case when cid like 'NAS%' then substring(cid,4,length(cid))
	 else cid
end as cid,
case when bdate > CURRENT_TIMESTAMP then null
	 else bdate
end as bdate,
case when UPPER(trim(gen)) in ('F','FEMALE') then 'Female'
	 when UPPER(trim(gen)) in ('M','MALE') then 'Male'
	 else 'n/a'
end as gen
from bronze.erp_cust_az12;
v_end_time := CLOCK_TIMESTAMP();
RAISE NOTICE '>> Load Duration: % seconds', EXTRACT(EPOCH FROM (v_end_time - v_start_time));

v_batch_end := CLOCK_TIMESTAMP();
RAISE NOTICE '================================================';
RAISE NOTICE 'Silver  Layer Loaded Successfully';
RAISE NOTICE 'Total Duration: % seconds', EXTRACT(EPOCH FROM (v_batch_end - v_batch_start));
RAISE NOTICE '================================================';

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '================================================';
        RAISE NOTICE 'ERROR DURING LOADING SILVER  LAYER';
        RAISE NOTICE 'Error: %', SQLERRM;
        RAISE NOTICE '================================================';

END; $$;



call silver.load_silver()
