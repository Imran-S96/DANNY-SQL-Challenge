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

-- 4.How many of each type of pizza was delivered?

SELECT 
pn."pizza_name",
COUNT(ro."pickup_time") AS delivered
FROM customer_orders as c
LEFT JOIN pizza_names as pn on c."pizza_id" = pn."pizza_id"
LEFT JOIN runner_orders as ro on c."order_id" = ro."order_id"
WHERE ro."pickup_time" <> 'null'
GROUP BY pn."pizza_name"
;

-- 5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
c."customer_id",
pn."pizza_name",
COUNT(c."order_id") as ordered
FROM customer_orders as c
LEFT JOIN pizza_names as pn on c."pizza_id" = pn."pizza_id"
LEFT JOIN runner_orders as ro on c."order_id" = ro."order_id"
WHERE ro."pickup_time" <> 'null'
GROUP BY c."customer_id", pn."pizza_name"
ORDER BY c."customer_id" ASC;


-- 6.What was the maximum number of pizzas delivered in a single order?

SELECT order_id, delivered
FROM (
    SELECT 
        c."order_id" AS order_id,
        COUNT(ro."pickup_time") AS delivered,
        RANK() OVER (ORDER BY COUNT(ro."pickup_time") DESC) AS rank
    FROM customer_orders AS c
    LEFT JOIN pizza_names AS pn ON c."pizza_id" = pn."pizza_id"
    LEFT JOIN runner_orders AS ro ON c."order_id" = ro."order_id"
    WHERE ro."pickup_time" <> 'null'
    GROUP BY c."order_id"
) AS ranked
WHERE rank = 1;


-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
co."customer_id",
SUM(CASE 
    WHEN ((co."exclusions" <> 'null' and co."exclusions" <> '')  
    OR (co."extras" <> 'null' and co."extras" <> '')) 
    THEN 1 ELSE 0 END) as "changes",
SUM(CASE 
    WHEN ((co."exclusions" <> 'null' and co."exclusions" <> '')  
    OR (co."extras" <> 'null' and co."extras" <> '')) THEN 0
    ELSE 1 END) as "no_changes"
FROM customer_orders as co 
LEFT JOIN runner_orders as ro USING("order_id")
WHERE ro."pickup_time" <> 'null'
GROUP BY co."customer_id"
ORDER BY co."customer_id"
;

-- How many pizzas were delivered that had both exclusions and extras?

-- What was the total volume of pizzas ordered for each hour of the day?

-- What was the volume of orders for each day of the week?