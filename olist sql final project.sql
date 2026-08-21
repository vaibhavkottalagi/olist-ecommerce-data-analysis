CREATE DATABASE IF NOT EXISTS olist_ecommerce_clean;
USE olist_ecommerce_clean;
SET GLOBAL local_infile = 1;

DROP TABLE IF EXISTS olist_orders, olist_order_payments, olist_order_items, olist_order_reviews;

-- Create staging tables using plain text columns to accept any formatting
CREATE TABLE olist_orders (
    order_id VARCHAR(255),
    customer_id VARCHAR(255),
    order_status VARCHAR(255),
    order_purchase_timestamp VARCHAR(255),
    order_approved_at VARCHAR(255),
    order_delivered_carrier_date VARCHAR(255),
    order_delivered_customer_date VARCHAR(255),
    order_estimated_delivery_date VARCHAR(255)
);

CREATE TABLE olist_order_payments (
    order_id VARCHAR(255),
    payment_sequential VARCHAR(255),
    payment_type VARCHAR(255),
    payment_installments VARCHAR(255),
    payment_value VARCHAR(255)
);

CREATE TABLE olist_order_items (
    order_id VARCHAR(255),
    order_item_id VARCHAR(255),
    product_id VARCHAR(255),
    seller_id VARCHAR(255),
    shipping_limit_date VARCHAR(255),
    price VARCHAR(255),
    freight_value VARCHAR(255)
);

CREATE TABLE olist_order_reviews (
    review_id VARCHAR(255),
    order_id VARCHAR(255),
    review_score VARCHAR(255),
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date VARCHAR(255),
    review_answer_timestamp VARCHAR(255)
);

-- Load CSV data without line-ending restrictions
LOAD DATA LOCAL INFILE 'D:/Ecommerce Analytics2/DA_P1222 (Ecommerce Analytics)/E-Commerce/olist_orders_dataset.csv'
INTO TABLE olist_orders 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/Ecommerce Analytics2/DA_P1222 (Ecommerce Analytics)/E-Commerce/olist_order_payments_dataset.csv'
INTO TABLE olist_order_payments 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/Ecommerce Analytics2/DA_P1222 (Ecommerce Analytics)/E-Commerce/olist_order_items_dataset.csv'
INTO TABLE olist_order_items 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/Ecommerce Analytics2/DA_P1222 (Ecommerce Analytics)/E-Commerce/olist_order_reviews_dataset.csv'
INTO TABLE olist_order_reviews 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES;

-- 1. Total Revenue
SELECT ROUND(SUM(CAST(payment_value AS DECIMAL(10,2))), 2) AS Total_Revenue 
FROM olist_order_payments 
WHERE payment_value REGEXP '^[0-9]+(\.[0-9]+)?$';

-- 2. Total Orders Count
SELECT COUNT(DISTINCT order_id) AS Total_Orders 
FROM olist_orders 
WHERE order_id IS NOT NULL AND order_id != '';

-- 3. Average Order Value (AOV)
SELECT ROUND(AVG(CAST(payment_value AS DECIMAL(10,2))), 2) AS Average_Order_Value 
FROM olist_order_payments 
WHERE payment_value REGEXP '^[0-9]+(\.[0-9]+)?$';

-- 4. Average Review Score
SELECT ROUND(AVG(CAST(review_score AS DECIMAL(10,2))), 2) AS Avg_Review_Score 
FROM olist_order_reviews 
WHERE review_score REGEXP '^[0-9]+$';

-- 5. Revenue by Payment Method
SELECT 
    TRIM(payment_type) AS Payment_Method, 
    COUNT(order_id) AS Total_Transactions,
    ROUND(SUM(CAST(payment_value AS DECIMAL(10,2))), 2) AS Total_Revenue
FROM olist_order_payments
WHERE payment_value REGEXP '^[0-9]+(\.[0-9]+)?$'
GROUP BY TRIM(payment_type)
ORDER BY Total_Revenue DESC;

USE olist_ecommerce_clean;

-- KPI 6: Weekday vs. Weekend Sales Breakdown
SELECT 
    CASE 
        WHEN DAYOFWEEK(STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) IN (1, 7) THEN 'Weekend'
        WHEN DAYOFWEEK(STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) BETWEEN 2 AND 6 THEN 'Weekday'
        ELSE 'Unknown'
    END AS Day_Type,
    COUNT(DISTINCT o.order_id) AS Total_Orders,
    ROUND(SUM(CAST(p.payment_value AS DECIMAL(10,2))), 2) AS Total_Revenue,
    ROUND(AVG(CAST(p.payment_value AS DECIMAL(10,2))), 2) AS Average_Order_Value
FROM olist_orders o
JOIN olist_order_payments p ON o.order_id = p.order_id
WHERE p.payment_value REGEXP '^[0-9]+(\.[0-9]+)?$'
GROUP BY Day_Type
ORDER BY Total_Revenue DESC;

