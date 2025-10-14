-- C. Ingredient Optimisation

-- 1.What are the standard ingredients for each pizza?

SELECT 
    pn."pizza_name",
    LISTAGG(pt."topping_name", ', ') as toppings
FROM pizza_recipes
LEFT JOIN LATERAL SPLIT_TO_TABLE("toppings", ',') as S
LEFT JOIN pizza_names as pn USING("pizza_id")
LEFT JOIN pizza_toppings as pt on S.value = pt."topping_id" 
GROUP BY pn."pizza_name";

-- 2.What was the most commonly added extra?

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

SELECT
    co."order_id",
    pn."pizza_name",
    pn."pizza_name"
        || COALESCE(CASE WHEN COUNT(pt."topping_id")  > 0 THEN ' - Exclude ' || LISTAGG(DISTINCT  pt."topping_name",  ', ') END, '')
        || COALESCE(CASE WHEN COUNT(pt1."topping_id") > 0 THEN ' - Extra '   || LISTAGG(DISTINCT  pt1."topping_name", ', ') END, '') AS toppings,
FROM 
    (select 
    *,
    ROW_NUMBER() OVER (ORDER BY co."order_id" ) as RNK
    from customer_orders as co) as co
LEFT JOIN pizza_names AS pn ON co."pizza_id" = pn."pizza_id"
LEFT JOIN LATERAL SPLIT_TO_TABLE("exclusions", ',') AS exl
LEFT JOIN LATERAL SPLIT_TO_TABLE(IFNULL(co."extras",'null'), ',') AS ext
LEFT JOIN pizza_toppings AS pt  ON TRY_TO_NUMBER(exl.value) = pt."topping_id"
LEFT JOIN pizza_toppings AS pt1 ON TRY_TO_NUMBER(ext.value) = pt1."topping_id"
GROUP BY co.RNK, co."order_id", pn."pizza_name"
ORDER BY co.RNK, co."order_id";


-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH EXCLUSIONS AS (
    SELECT 
    order_id,
    pizza_id,
    S.value as topping_id
    FROM customer_orders as co
    LEFT JOIN LATERAL SPLIT_TO_TABLE(exclusions,', ') as S
    WHERE LENGTH(value)>0 AND value<>'null'
)
,EXTRAS AS (
    SELECT 
    order_id,
    pizza_id,
    S.value as topping_id,
    topping_name
    FROM customer_orders as co
    LEFT JOIN LATERAL SPLIT_TO_TABLE(extras,', ') as S
    INNER JOIN pizza_toppings as T on t.topping_id = S.value
    WHERE LENGTH(value)>0 AND value<>'null'
)
,ORDERS AS (
    SELECT DISTINCT
    CO.order_id,
    CO.pizza_id,
    S.value as topping_id,
    topping_name
    FROM customer_orders as CO
    INNER JOIN pizza_recipes as PR on CO.pizza_id = PR.pizza_id
    LEFT JOIN LATERAL SPLIT_TO_TABLE(toppings,', ') as S
    INNER JOIN pizza_toppings as T on t.topping_id = S.value
)
,ORDERS_WITH_EXTRAS_AND_EXCLUSIONS AS (
    SELECT 
    O.order_id,
    O.pizza_id,
    O.topping_id::int as topping_id,
    topping_name
    FROM ORDERS AS O
    LEFT JOIN EXCLUSIONS AS EXC ON EXC.order_id=O.order_id AND EXC.pizza_id=O.pizza_id AND EXC.topping_id=O.topping_id 
    WHERE EXC.topping_id IS NULL

    UNION ALL 

    SELECT 
    order_id,
    pizza_id,
    topping_id::int as topping_id,
    topping_name
    FROM EXTRAS
    WHERE topping_id<>''
)
,TOPPING_COUNT AS (
    SELECT 
    O.order_id,
    O.pizza_id,
    O.topping_name,
    COUNT(*) as n
    FROM ORDERS_WITH_EXTRAS_AND_EXCLUSIONS as O
    GROUP BY 
    O.order_id,
    O.pizza_id,
    O.topping_name
)
SELECT 
order_id,
pizza_id,
LISTAGG(
CASE
    WHEN n>1 THEN n || 'x' || topping_name
    ELSE topping_name
END,', ') as ingredient
FROM TOPPING_COUNT
GROUP BY order_id,
pizza_id;

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
WITH EXCLUSIONS AS (
    SELECT 
    order_id,
    pizza_id,
    S.value as topping_id
    FROM customer_orders as co
    LEFT JOIN LATERAL SPLIT_TO_TABLE(exclusions,', ') as S
    WHERE LENGTH(value)>0 AND value<>'null'
)
,EXTRAS AS (
    SELECT 
    order_id,
    pizza_id,
    S.value as topping_id,
    topping_name
    FROM customer_orders as co
    LEFT JOIN LATERAL SPLIT_TO_TABLE(extras,', ') as S
    INNER JOIN pizza_toppings as T on t.topping_id = S.value
    WHERE LENGTH(value)>0 AND value<>'null'
)
,ORDERS AS (
    SELECT DISTINCT
    CO.order_id,
    CO.pizza_id,
    S.value as topping_id,
    topping_name
    FROM customer_orders as CO
    INNER JOIN pizza_recipes as PR on CO.pizza_id = PR.pizza_id
    LEFT JOIN LATERAL SPLIT_TO_TABLE(toppings,', ') as S
    INNER JOIN pizza_toppings as T on t.topping_id = S.value
)
,ORDERS_WITH_EXTRAS_AND_EXCLUSIONS AS (
    SELECT 
    O.order_id,
    O.pizza_id,
    O.topping_id::int as topping_id,
    topping_name
    FROM ORDERS AS O
    LEFT JOIN EXCLUSIONS AS EXC ON EXC.order_id=O.order_id AND EXC.pizza_id=O.pizza_id AND EXC.topping_id=O.topping_id 
    WHERE EXC.topping_id IS NULL

    UNION ALL 

    SELECT 
    order_id,
    pizza_id,
    topping_id::int as topping_id,
    topping_name
    FROM EXTRAS
    WHERE topping_id<>''
)

SELECT 
O.topping_name,
COUNT(O.pizza_id) as ingredient_count
FROM ORDERS_WITH_EXTRAS_AND_EXCLUSIONS as O
INNER JOIN runner_orders as ro on O.order_id = ro.order_id
WHERE pickup_time<>'null'
GROUP BY 
O.topping_name
ORDER BY COUNT(O.pizza_id) DESC