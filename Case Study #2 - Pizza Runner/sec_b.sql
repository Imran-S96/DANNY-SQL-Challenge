-- B. Runner and Customer Experience

-- 1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
DATE_TRUNC('week', r."registration_date") + 4  as "week",
COUNT(r."runner_id") as runners_signed_up
FROM runners as r
GROUP BY DATE_TRUNC('week', r."registration_date") + 4
ORDER BY DATE_TRUNC('week', r."registration_date") + 4;




-- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- What was the average distance travelled for each customer?
-- What was the difference between the longest and shortest delivery times for all orders?
-- What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- What is the successful delivery percentage for each runner?