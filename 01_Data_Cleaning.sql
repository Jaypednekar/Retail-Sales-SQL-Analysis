-- PROJECT: Retail Sales Data Cleaning
-- DATABASE: project1
-- TABLES: orders, details
-- PURPOSE: Check data quality and clean the imported retail data.
-- IMPORTANT: This file records the cleaning steps in the order they were used.
-- Do not run the whole file again on an already-cleaned database.
-- In particular, the date conversion and column rename are one-time steps.
-- Check the current column type/name before running any ALTER or RENAME statement.
-- Run optional or example statements only when they apply to your database.


-- STEP 1: Download the dataset from Kaggle.
-- STEP 2: Import the CSV files into MySQL.
-- STEP 3: Data cleaning and validation.
-- 1. Check whether the records were imported correctly.
SELECT COUNT(*) AS total_orders
FROM Orders;

SELECT COUNT(*) AS total_details
FROM Details;



-- 2. Check table columns, data types, constraints, and defaults.
DESCRIBE Orders;

DESCRIBE Details;

-- 2.1 Table modifications.
-- 2.1.1 Modify a column data type or constraint.
-- Run this only when order_date contains text in DD-MM-YYYY format.
ALTER TABLE orders 
modify COLUMN  order_date varchar(50) NULL DEFAULT NULL 
;

-- 2.1.2 Convert the text date into a MySQL date value.
-- Run immediately after the VARCHAR conversion above, not on an already-cleaned DATE column.
 UPDATE orders
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y')
WHERE order_date IS NOT NULL;

-- 2.1.3 Set the final date data type and constraint.
ALTER TABLE orders
MODIFY COLUMN order_date DATE NULL DEFAULT NULL;

-- 2.2 Rename a column.
-- Run only if the source column is still named CustomerName.
ALTER TABLE orders
RENAME COLUMN CustomerName TO customer_name;

-- 2.3 Rename a table (example only).
-- Example only: run only if your actual table is named orders1.
-- RENAME TABLE orders1 TO orders;

-- 2.4 Drop a column (example only).
-- Example only: run only after confirming customer_id is unnecessary and backed up.
-- ALTER TABLE orders DROP COLUMN customer_id;

-- 2.5 Add a column (example only).
-- Example only: do not add this column unless your project requires it
-- and you have valid values for existing records.
-- ALTER TABLE orders ADD COLUMN customer_phon VARCHAR(50) NOT NULL;



-- 3. Check for NULL values.
SELECT
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(order_date IS NULL) AS missing_order_date,
    SUM(Customer_Name IS NULL) AS missing_customer,
    SUM(State IS NULL) AS missing_state,
    SUM(City IS NULL) AS missing_city
FROM Orders;

SELECT
    SUM(order_id IS NULL) AS missing_order_id,
    SUM(Amount IS NULL) AS missing_amount,
    SUM(Profit IS NULL) AS missing_profit,
    SUM(Quantity IS NULL) AS missing_quantity,
    SUM(Category IS NULL) AS missing_category,
    SUM(Sub_Category IS NULL) AS missing_sub_category,
    SUM(PayMode IS NULL) AS missing_paymode
FROM Details;


-- 4. Display rows with missing values.
SELECT *
FROM Details
WHERE Amount IS NULL;

-- 4.1 Update missing values only when the correct values are available from the source.
-- REVIEW BEFORE RUNNING:
-- Do not replace missing Amount values with 0 unless the original source confirms 0.
-- If the original source provides the correct values, update them from that source.
-- UPDATE Details
-- SET Amount = 0
-- WHERE Amount IS NULL;

-- 5. Check for duplicate records.
-- 5.1 Compare total IDs with distinct IDs to check for duplicate order IDs.
SELECT COUNT(order_id) AS total_order_ids,
       COUNT(DISTINCT order_id) AS distinct_order_ids
FROM orders;

-- 5.2 Find order IDs that appear more than once.
SELECT order_id,
    COUNT(*) AS total_count
FROM Orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- 5.3 Check duplicate detail rows using all relevant columns.
SELECT
    order_id,
    Amount,
    Profit,
    Quantity,
    Category,
    Sub_Category,
    PayMode,
    COUNT(*) AS total_count
FROM Details
GROUP BY
    order_id,
    Amount,
    Profit,
    Quantity,
    Category,
    Sub_Category,
    PayMode
HAVING COUNT(*) > 1;

-- 5.4 Back up the table before deleting any confirmed duplicate records.

-- Run this backup statement once, before making any manual deletion.
-- CREATE TABLE Orders_backup AS
-- SELECT * FROM Orders;

-- Example only: destructive DELETE statement; do not run as part of the final
-- cleaning script unless you have verified the exact record and made a backup.
-- DELETE FROM orders WHERE id = 1;

-- Check the final orders table structure.
DESCRIBE orders;

-- 6. Check whether order IDs match between the two tables.
SELECT o.order_id
FROM Orders o
LEFT JOIN Details d
    ON o.order_id = d.order_id
WHERE d.order_id IS NULL;

SELECT d.order_id
FROM Details d
LEFT JOIN Orders o
    ON d.order_id = o.order_id
WHERE o.order_id IS NULL;

-- 7. Validate dates and review values and distinct categories.
SELECT MIN(order_date) AS first_order_date,
       MAX(order_date) AS last_order_date,
       COUNT(*) AS total_rows,
       SUM(order_date IS NULL) AS missing_order_dates
FROM orders;

select order_id,order_date from orders order by order_date;

select * from details where Quantity<=0;
select * from details where amount<=0;
select count(*) from details where Profit<=0;

select distinct(city) from orders;
select count(distinct(city)) from orders;
select distinct(state) from orders;
select count(distinct(state)) from orders;
select distinct(customer_name) from orders;
select count(distinct(Customer_Name)) from orders;

select count(distinct(category)) from details order by category;
select distinct(Sub_Category) from details order by sub_category;
select distinct(category) from details order by category;
select count(distinct(sub_category)) from details order by sub_category;
select distinct(PayMode) from details order by PayMode;
select count(distinct(PayMode)) from details order by PayMode;

-- Remove leading/trailing spaces from payment-mode values, if any are present.
-- This UPDATE changes data; run it only after confirming the values contain extra spaces.
UPDATE Details
SET PayMode = TRIM(PayMode)
WHERE PayMode <> TRIM(PayMode);

/* Small TRIM() example:
SELECT TRIM('  hello world  ') AS trimmed_text;
TRIM() removes extra spaces from the beginning and end of a string.
*/


SELECT COUNT(*) AS total_orders
FROM Orders;

SELECT COUNT(*) AS total_details
FROM Details;
