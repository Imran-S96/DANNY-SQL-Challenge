-- VIEW CREATED

CREATE VIEW DINNER AS (
SELECT *
FROM SALES AS S
LEFT JOIN MENU AS MU USING ("product_id")
LEFT JOIN MEMBERS AS M USING("customer_id")
);


-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
    "customer_id", 
     SUM("price") AS "total_spent"
FROM DINNER
GROUP BY "customer_id";


-- 2. How many days has each customer visited the restaurant?

SELECT 
    "customer_id", 
     COUNT(DISTINCT "order_date") AS "days_visited"
FROM DINNER
GROUP BY "customer_id";


-- 3. What was the first item from the menu purchased by each customer?

WITH first_item AS (
SELECT 
    "customer_id", 
    "order_date", 
    "product_name",
     RANK() OVER (PARTITION BY "customer_id" ORDER BY "order_date") AS rank
FROM DINNER
GROUP BY "customer_id", "order_date", "product_name")

SELECT 
    "customer_id" , 
    "product_name"
FROM first_item
WHERE rank = 1;

-- Alternative Subquery

SELECT 
    "customer_id", 
    "product_name"
FROM (
        SELECT  
            "customer_id", 
            "order_date", 
            "product_name",
            RANK() OVER (PARTITION BY "customer_id" ORDER BY "order_date") AS rank
        FROM DINNER
        GROUP BY "customer_id", "order_date", "product_name")
WHERE rank = 1;



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT  
    "product_name", 
     COUNT("product_name") AS "times_ordered"
FROM DINNER
GROUP BY "product_name"
ORDER BY COUNT("product_name") DESC
LIMIT 1;


-- Alternative Subquery

WITH M_PURCHASE AS (
SELECT 
    "product_name", 
     COUNT("product_name") AS "times_ordered"
FROM DINNER
GROUP BY "product_name"
ORDER BY COUNT("product_name") DESC)

SELECT 
    "product_name", 
    "times_ordered"
FROM M_PURCHASE
where "times_ordered" = (SELECT MAX("times_ordered") FROM M_PURCHASE) ;


-- Alternative Subquery RANK FUNCTION

SELECT 
    "product_name", 
    "times_ordered" 
FROM (
        SELECT 
            "product_name", 
            COUNT("product_name") AS "times_ordered", 
            RANK() OVER (ORDER BY COUNT("product_name") DESC) AS RANK
        FROM DINNER
        GROUP BY "product_name"
        ORDER BY COUNT("product_name") DESC)
WHERE RANK = 1;


-- 5. Which item was the most popular for each customer?

SELECT 
    "customer_id", 
    "product_name", 
    "times_ordered" 
FROM (
        SELECT 
            "customer_id", 
            "product_name", 
            COUNT("product_name") AS "times_ordered", 
            RANK() OVER (PARTITION BY "customer_id" ORDER BY COUNT("product_name") DESC) AS RANK
        FROM DINNER
        GROUP BY "customer_id", "product_name"
        ORDER BY "customer_id", COUNT("product_name") DESC)
WHERE RANK = 1;


-- 6. Which item was purchased first by the customer after they became a member?

SELECT 
    "customer_id", 
    "product_name" 
FROM (
        SELECT 
            *, 
            RANK() OVER (PARTITION BY "customer_id" ORDER BY "order_date" ) AS RNK
        FROM DINNER
        WHERE "join_date" IS NOT NULL AND "order_date" >= "join_date"
        ORDER BY "customer_id")
WHERE RNK = 1;


-- 7. Which item was purchased just before the customer became a member?

SELECT 
    "customer_id", 
    "product_name"
FROM DINNER
WHERE "join_date" IS NOT NULL AND "order_date" < "join_date"
GROUP BY "customer_id", "product_name"
ORDER BY "customer_id";


-- 8. What is the total items and amount spent for each member before they became a member?


SELECT 
    "customer_id",  
     COUNT("product_name") AS "total_items", 
     SUM("price") AS "spend"
FROM DINNER
WHERE "join_date" IS NOT NULL AND "order_date" < "join_date"
GROUP BY "customer_id"
ORDER BY "customer_id";


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT "customer_id", SUM("points") AS "total_points"  
FROM (
        SELECT 
            *,
            CASE 
                 WHEN "product_name" = 'sushi' THEN "price" * 20
                 ELSE "price" * 10 END AS "points"
        FROM DINNER)
GROUP BY "customer_id";


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


SELECT "customer_id", SUM("points") AS "total_points"  
 FROM (
        SELECT 
                *,
                CASE 
                     WHEN "product_name" = 'sushi' or "order_date" BETWEEN '2021-01-07' AND '2021-01-14' THEN "price" * 20
                     ELSE "price" * 10 END AS "points",
        FROM DINNER
        WHERE "join_date" IS NOT NULL AND "order_date" BETWEEN '2021-01-01' AND '2021-01-31' )
GROUP BY "customer_id";



