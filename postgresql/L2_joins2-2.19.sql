
-- 2. JOINTS

SELECT orders.* --pulling info only from the orders table
	FROM orders
	JOIN accounts
	ON orders.account_id = accounts.id;

-- 2.4 

SELECT accounts.name, orders.occurred_at
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

SELECT * -- pulls all columns for both tables, equ to orders.*, accounts.*
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;

SELECT orders.standard_qty, orders.gloss_qty, orders.poster_qty,
	accounts.website, accounts.primary_poc
FROM orders
JOIN accounts
ON orders.account_id = accounts.id;


-- 2.9 JOINS Revisited


SELECT sales_reps.id, sales_reps.name, region.name FROM sales_reps
JOIN region ON sales_reps.region_id = region.id;


SELECT web_events.channel, accounts.name, orders.total
FROM web_events
JOIN accounts
ON web_events.account_id = accounts.id
JOIN orders
ON accounts.id = orders.account_id

-- 2.10 Using alias

-- Select t1.column1 aliasname, t2.column2 aliasname2
-- FROM tablename AS t1
-- JOIN tablename2 AS t2

-- 2.11 QUIZ JOIN
SELECT a.primary_poc, we.occurred_at, we.channel, a.name FROM web_events as we
JOIN accounts as a
ON we.account_id = a.id
WHERE a.name = 'Walmart';


SELECT r.name region, s.name rep, a.name account FROM accounts as a
JOIN sales_reps as s
ON a.sales_rep_id = s.id
JOIN region as r
ON s.region_id = r.id
ORDER BY a.name;

-- His
SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
ORDER BY a.name;


SELECT r.name region, a.name account, (o.total_amt_usd/(o.total + 0.01)) unit_price FROM orders as o
JOIN accounts as a
ON o.account_id = a.id
JOIN sales_reps as s
ON a.sales_rep_id = s.id
JOIN region as r
ON s.region_id = r.id;

-- His
SELECT r.name region, a.name account, 
           o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id;


-- 2.18 JOINS and FILTERING example

Select orders.*, accounts.*
	From orders
	LEFT JOIN accounts
	ON orders.account_id = accounts.id
WHERE accounts.sales_rep_id = 321500; 


Select orders.*, accounts.* -- before join execution
	From orders
	LEFT JOIN accounts
	ON orders.account_id = accounts.id 
	AND accounts.sales_rep_id = 321500; 


