-- C. Ingredient Optimisation

-- 1.What are the standard ingredients for each pizza?

SELECT 
    pn."pizza_name",
    pt."topping_name"
FROM pizza_recipes
LEFT JOIN LATERAL SPLIT_TO_TABLE("toppings", ',') as S
LEFT JOIN pizza_names as pn USING("pizza_id")
LEFT JOIN pizza_toppings as pt on S.value = pt."topping_id" ;

-- 2.What was the most commonly added extra?

SELECT 
    pt."topping_name",
    COUNT(pt."topping_name") as count_of_toppings_extra
FROM customer_orders
LEFT JOIN LATERAL SPLIT_TO_TABLE("extras",',') as S
LEFT JOIN pizza_toppings as pt on pt."topping_id" = TRY_TO_NUMBER(S.value)
WHERE S.value <> 'null' AND S.value <> ''
GROUP BY pt."topping_name"
ORDER BY COUNT(pt."topping_name") DESC
;

SELECT 
    pt."topping_name",
    COUNT(pt."topping_name") as count_of_toppings_extra,
FROM customer_orders
LEFT JOIN LATERAL SPLIT_TO_TABLE("extras",',') as S
LEFT JOIN pizza_toppings as pt on pt."topping_id" = TRY_TO_NUMBER(S.value)
WHERE S.value <> 'null' AND S.value <> ''
GROUP BY pt."topping_name"
QUALIFY DENSE_RANK() OVER (ORDER BY COUNT(pt."topping_name") DESC) = 1
ORDER BY COUNT(pt."topping_name") DESC
;

-- 3.What was the most common exclusion?

SELECT 
    pt."topping_name",
    COUNT(pt."topping_name") as count_of_toppings_exclusion
FROM customer_orders
LEFT JOIN LATERAL SPLIT_TO_TABLE("exclusions",',') as S
LEFT JOIN pizza_toppings as pt on pt."topping_id" = TRY_TO_NUMBER(S.value)
WHERE S.value <> 'null' AND S.value <> ''
GROUP BY pt."topping_name"
QUALIFY DENSE_RANK() OVER (ORDER BY COUNT(pt."topping_name") DESC) = 1
ORDER BY COUNT(pt."topping_name") DESC
;

-- 4.Generate an order item for each record in the customers_orders table in the format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


-- 5.Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- 6.What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?