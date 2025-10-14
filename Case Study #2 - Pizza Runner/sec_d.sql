-- D. Pricing and Ratings

-- 1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes 
-- how much money has Pizza Runner made so far if there are no delivery fees?

-- This is accounting the cancellations

SELECT 
SUM(CASE 
    WHEN co."pizza_id" = 1 THEN 12
    WHEN co."pizza_id" = 2 THEN 10
    ELSE null END) as pizza_runner_earnings
FROM customer_orders as co
LEFT JOIN runner_orders as ro on ro."order_id" = co."order_id"
WHERE ro."pickup_time" <> 'null';

-- 2.What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra


SELECT 
*,
CASE 
    WHEN TRY_TO_NUMBER(s.value) IN (1,2,3,4,6,7,8,9,10,11,12) THEN 1
    WHEN TRY_TO_NUMBER(s.value) = 5 THEN 2    
    ELSE 0 END as additional_cost
FROM customer_orders as co
LEFT JOIN LATERAL SPLIT_TO_TABLE(IFNULL(co."extras",''),', ') as s;


SELECT 
*,
CASE 
    WHEN TRY_TO_NUMBER(s.value) = 5 THEN 2    
    WHEN co."extras" is not null AND co."extras" <> 'null' AND co."extras" <>'' THEN 1
    ELSE 0 END as additional_cost
FROM customer_orders as co
LEFT JOIN LATERAL SPLIT_TO_TABLE(IFNULL(co."extras",''),', ') as s;

-- 3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
-- how would you design an additional table for this new dataset 
-- - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

-- 4.Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas


-- 5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - 
-- how much money does Pizza Runner have left over after these deliveries?