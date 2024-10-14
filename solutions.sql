-- 1. What is the total amount each customer spent at the restaurant?

SELECT S."customer_id" , SUM(M."price") AS "total_spend"
FROM sales AS S
LEFT JOIN menu AS M
USING("product_id")
GROUP BY S."customer_id"
ORDER BY S."customer_id"; 

+--------------+-------------+
| customer_id  | TOTAL_SPEND |
+--------------+-------------+
| A            | 76          |
| B            | 74          |
| C            | 36          |
+--------------+-------------+

-- 2. How many days has each customer visited the restaurant?

SELECT "customer_id" , COUNT(DISTINCT("order_date")) AS "days"
FROM sales
GROUP BY "customer_id"
ORDER BY "customer_id";

+--------------+------+
| customer_id  | days |
+--------------+------+
| A            | 4    |
| B            | 6    |
| C            | 2    |
+--------------+------+

-- 3. What was the first item from the menu purchased by each customer?

WITH CTE AS (
SELECT 
 "customer_id", 
 "order_date",
 "product_name",
 RANK() OVER (PARTITION BY "customer_id" ORDER BY "order_date") AS "RNK"
FROM sales
INNER JOIN menu
USING("product_id")
)

SELECT "customer_id" , "product_name"
FROM CTE
WHERE "RNK" = 1
ORDER BY "customer_id" ASC;

+--------------+--------------+
| customer_id  | product_name  |
+--------------+--------------+
| A            | sushi         |
| A            | curry         |
| B            | curry         |
| C            | ramen         |
| C            | ramen         |
+--------------+--------------+

-- 4.What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT M."product_name",COUNT(M."product_name") AS "purchased_times"
FROM sales AS S
INNER JOIN menu AS M
USING("product_id")
GROUP BY M."product_name"
ORDER BY "purchased_times" DESC
LIMIT 1;

+--------------+------------------+
| product_name | purchased_times   |
+--------------+------------------+
| ramen        | 8                |
+--------------+------------------+


-- 5. Which item was the most popular for each customer?

WITH CTE AS
(SELECT 
 S."customer_id", 
 M."product_name", 
 COUNT(M."product_name") AS "count",
 RANK() OVER (PARTITION BY S."customer_id" ORDER BY COUNT(M."product_name") DESC ) AS "RNK"
FROM sales AS S
INNER JOIN menu AS M
USING("product_id")
GROUP BY S."customer_id", M."product_name"
)
SELECT "customer_id","product_name"
FROM CTE
WHERE "RNK" = 1
ORDER BY "customer_id";

+--------------+--------------+
| customer_id  | product_name  |
+--------------+--------------+
| A            | ramen         |
| B            | curry         |
| B            | sushi         |
| B            | ramen         |
| C            | ramen         |
+--------------+--------------+

-- 6. Which item was purchased first by the customer after they became a member?

WITH CTE AS (
SELECT 
 S."customer_id",
 M."product_name",
 S."order_date",
 RANK() OVER(PARTITION BY S."customer_id" ORDER BY S."order_date" ) AS "RNK"
FROM sales AS S
INNER JOIN members AS MEM
USING("customer_id")
INNER JOIN menu AS M
USING ("product_id")
WHERE S."order_date" >= MEM."join_date"
)
SELECT "customer_id", "product_name", "order_date"
FROM CTE
WHERE "RNK" = 1;

+--------------+--------------+------------+
| customer_id  | product_name  | order_date |
+--------------+--------------+------------+
| A            | curry         | 07/01/2021 |
| B            | sushi         | 11/01/2021 |
+--------------+--------------+------------+

-- 7. Which item was purchased just before the customer became a member?

WITH CTE AS (
SELECT 
 S."customer_id",
 M."product_name",
 S."order_date",
 RANK() OVER(PARTITION BY S."customer_id" ORDER BY S."order_date" DESC ) AS "RNK"
FROM sales AS S
INNER JOIN members AS MEM
USING("customer_id")
INNER JOIN menu AS M
USING ("product_id")
WHERE S."order_date" < MEM."join_date"
)
SELECT "customer_id", "product_name", "order_date"
FROM CTE
WHERE "RNK" = 1;

+--------------+--------------+------------+
| customer_id  | product_name  | order_date |
+--------------+--------------+------------+
| A            | sushi         | 01/01/2021 |
| A            | curry         | 01/01/2021 |
| B            | sushi         | 04/01/2021 |
+--------------+--------------+------------+

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
 S."customer_id",
 SUM(M."price") AS "total_spend",
 COUNT(M."product_id") AS "total_items_purchased" 
FROM sales AS S
INNER JOIN members AS MEM
USING("customer_id")
INNER JOIN menu AS M
USING ("product_id")
WHERE S."order_date" < MEM."join_date"
GROUP BY S."customer_id"
ORDER BY S."customer_id" ASC;

+--------------+-------------+-------------------------+
| customer_id  | total_spend | total_items_purchased   |
+--------------+-------------+-------------------------+
| A            | 25          | 2                       |
| B            | 40          | 3                       |
+--------------+-------------+-------------------------+

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
 S."customer_id",
 SUM (CASE 
  WHEN M."product_name" = 'sushi' THEN M."price" * 20
  ELSE M."price" * 10
  END) AS "points"
