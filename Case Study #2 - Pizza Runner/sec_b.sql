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

WITH CTE AS (
SELECT 
    co."order_id",
    COUNT(co."pizza_id") as pizza_nums,       
    ROUND(AVG(TIMEDIFF('minute',co."order_time",ro."pickup_time"::timestamp_ntz)),0) as AVG_TIME
FROM customer_orders as co 
LEFT JOIN runner_orders as ro USING("order_id")
WHERE ro."pickup_time" <> 'null'
GROUP BY co."order_id")

SELECT 
    pizza_nums,
    ROUND(AVG(AVG_TIME),0) as avg_time
FROM CTE
GROUP BY pizza_nums
ORDER BY AVG_TIME;



-- 4.What was the average distance travelled for each customer?

SELECT
    co."customer_id",
    ROUND(AVG(REPLACE(ro."distance", 'km', '')),2) AS avg_distance
FROM customer_orders as co
LEFT JOIN runner_orders as ro USING("order_id")
WHERE ro."distance" <> 'null'
GROUP BY co."customer_id"
;

-- 5.What was the difference between the longest and shortest delivery times for all orders?

SELECT 
  MAX(REGEXP_REPLACE("duration", '[^0-9]', '')::int) - MIN(REGEXP_REPLACE("duration", '[^0-9]', '')::int) as delivery_time_difference 
FROM runner_orders 
WHERE "duration" <> 'null'; 

-- 6.What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
    "runner_id",
    "order_id",
    ROUND(AVG((REPLACE("distance", 'km', ''))  / ((REGEXP_REPLACE("duration", '[^0-9]', ''))/60)),2)as speed_km_per_hour
FROM runner_orders
WHERE "distance" <> 'null'
GROUP BY "runner_id","order_id"
ORDER BY "runner_id","order_id";

-- 7.What is the successful delivery percentage for each runner?

SELECT
    "runner_id",
    ROUND(
    (SUM(CASE WHEN "pickup_time" <> 'null' THEN 1 ELSE 0 END)
    /
    (SUM(CASE WHEN "pickup_time" <> 'null' THEN 1 ELSE 0 END) + SUM(CASE WHEN "pickup_time" <> 'null' THEN 0 ELSE 1 END))*100)
    ,0) AS success_delivery_percentage

FROM runner_orders
GROUP BY "runner_id"
;

select *
from runner_orders;