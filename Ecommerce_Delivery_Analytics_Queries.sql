CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;
show tables;
select * from customers;
SELECT COUNT(*) FROM customers;
desc  customers;

SELECT
    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(DISTINCT CASE
        WHEN LOWER(TRIM(order_status)) = 'delivered'
        THEN order_id
    END) AS delivered_orders,

    SUM(CASE
        WHEN LOWER(TRIM(order_status)) = 'delivered'
        THEN quantity * unit_price_usd - IFNULL(discount_usd, 0)
        ELSE 0
    END) AS delivered_sales

FROM customers;
SELECT
    MONTHNAME(STR_TO_DATE(order_date, '%d-%m-%Y')) AS sales_month,
    MONTH(STR_TO_DATE(order_date, '%d-%m-%Y')) AS month_number,
    SUM(quantity * unit_price_usd - IFNULL(discount_usd, 0)) AS monthly_sales
FROM customers
WHERE LOWER(TRIM(order_status)) = 'delivered'
GROUP BY sales_month, month_number
ORDER BY month_number;
SELECT
    product_category,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_quantity,
    SUM(quantity * unit_price_usd - IFNULL(discount_usd, 0)) AS total_sales
FROM customers
WHERE LOWER(TRIM(order_status)) = 'delivered'
GROUP BY product_category
ORDER BY total_sales DESC;
SELECT
    customer_region,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(quantity) AS total_quantity,
    SUM(quantity * unit_price_usd - IFNULL(discount_usd, 0)) AS total_sales
FROM customers
WHERE LOWER(TRIM(order_status)) = 'delivered'
GROUP BY customer_region
ORDER BY total_sales DESC;
SELECT
    order_id,
    delivery_partner,
    promised_delivery_date,
    actual_delivery_date,
    DATEDIFF(
        STR_TO_DATE(actual_delivery_date, '%d-%m-%Y'),
        STR_TO_DATE(promised_delivery_date, '%d-%m-%Y')
    ) AS delay_days
FROM customers
WHERE order_status = 'Delivered'
AND actual_delivery_date IS NOT NULL
AND promised_delivery_date IS NOT NULL
AND STR_TO_DATE(actual_delivery_date, '%d-%m-%Y')
    > STR_TO_DATE(promised_delivery_date, '%d-%m-%Y')
ORDER BY delay_days DESC;
SELECT
    product_category,
    COUNT(review_score) AS total_reviews,
    ROUND(AVG(CAST(review_score AS DECIMAL(3,1))), 2)
        AS average_rating
FROM customers
WHERE review_score IS NOT NULL
AND TRIM(review_score) <> ''
GROUP BY product_category
ORDER BY average_rating DESC;
SELECT
    CASE
        WHEN DATEDIFF(
            STR_TO_DATE(actual_delivery_date, '%d-%m-%Y'),
            STR_TO_DATE(promised_delivery_date, '%d-%m-%Y')
        ) > 0 THEN 'Delayed'
        ELSE 'On Time'
    END AS delivery_status,

    COUNT(review_score) AS total_reviews,

    ROUND(AVG(CAST(review_score AS DECIMAL(3,1))), 2)
        AS average_rating

FROM customers
WHERE order_status = 'Delivered'
AND review_score IS NOT NULL
AND TRIM(review_score) <> ''
AND STR_TO_DATE(actual_delivery_date, '%d-%m-%Y') IS NOT NULL
AND STR_TO_DATE(promised_delivery_date, '%d-%m-%Y') IS NOT NULL

GROUP BY delivery_status;
