/*
================================================================================
Silver Layer Data Quality Checks
================================================================================
Purpose:
    This script performs data quality checks on the Silver Layer tables
    after the Bronze -> Silver transformation.

Tables Tested:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat_g1v2

Expectation:
    Queries marked with "Expectation: No result" should return zero rows.
================================================================================
*/


/*
================================================================================
1. CRM CUSTOMER INFORMATION
================================================================================
*/

SELECT *
FROM silver.crm_cust_info;


-- Check primary keys: Unique and Not Nulls
-- Expectation: No result

SELECT 
    cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 
    OR cst_id IS NULL;


-- Check unwanted spaces
-- Expectation: No result

SELECT 
    cst_firstname,
    cst_lastname,
    cst_gndr
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname)
   OR cst_gndr != TRIM(cst_gndr);


-- Data standardization and consistency
-- In this data warehouse, we focus on creating and storing meaningful
-- values instead of abbreviated values.

SELECT DISTINCT 
    cst_gndr
FROM silver.crm_cust_info;


SELECT DISTINCT 
    cst_marital_status
FROM silver.crm_cust_info;


-- Check gender for unexpected values
-- Expectation: No result

SELECT DISTINCT
    cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Male', 'Female', 'n/a');


-- Check marital status for unexpected values
-- Expectation: No result

SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status NOT IN ('Single', 'Married', 'n/a');



/*
================================================================================
2. CRM PRODUCT INFORMATION
================================================================================
*/

SELECT *
FROM silver.crm_prd_info;


-- Check primary keys: Unique and Not Nulls
-- Expectation: No result

SELECT 
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 
    OR prd_id IS NULL;


-- Check unwanted spaces
-- Expectation: No result

SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- Check for NULL or negative product cost
-- Expectation: No result

SELECT 
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 
   OR prd_cost IS NULL;


-- Data standardization and consistency

SELECT DISTINCT 
    prd_line
FROM silver.crm_prd_info;


-- Check product line for unexpected values
-- Expectation: No result

SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info
WHERE prd_line NOT IN
(
    'Mountain',
    'Road',
    'Other Sales',
    'Touring',
    'n/a'
);


-- Check category ID

SELECT DISTINCT
    cat_id
FROM silver.crm_prd_info;


-- Check product key

SELECT DISTINCT
    prd_key
FROM silver.crm_prd_info;


-- Check for invalid product key format
-- Product key should not contain the category prefix
-- Expectation: No result

SELECT
    prd_key
FROM silver.crm_prd_info
WHERE prd_key LIKE '%-%';


-- Check for invalid product dates
-- End date must not be earlier than start date
-- Expectation: No result

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;



/*
================================================================================
3. CRM SALES DETAILS
================================================================================
*/

SELECT *
FROM silver.crm_sales_details;


-- Check sales order number for NULL values
-- Expectation: No result

SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL;


-- Check product key for NULL values
-- Expectation: No result

SELECT *
FROM silver.crm_sales_details
WHERE sls_prd_key IS NULL;


-- Check customer ID for NULL values
-- Expectation: No result

SELECT *
FROM silver.crm_sales_details
WHERE sls_cust_id IS NULL;


-- Check sales quantity
-- Quantity must not be NULL, zero, or negative
-- Expectation: No result

SELECT *
FROM silver.crm_sales_details
WHERE sls_quantity IS NULL
   OR sls_quantity <= 0;


-- Check sales price
-- Price must not be NULL, zero, or negative
-- Expectation: No result

SELECT *
FROM silver.crm_sales_details
WHERE sls_price IS NULL
   OR sls_price <= 0;


-- Check sales amount
-- Sales must not be NULL, zero, or negative
-- Expectation: No result

SELECT *
FROM silver.crm_sales_details
WHERE sls_sales IS NULL
   OR sls_sales <= 0;


-- Check data consistency between sales, quantity, and price
-- sales = quantity * price
-- Expectation: No result

SELECT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;


-- Check order date
-- Order date should not be later than ship date
-- Expectation: No result

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt;


-- Check ship date
-- Ship date should not be later than due date
-- Expectation: No result

SELECT *
FROM silver.crm_sales_details
WHERE sls_ship_dt > sls_due_dt;


-- Check date consistency
-- Order date should not be later than due date
-- Expectation: No result

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_due_dt;



/*
================================================================================
4. ERP CUSTOMER INFORMATION
================================================================================
*/

SELECT *
FROM silver.erp_cust_az12;


-- Check customer ID for NULL values
-- Expectation: No result

SELECT *
FROM silver.erp_cust_az12
WHERE cid IS NULL;


-- Check duplicate customer IDs
-- Expectation: No result

SELECT
    cid,
    COUNT(*)
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1;


-- Check that NAS prefix has been removed
-- Expectation: No result

SELECT
    cid
FROM silver.erp_cust_az12
WHERE cid LIKE 'NAS%';


-- Check birth dates
-- Birth date should not be in the future
-- Expectation: No result

SELECT *
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();


-- Data standardization and consistency

SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


-- Check gender for unexpected values
-- Expectation: No result

SELECT DISTINCT
    gen
FROM silver.erp_cust_az12
WHERE gen NOT IN ('Male', 'Female', 'n/a');



/*
================================================================================
5. ERP LOCATION INFORMATION
================================================================================
*/

SELECT *
FROM silver.erp_loc_a101;


-- Check customer ID for NULL values
-- Expectation: No result

SELECT *
FROM silver.erp_loc_a101
WHERE cid IS NULL;


-- Check duplicate customer IDs
-- Expectation: No result

SELECT
    cid,
    COUNT(*)
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1;


-- Check for unwanted hyphens in customer ID
-- Hyphens were removed during transformation
-- Expectation: No result

SELECT
    cid
FROM silver.erp_loc_a101
WHERE cid LIKE '%-%';


-- Data standardization and consistency

SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101;


-- Check country for NULL or blank values
-- Expectation: No result

SELECT *
FROM silver.erp_loc_a101
WHERE cntry IS NULL
   OR TRIM(cntry) = '';


-- Check for unexpected country values
-- Expectation: No result

SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
WHERE cntry NOT IN
(
    'Germany',
    'United States',
    'n/a'
);



/*
================================================================================
6. ERP PRODUCT CATEGORY INFORMATION
================================================================================
*/

SELECT *
FROM silver.erp_px_cat_g1v2;


-- Check ID for NULL values
-- Expectation: No result

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE id IS NULL;


-- Check duplicate IDs
-- Expectation: No result

SELECT
    id,
    COUNT(*)
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;


-- Check category values

SELECT DISTINCT
    cat
FROM silver.erp_px_cat_g1v2;


-- Check subcategory values

SELECT DISTINCT
    subcat
FROM silver.erp_px_cat_g1v2;


-- Check maintenance values

SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2;


-- Check for NULL values in category information
-- Expectation: No result

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat IS NULL
   OR subcat IS NULL
   OR maintenance IS NULL;


-- Check unwanted spaces
-- Expectation: No result

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);
