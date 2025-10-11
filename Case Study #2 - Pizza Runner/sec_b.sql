-- B. Runner and Customer Experience

-- 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
    DATE_TRUNC('week', r."registration_date") + 4  as "week",
    COUNT(r."runner_id") as runners_signed_up
FROM runners as r
GROUP BY DATE_TRUNC('week', r."registration_date") + 4
ORDER BY DATE_TRUNC('week', r."registration_date") + 4;

-- 2.What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT 
    ro."runner_id",
    ROUND(AVG(TIMEDIFF('minute',co."order_time",ro."pickup_time"::timestamp_ntz)),0) as AVG_TIME
FROM customer_orders as co 
LEFT JOIN runner_orders as ro USING("order_id")
WHERE ro."pickup_time" <> 'null'
GROUP BY ro."runner_id"
ORDER BY ro."runner_id";

-- 3.Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT 
    co."order_id",
    COUNT(co."pizza_id") as "no._pizza",       
    ROUND(AVG(TIMEDIFF('minute',co."order_time",ro."pickup_time"::timestamp_ntz)),0) as AVG_TIME
FROM customer_orders as co 
LEFT JOIN runner_orders as ro USING("order_id")
WHERE ro."pickup_time" <> 'null'
GROUP BY co."order_id"
ORDER BY ROUND(AVG(TIMEDIFF('minute',co."order_time",ro."pickup_time"::timestamp_ntz)),0);



-- What was the average distance travelled for each customer?
-- What was the difference between the longest and shortest delivery times for all orders?
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- What is the successful delivery percentage for each runner?