USE olist_ecommerce_clean;

-- ============================================================================
-- KPI 7: Orders with Review Score 5 & Paid via Credit Card
-- EXPLANATION: Shows customer satisfaction for our main payment method by 
-- counting unique orders that received a 5-star rating AND were paid using a Credit Card.
-- ============================================================================
SELECT COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_orders o
JOIN olist_order_payments p ON o.order_id = p.order_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE CAST(r.review_score AS UNSIGNED) = 5
  AND LOWER(TRIM(p.payment_type)) = 'credit_card';


-- ============================================================================
-- KPI 8: Average Delivery Days for 'pet_shop' Category
-- EXPLANATION: Measures logistics performance for pet product orders by calculating 
-- the average number of days between order purchase timestamp and actual customer delivery date.
-- ============================================================================
USE olist_ecommerce_clean;

-- 1. Drop existing tables if incomplete
DROP TABLE IF EXISTS olist_products, olist_customers;

-- 2. Re-create tables with safe text structures
CREATE TABLE olist_products (
    product_id VARCHAR(255),
    product_category_name VARCHAR(255),
    product_name_lenght VARCHAR(255),
    product_description_lenght VARCHAR(255),
    product_photos_qty VARCHAR(255),
    product_weight_g VARCHAR(255),
    product_length_cm VARCHAR(255),
    product_height_cm VARCHAR(255),
    product_width_cm VARCHAR(255)
);

CREATE TABLE olist_customers (
    customer_id VARCHAR(255),
    customer_unique_id VARCHAR(255),
    customer_zip_code_prefix VARCHAR(255),
    customer_city VARCHAR(255),
    customer_state VARCHAR(255)
);

-- 3. Load CSV files without strict formatting locks
LOAD DATA LOCAL INFILE 'D:/Ecommerce Analytics2/DA_P1222 (Ecommerce Analytics)/E-Commerce/olist_products_dataset.csv'
INTO TABLE olist_products 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/Ecommerce Analytics2/DA_P1222 (Ecommerce Analytics)/E-Commerce/olist_customers_dataset.csv'
INTO TABLE olist_customers 
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
IGNORE 1 LINES;


-- ============================================================================
-- KPI 8: Average Delivery Days for 'pet_shop' Category
-- EXPLANATION: Measures logistics performance for pet product orders by calculating 
-- the average number of days between order purchase timestamp and actual customer delivery date.
-- ============================================================================
USE olist_ecommerce_clean;

-- Increase timeout limit for this session
SET SESSION max_execution_time = 60000;

SELECT 
    ROUND(AVG(
        DATEDIFF(
            CAST(o.order_delivered_customer_date AS DATETIME),
            CAST(o.order_purchase_timestamp AS DATETIME)
        )
    ), 2) AS avg_delivery_days
FROM olist_orders o
INNER JOIN olist_order_items i ON o.order_id = i.order_id
INNER JOIN olist_products pr ON i.product_id = pr.product_id
WHERE pr.product_category_name = 'pet_shop'
  AND o.order_delivered_customer_date IS NOT NULL 
  AND o.order_delivered_customer_date != '';
  
  
  
-- ============================================================================
-- KPI 9: Average Price and Payment Value in São Paulo
-- EXPLANATION: Evaluates purchasing power in our top geographic market (São Paulo) 
-- by calculating the average product price and average final checkout transaction value.
-- ============================================================================
SELECT 
    ROUND(AVG(CAST(i.price AS DECIMAL(10,2))), 2) AS avg_item_price,
    ROUND(AVG(CAST(p.payment_value AS DECIMAL(10,2))), 2) AS avg_payment_value
FROM olist_orders o
JOIN olist_customers c ON TRIM(o.customer_id) = TRIM(c.customer_id)
JOIN olist_order_items i ON TRIM(o.order_id) = TRIM(i.order_id)
JOIN olist_order_payments p ON TRIM(o.order_id) = TRIM(p.order_id)
WHERE LOWER(TRIM(c.customer_city)) = 'sao paulo'
  AND i.price REGEXP '^[0-9]+(\.[0-9]+)?$'
  AND p.payment_value REGEXP '^[0-9]+(\.[0-9]+)?$';
-- ============================================================================
-- KPI 10: Relationship Between Shipping Days vs. Review Scores
-- EXPLANATION: Analyzes how delivery speed impacts customer satisfaction by 
-- grouping review ratings (1 to 5 stars) against the average shipping time in days.
-- ============================================================================
SELECT 
    CAST(r.review_score AS UNSIGNED) AS review_score,
    ROUND(AVG(DATEDIFF(
        STR_TO_DATE(o.order_delivered_customer_date, '%Y-%m-%d %H:%i:%s'),
        STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')
    )), 2) AS avg_shipping_days
FROM olist_orders o
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND r.review_score REGEXP '^[0-9]+$'
GROUP BY CAST(r.review_score AS UNSIGNED)
ORDER BY review_score DESC;