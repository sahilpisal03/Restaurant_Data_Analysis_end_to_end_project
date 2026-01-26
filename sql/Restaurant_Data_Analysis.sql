-- Creating the database
CREATE DATABASE food_delivery_analytics;
GO

-- Utilizing the database
USE food_delivery_analytics;
GO

-- Creating the table
CREATE TABLE restaurant_data_cleaned(
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    category VARCHAR(50),
    item VARCHAR(100),
    price DECIMAL(10,2),
    quantity DECIMAL(10,2),
    order_total DECIMAL(10,2),
    order_date VARCHAR(50),   -- load as text first
    payment_method VARCHAR(50),
    order_hour DECIMAL(10,2),
    order_day VARCHAR(50),
    order_month VARCHAR(50)
);

-- Loading the data
BULK INSERT restaurant_data_cleaned
FROM 'C:\Users\WELCOME\OneDrive\Desktop\Food Delivery Data Analysis\data\clean\cleaned_data.csv'
WITH(
    ROWTERMINATOR = '\n',
    FIELDTERMINATOR = ',',
    FIRSTROW = 2,
    TABLOCK
);

-- Convert order_date column to DATE type (after cleaning if needed)
UPDATE restaurant_data_cleaned
SET order_date = TRY_CONVERT(DATE, order_date, 103);

ALTER TABLE restaurant_data_cleaned
ALTER COLUMN order_date DATE;

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'restaurant_data_cleaned'
  AND COLUMN_NAME = 'order_date';

-- Sanity Check
SELECT COUNT(*) FROM restaurant_data_cleaned;
SELECT TOP 10 * FROM restaurant_data_cleaned;

-- Basic Validation
SELECT COUNT(*) FROM restaurant_data_cleaned WHERE quantity > 0;
SELECT COUNT(*) FROM restaurant_data_cleaned WHERE order_total > 0;

-- Dropping column that is not useful
ALTER TABLE restaurant_data_cleaned DROP COLUMN order_hour;

-- Core Business Analysis
-- KPIs
SELECT 
    COUNT(order_id) AS total_orders,
    SUM(order_total) AS total_revenue,
    ROUND(AVG(order_total),2) AS avg_order_value
FROM restaurant_data_cleaned;

-- Revenue by Day
SELECT 
    order_day,
    SUM(order_total) AS revenue
FROM restaurant_data_cleaned
GROUP BY order_day
ORDER BY revenue DESC;

-- Revenue by Category
SELECT category,
	SUM(order_total) AS revenue
FROM restaurant_data_cleaned
GROUP BY category
ORDER BY revenue DESC;

-- Revenue by Item
SELECT item,
	SUM(order_total) AS revenue
FROM restaurant_data_cleaned
GROUP BY item
ORDER BY revenue DESC;

-- Revenue by Month
SELECT order_month,
	SUM(order_total) AS revenue
FROM restaurant_data_cleaned
GROUP BY order_month
ORDER BY revenue DESC;

-- Revenue/Collections by Payment Method
SELECT payment_method,
	SUM(order_total) AS revenue
FROM restaurant_data_cleaned
GROUP BY payment_method
ORDER BY revenue DESC;

-- Top 5 Most ordered dish
SELECT item, 
	COUNT(item) AS no_of_orders
FROM restaurant_data_cleaned
GROUP BY item
ORDER BY no_of_orders DESC
OFFSET 1 ROWS FETCH NEXT 5 ROWS ONLY;

-- Top 5 Least ordered dish
SELECT TOP 5 item, 
	COUNT(item) AS no_of_orders
FROM restaurant_data_cleaned
GROUP BY item
ORDER BY no_of_orders;

-- Frequently visited/Highest number of Orders by Customer
SELECT customer_id,
	COUNT(customer_id) AS no_of_orders
FROM restaurant_data_cleaned
GROUP BY customer_id
ORDER BY no_of_orders DESC;

-- Most Ordered Category
SELECT category,
	COUNT(category) AS no_of_orders,
	SUM(order_total) AS revenue
FROM restaurant_data_cleaned
GROUP BY category
ORDER BY no_of_orders DESC;

-- Quantity vs Spending
SELECT
  quantity,
  ROUND(AVG(order_total),2) AS avg_order_value
FROM restaurant_data_cleaned
GROUP BY quantity
ORDER BY quantity;

-- Top Spending Customers
SELECT TOP 5
  customer_id,
  SUM(order_total) AS total_spent
FROM restaurant_data_cleaned
GROUP BY customer_id
ORDER BY total_spent DESC;

-- Revenue Segmentation
SELECT
  order_id,
  order_total,
  CASE
    WHEN order_total >= 30 THEN 'High Value'
    WHEN order_total >= 15 THEN 'Medium Value'
    ELSE 'Low Value'
  END AS order_segment
FROM restaurant_data_cleaned;

-- Revenue greater than 20000 from specific dishes
SELECT 
    item,
    SUM(order_total) AS revenue
FROM restaurant_data_cleaned
GROUP BY item
HAVING SUM(order_total) > 20000
ORDER BY revenue DESC;

-- Create a view
CREATE VIEW vw_daily_revenue
AS
SELECT 
    order_day,
    SUM(order_total) AS revenue
FROM restaurant_data_cleaned
GROUP BY order_day;

CREATE VIEW vw_category_revenue AS
SELECT
    category,
    SUM(order_total) AS total_revenue
FROM restaurant_data_cleaned
GROUP BY category;

-- We can create multiple views for creating dashboards in easier way
-- Now, we have more broader view or understanding of our dataset
-- We ready to create PowerBI Dashboards