FROM sales AS S
LEFT JOIN menu AS M
USING ("product_id")
GROUP BY S."customer_id";

+--------------+--------+
| customer_id  | points |
+--------------+--------+
| A            | 860    |
| B            | 940    |
| C            | 360    |
+--------------+--------+

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi 
-- how many points do customer A and B have at the end of January?

SELECT 
  S."customer_id", 
  SUM(
    CASE 
      WHEN S."order_date" BETWEEN MEM."join_date" AND DATEADD('day', 6, MEM."join_date") THEN M."price" * 10 * 2 
      WHEN M."product_name" = 'sushi' THEN M."price" * 10 * 2 
      ELSE M."price" * 10 
    END
  ) AS "points"
FROM menu AS M
INNER JOIN sales AS S 
USING ("product_id")
INNER JOIN members AS MEM
USING ("customer_id")
WHERE DATE_TRUNC('month', S."order_date") = '2021-01-01' 
GROUP BY S."customer_id";

+--------------+--------+
| customer_id  | points |
+--------------+--------+
| A            | 1370   |
| B            | 820    |
+--------------+--------+


-- Bonus Question 1

SELECT 
S."customer_id",
S."order_date",
M."product_name",
M."price",
(CASE
WHEN MEM."join_date" is NULL THEN 'N'
WHEN MEM."join_date">S."order_date" THEN 'N'
ELSE 'Y'
END)
AS "member"
FROM sales AS S
LEFT JOIN menu AS M
USING("product_id")
LEFT JOIN members AS MEM
USING("customer_id")
ORDER BY S."customer_id",S."order_date",M."price" DESC;

+--------------+------------+--------------+-------+--------+
| customer_id  | order_date | product_name | price | member |
+--------------+------------+--------------+-------+--------+
| A            | 01/01/2021 | curry        | 15    | N      |
| A            | 01/01/2021 | sushi        | 10    | N      |
| A            | 07/01/2021 | curry        | 15    | Y      |
| A            | 10/01/2021 | ramen        | 12    | Y      |
| A            | 11/01/2021 | ramen        | 12    | Y      |
| A            | 11/01/2021 | ramen        | 12    | Y      |
| B            | 01/01/2021 | curry        | 15    | N      |
| B            | 02/01/2021 | curry        | 15    | N      |
| B            | 04/01/2021 | sushi        | 10    | N      |
| B            | 11/01/2021 | sushi        | 10    | Y      |
| B            | 16/01/2021 | ramen        | 12    | Y      |
| B            | 01/02/2021 | ramen        | 12    | Y      |
| C            | 01/01/2021 | ramen        | 12    | N      |
| C            | 01/01/2021 | ramen        | 12    | N      |
| C            | 07/01/2021 | ramen        | 12    | N      |
+--------------+------------+--------------+-------+--------+


-- Bonus Question 2

WITH CTE AS (
SELECT 
S."customer_id",
S."order_date",
M."product_name",
M."price",
(CASE
WHEN MEM."join_date" is NULL THEN 'N'
WHEN MEM."join_date">S."order_date" THEN 'N'
ELSE 'Y'
END)
AS "member",
FROM sales AS S
LEFT JOIN menu AS M
USING("product_id")
LEFT JOIN members AS MEM
USING("customer_id")
ORDER BY S."customer_id",S."order_date",M."price" DESC
)

SELECT 
*, 
CASE 
 WHEN "member" = 'N' THEN NULL
 ELSE RANK() OVER (PARTITION BY "customer_id", "member" ORDER BY "order_date") END AS "ranking"
FROM CTE

+--------------+------------+--------------+-------+--------+---------+
| customer_id  | order_date | product_name | price | member | ranking |
+--------------+------------+--------------+-------+--------+---------+
| A            | 01/01/2021 | sushi        | 10    | N      | NULL    |
| A            | 01/01/2021 | curry        | 15    | N      | NULL    |
| A            | 07/01/2021 | curry        | 15    | Y      | 1       |
| A            | 10/01/2021 | ramen        | 12    | Y      | 2       |
| A            | 11/01/2021 | ramen        | 12    | Y      | 3       |
| A            | 11/01/2021 | ramen        | 12    | Y      | 3       |
| B            | 01/01/2021 | curry        | 15    | N      | NULL    |
| B            | 02/01/2021 | curry        | 15    | N      | NULL    |
| B            | 04/01/2021 | sushi        | 10    | N      | NULL    |
| B            | 11/01/2021 | sushi        | 10    | Y      | 1       |
| B            | 16/01/2021 | ramen        | 12    | Y      | 2       |
| B            | 01/02/2021 | ramen        | 12    | Y      | 3       |
| C            | 01/01/2021 | ramen        | 12    | N      | NULL    |
| C            | 01/01/2021 | ramen        | 12    | N      | NULL    |
| C            | 07/01/2021 | ramen        | 12    | N      | NULL    |
+--------------+------------+--------------+-------+--------+---------+






