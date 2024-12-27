create database pizza_sales;
use pizza_sales;

create table orders (
      order_id INT primary key,
      date text,
      time text
);

## FOR IMPORTING THE DATA USING QUERY---
LOAD DATA INFILE 'C:\Users\Abhijit Patil\Downloads\Pizza-Sales-SQL-and-Power-BI-main\Pizza-Sales-SQL-and-Power-BI-main\orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
-----------------------------------------------------------------------------------------------------------------------------
SELECT * FROM orders;
SELECT * FROM order_details; 
SELECT * FROM pizzas;
SELECT * FROM pizza_types;

## CONNECTING TWO TABLES PIZZAS & PIZZA_TYPES
CREATE VIEW pizza_details AS 
SELECT p.pizza_id,p.pizza_type_id,pt.name,pt.category,p.size,p.price,pt.ingredients
FROM pizzas p
JOIN pizza_types pt
ON pt.pizza_type_id = p.pizza_type_id;

SELECT * FROM pizza_details;

## CHANGING DATATYPES
ALTER TABLE orders
MODIFY date DATE;

ALTER TABLE orders
MODIFY time TIME;

## DATA ANALYSIS
-- total revenue
SELECT ROUND(SUM(od.quantity * p.price),2) AS total_revenue
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id;

-- total no. of pizzas sold
SELECT SUM(od.quantity) AS pizza_sold
FROM order_details od;

-- total orders
SELECT COUNT(DISTINCT(order_id)) AS total_orders
FROM order_details;

-- Average order value
SELECT SUM(od.quantity * p.price) / COUNT(DISTINCT(od.order_id)) AS avg_order_value
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id;

--  average number of pizza per order
SELECT ROUND(SUM(od.quantity) / COUNT(DISTINCT(od.order_id)),0) AS avg_no_pizza_per_order FROM order_details od;

-- total revenue and no of orders per category
SELECT p.category, SUM(od.quantity*p.price) AS total_revenue, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id
GROUP BY p.category;

-- toatal revenue and number od orders per size
SELECT p.size, SUM(od.quantity*p.price) AS total_revenue, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id
GROUP BY p.size;

-- hourly,daily and monthly trend in orders and revenue of pizza
SELECT 
	CASE 
	    WHEN HOUR(o.time) BETWEEN 9 AND 12 THEN 'Late Morning'
        WHEN HOUR(o.time) BETWEEN 12 AND 15 THEN 'Lunch'
        WHEN HOUR(o.time) BETWEEN 15 AND 18 THEN 'Mid Afternoon'
        WHEN HOUR(o.time) BETWEEN 18 AND 21 THEN 'Dinner'
        WHEN HOUR(o.time) BETWEEN 21 AND 23 THEN 'Late Night'
        ELSE 'others'
        END AS meal_time, COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o ON o.order_id = od.order_id
GROUP BY meal_time
ORDER BY total_orders DESC;

-- weekdays 
SELECT DAYNAME(o.date) AS day_name,COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o
ON o.order_id = od.order_id
GROUP BY DAYNAME(o.date)
ORDER BY total_orders DESC;

-- monthwise trend
SELECT MONTHNAME(o.date) AS day_name,COUNT(DISTINCT(od.order_id)) AS total_orders
FROM order_details od
JOIN orders o
ON o.order_id = od.order_id
GROUP BY MONTHNAME(o.date)
ORDER BY total_orders DESC;

-- Most ordered pizza by size
SELECT p.name,p.size,COUNT(od.order_id) AS count_pizzas
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id
GROUP BY p.name,p.size
ORDER BY count_pizzas DESC;

-- Most ordered pizza by name
SELECT p.name, COUNT(od.order_id) AS count_pizzas
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY count_pizzas DESC
LIMIT 1;

-- TOP 5 pizzas by revenue
SELECT p.name, SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY total_revenue DESC
LIMIT 5;

-- top pizzas by sales
SELECT p.name, SUM(od.quantity) AS pizzas_sold
FROM order_details od
JOIN pizza_details p
ON od.pizza_id = p.pizza_id
GROUP BY p.name
ORDER BY pizzas_sold DESC
LIMIT 5;

-- pizza analysis
SELECT name,price
FROM pizza_details
ORDER BY price DESC
LIMIT 1;

-- Top used ingredients
SELECT * FROM pizza_details;

CREATE TEMPORARY TABLE numbers AS ( 
	SELECT 1 AS n UNION ALL 
    SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
    SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL 
    SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
);

SELECT ingredient, COUNT(ingredient) AS ingredient_count
FROM (
      SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(ingredients,',',n),',',-1) AS ingredient
      FROM order_details
      JOIN pizza_details ON pizza_details.pizza_id = order_details.pizza_id
      JOIN numbers ON CHAR_LENGTH(ingredients) - CHAR_LENGTH(REPLACE(ingredients,',','')) >= n-1
      ) AS subquery
GROUP BY ingredient
ORDER BY ingredient_count DESC;