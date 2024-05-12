CREATE DATABASE pizza;

USE pizza;

CREATE TABLE orders(
order_id int NOT NULL,
order_date date NOT NULL,
order_time time NOT NULL,
PRIMARY KEY(order_id) );


CREATE TABLE order_details(
order_details_id int NOT NULL,
order_id int NOT NULL,
pizza_id text NOT NULL,
quantity int NOT NULL,
PRIMARY KEY(order_details_id) );


-- BASIC --
-- Retrieve the total number of orders placed.

SELECT * FROM orders;

SELECT count(order_id) as total_number_of_orders
FROM orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
    
--     CTRL+B to beautify the query


-- Identify the highest-priced pizza.
SELECT 
    pt.name AS name, p.price AS price
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT 
    p.size AS size, COUNT(od.order_details_id) AS count
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = od.pizza_id
GROUP BY size
ORDER BY count DESC;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name name, SUM(od.quantity) quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY name
ORDER BY quantity DESC
LIMIT 5;



-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category AS category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY category
ORDER BY total_quantity DESC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) hour, COUNT(order_id) order_count
FROM
    orders
GROUP BY hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) pizza_count
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) quantity
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY order_date) AS quantity_ordered;



-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name, SUM(od.quantity * p.price) revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY name
ORDER BY revenue DESC
LIMIT 3;


-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
                FROM
                    order_details od
                        JOIN
                    pizzas p ON od.pizza_id = p.pizza_id)) * 100,
            2) revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY category
ORDER BY revenue DESC; 
