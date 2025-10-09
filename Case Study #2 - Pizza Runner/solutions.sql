-- A. Pizza Metrics

-- 1.How many pizzas were ordered?

SELECT COUNT("pizza_id") AS Total_pizza_ordered
FROM customer_orders;

-- 2.How many unique customer orders were made?

SELECT COUNT(DISTINCT("order_id")) AS total_unique_orders
FROM customer_orders;

-- 3.How many successful orders were delivered by each runner?

SELECT "runner_id", COUNT("pickup_time") AS successful_orders
FROM runner_orders
WHERE "pickup_time" <> 'null'
GROUP BY "runner_id";

-- How many of each type of pizza was delivered?

SELECT 
pn."pizza_name",
COUNT(ro."pickup_time") AS delivered
FROM customer_orders as c
LEFT JOIN pizza_names as pn on c."pizza_id" = pn."pizza_id"
LEFT JOIN runner_orders as ro on c."order_id" = ro."order_id"
WHERE ro."pickup_time" <> 'null'
GROUP BY pn."pizza_name"
;

-- How many Vegetarian and Meatlovers were ordered by each customer?

-- What was the maximum number of pizzas delivered in a single order?

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

-- How many pizzas were delivered that had both exclusions and extras?

-- What was the total volume of pizzas ordered for each hour of the day?

-- What was the volume of orders for each day of the week?