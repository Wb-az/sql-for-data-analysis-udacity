-- 4.13 GROUP BY

SELECT account_id,
	SUM(standard_qty)AS standard_sum,
	SUM(gloss_qty) AS gloss_sum,
	SUM(poster_qty) AS poster_sum

FROM orders
GROUP BY account_id -- same as the select
ORDER BY account_id;


-- QUIZZ GROUP BY

--  1. Which account (by name) placed the earliest order? Your solution should have the account 
	-- name and the date of the order.
  
SELECT a.name, o.occurred_at 
	FROM accounts a
	JOIN orders o ON a.id = o.account_id
ORDER BY occurred_at 
LIMIT 1;

--  2. Find the total sales in usd for each account. You should include two columns - the total sales 
-- for each company's orders in usd and the company name.

SELECT a.name, SUM(o.total_amt_usd) total
	FROM orders o
	JOIN accounts a 
	ON a.id = o.account_id
	GROUP BY a.name
	ORDER BY a.name;


-- 3. Via what channel did the most recent (latest) web_event occur, which account was associated with 
-- this web_event? Your query should return only three values - the date, channel, and account name.

SELECT w.occurred_at, w.channel, a.name
	FROM web_events w
	JOIN accounts a ON w.account_id = a.id
	ORDER BY occurred_at DESC
LIMIT 1;

-- 4. Find the total number of times each type of channel from the web_events was used. Your final 
	-- table should have two columns - the channel and the number of times the channel was used.

SELECT channel, COUNT(channel)
FROM web_events
GROUP BY channel; -- aggregatations on the group clause


-- 5. Who was the primary contact associated with the earliest web_event?

SELECT a.primary_poc
FROM accounts a
JOIN web_events w ON a.id = w.account_id
ORDER BY w.occurred_at 
LIMIT 1;


-- 6. What was the smallest order placed by each account in terms of total usd. Provide only two columns - 
-- the account name and the total usd. Order from smallest dollar amounts to largest.

SELECT a.name, min(o.total_amt_usd) smaller_dollar_amt
FROM orders o
JOIN accounts a ON o.account_id = a.id
GROUP BY a.name
ORDER BY smaller_dollar_amt;

-- 7. Find the number of sales reps in each region. Your final table should have two columns - 
-- the region and the number of sales_reps. Order from fewest reps to most reps.


SELECT r.name, COUNT(*) sales_rep_count
FROM sales_reps s
JOIN region r ON s.region_id = r.id
GROUP BY r.name
ORDER BY sales_rep_count

-- 4.17 QUIZZ GRUP BY Part - II

-- 1. For each account, determine the average amount of each type of paper 
-- they purchased across their orders. Your result should have four columns 
-- - one for the account name and one for the average quantity purchased 
-- for each of the paper types for each account.

SELECT a.name, AVG(o.standard_qty) AS standard_avg_qty,
	AVG(o.poster_qty) AS poster_avg_qty,
	AVG(o.gloss_qty) AS gloss_avg_qty 
FROM orders o
JOIN accounts a ON o.account_id = a.id
GROUP BY a.name;
	

-- 2. For each account, determine the average amount spent per order on each 
-- paper type. Your result should have four columns - one for the account name and 
-- one for the average amount spent on each paper type.

SELECT a.name, round(AVG(o.standard_amt_usd), 2) AS standard_avg_usd,
	AVG(o.poster_amt_usd) AS poster_avg_usd,
	AVG(o.gloss_amt_usd) AS gloss_amt_usd
FROM orders o
JOIN accounts a ON o.account_id = a.id
GROUP BY a.name

	
-- 3. Determine the number of times a particular channel was used in the web_events 
-- table for each sales rep. Your final table should have three columns - the name of 
-- the sales rep, the channel, and the number of occurrences. Order your table with the 
-- highest number of occurrences first.	

SELECT s.name, w.channel, COUNT(w.channel) num_occurrences
FROM web_events w
	JOIN accounts a ON w.account_id = a.id
	JOIN sales_reps s ON a.sales_rep_id = s.id
GROUP BY s.name, w.channel
ORDER BY num_occurrences DESC

	
-- 4. Determine the number of times a particular channel was used in the 
-- web_events table for each region. Your final table should have three 
-- columns - the region name, the channel, and the number of occurrences.
-- Order your table with the highest number of occurrences first.

SELECT r.name, w.channel, COUNT(w.channel) num_occurrences
FROM web_events w
	JOIN accounts a ON w.account_id = a.id
	JOIN sales_reps s ON a.sales_rep_id = s.id
	JOIN region r ON s.region_id = r.id
GROUP BY r.name, w.channel
ORDER BY num_occurrences DESC

-- 4.19 Distinct

SELECT DISTINCT account_id, channel
FROM web_events
ORDER BY account_id

-- 4.20

-- 1. Use DISTINCT to test if there are any accounts associated with more than one region.
SELECT a.name, r.name
FROM accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
JOIN region r ON s.region_id = r.id
ORDER BY a.name, r.name



SELECT DISTINCT id, name -- their sol
FROM accounts;


SELECT  -- their sol
a.name as "account name", r.name as "region name"
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
JOIN region r
ON r.id = s.region_id
ORDER BY a.name, r.name;


-- 2. Have any sales reps worked on more than one account?

SELECT DISTINCT s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
GROUP BY s.name
ORDER BY num_accounts;


SELECT s.id, s.name, COUNT(*) num_accounts --theirs
FROM accounts a
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.id, s.name
ORDER BY num_accounts, s.name;

SELECT DISTINCT id, name --theirs
FROM sales_reps;

-- 4.22 HAVING

SELECT account_id, SUM(total_amt_usd) AS sum_total_amt_usd
FROM orders
GROUP BY 1
HAVING SUM(total_amt_usd) >= 250000
ORDER BY 2 DESC -- col 2


-- 4.23


-- 1. How many of the sales reps have more than 5 accounts that they manage?

SELECT s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
GROUP BY s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts


-- subquery option
SELECT COUNT(*) num_reps_above5
FROM(SELECT s.name, COUNT(*) num_accounts
FROM accounts a
JOIN sales_reps s ON a.sales_rep_id = s.id
GROUP BY s.name
HAVING COUNT(*) > 5
ORDER BY num_accounts) AS Table1;

-- 2. How many accounts have more than 20 orders?

SELECT COUNT (*) accounts_with_over_20_orders
FROM (SELECT a.name, COUNT(*) counts
FROM accounts a
JOIN orders o ON a.id = o.account_id
GROUP BY a.name
HAVING COUNT(*) > 20
ORDER BY counts) AS Table1;

SELECT a.id, a.name, COUNT(*) num_orders -- their solution
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING COUNT(*) > 20
ORDER BY num_orders;

-- 3. Which account has the most orders?
SELECT a.name, COUNT(*) num_orders
FROM accounts a
JOIN orders o ON a.id = o.account_id
GROUP BY a.name
ORDER BY num_orders DESC
LIMIT 1

SELECT a.id, a.name, COUNT(*) num_orders -- their
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY num_orders DESC
LIMIT 1;


-- 4. Which accounts spent more than 30,000 usd total across all orders?

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spend 
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) > 30000
ORDER BY total_spend DESC;


-- 5. Which accounts spent less than 1,000 usd total across all orders?

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spend
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
HAVING SUM(o.total_amt_usd) < 1000
ORDER BY total_spend DESC;

-- 6. Which account has spent the most with us?
SELECT a.id, a.name, SUM(o.total_amt_usd) total_spend 
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spend DESC
LIMIT 1;

-- 7. Which account has spent the least with us?

SELECT a.id, a.name, SUM(o.total_amt_usd) total_spend 
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY total_spend
LIMIT 1;

-- 8. Which accounts used facebook as a channel to contact customers more than 6 times?
SELECT a.id, a.name, w.channel, count(*) channel_usage-- their
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
HAVING COUNT(*) > 6
ORDER BY channel_usage;

-- HAVING COUNT(*) > 6 AND w.channel = 'facebook'

-- 9. Which account used facebook most as a channel?
SELECT a.id, a.name, w.channel, count(*) channel_usage-- their
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
WHERE w.channel = 'facebook'
GROUP BY a.id, a.name, w.channel
ORDER BY channel_usage DESC
LIMIT 1;


-- 10. Which channel was most frequently used by most accounts?

SELECT a.id, a.name, w.channel, count(*) channel_usage
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY  a.id, a.name, w.channel
ORDER BY channel_usage DESC;


SELECT w.channel, count(*) channel_usage
FROM accounts a
JOIN web_events w
ON a.id = w.account_id
GROUP BY w.channel
ORDER BY channel_usage DESC;


-- 4.25 DATES YYYY MM DD DB,  Us MM DD YY, REST of the world DD MM YYYY

SELECT DATE_TRUNC('day', occurred_at) as day_of_the_week,
SUM(standard_qty) AS standard_qty_sum
FROM orders
GROUP BY DATE_TRUNC('day', occurred_at)
ORDER BY DATE_TRUNC('day', occurred_at);


SELECT DATE_PART('down', occurred_at) AS day_of_the_week,
SUM(total) AS total_qty
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- ALTER TABLE orders
--     ALTER COLUMN occurred_at 
--     TYPE TIMESTAMP WITH TIME ZONE
--         USING occurred AT TIME ZONE 'UTC'


-- 4.27 QUIZZ dates

-- 1. Find the sales in terms of total dollars for all orders in each year, ordered 
-- from greatest to least. Do you notice any trends in the yearly sales totals?

SELECT DATE_TRUNC('year', occurred_at) as year, sum(total_amt_usd) --includ 00 tome stamp
FROM orders
GROUP BY 1
ORDER BY 2 DESC;


SELECT DATE_PART('year', occurred_at) ord_year,  SUM(total_amt_usd) total_spent -- extracts only the year
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Which month did Parch & Posey have the greatest sales in terms of total dollars? 
-- 	Are all months evenly represented by the dataset?

SELECT DATE_PART('month', occurred_at) ord_month,  SUM(total_amt_usd) total_spent -- extracts only the year
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01' -- to make representation even
GROUP BY 1
ORDER BY 2 DESC;


-- 3. Which year did Parch & Posey have the greatest sales in terms of total number of orders? 
-- 	Are all years evenly represented by the dataset?
SELECT DATE_PART('year', occurred_at) ord_year,  COUNT(*) total_orders 
FROM orders
--WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01' -- to make representation even
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- 4. Which month did Parch & Posey have the greatest sales in terms of total number of orders? 
-- 	Are all months evenly represented by the dataset?

SELECT DATE_PART('month', occurred_at) ord_month,  COUNT(*) total_orders 
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01' -- to make representation even
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


-- 5. In which month of which year did Walmart spend the most on gloss paper in terms of dollars?

SELECT DATE_TRUNC('month', o.occurred_at) ord_month, a.name, SUM(o.gloss_amt_usd) total_gloss 
FROM orders o
JOIN accounts a 
ON o.account_id = a.id
WHERE a.name LIKE 'Walmart'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1;

SELECT DATE_TRUNC('month', o.occurred_at) ord_date, SUM(o.gloss_amt_usd) tot_spent
FROM orders o 
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- 4.29 CASE STATEMENTS LIKE IF

SELECT id, account_id, occurred_at, channel, 
	CASE WHEN channel = 'facebook' OR channel = 'direct' THEN 'yes' ELSE 'no' END AS is_facebook
FROM web_events
ORDER BY occurred_at


SELECT id, account_id, occurred_at, total, 
	CASE WHEN total > 500 THEN 'Over 500'
		WHEN total > 300 AND total <= 500 THEN '301 - 500'
		WHEN total > 100 AND total <= 300 THEN '101 - 500'
		ELSE '100 OR UNDER' END AS total_group
FROM orders

	

-- prevent error for zero division
SELECT account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;

-- 4.30 CASE& Aggregations

SELECT CASE WHEN total > 500 THEN 'Over 500'
	ELSE '500 or less' END AS total_group,
	COUNT(*) AS order_count
 FROM orders
GROUP BY 1


-- 4.31 QUIZZ CASE

-- 1. Write a query to display for each order, the account ID, total amount of the order, and the 
-- level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or 
-- more, or smaller than $3000.

SELECT account_id, total_amt_usd, 
	CASE WHEN orders.total_amt_usd >= 3000 THEN 'Large'
	ELSE 'Small' END AS order_level
	FROM orders;
	

-- 2. Write a query to display the number of orders in each of three categories, based on the total 
-- 	number of items in each order. The three categories are: 'At Least 2000', 'Between 1000 and 
-- 	2000' and 'Less than 1000'.

SELECT  COUNT(*) order_count,  -- the order can be inverted
	CASE WHEN total >= 2000 THEN 'At least 2000'
		WHEN total < 2000  AND total >= 1000 THEN 'Between 1000 and 2000'
		ELSE 'Less than 1000' END AS order_category
FROM orders
GROUP BY 2



-- 3. We would like to understand 3 different levels of customers based on the amount associated with 
-- 	their purchases. The top level includes anyone with a Lifetime Value 
-- 	(total sales of all orders) greater than 200,000 usd. The second level is between 
-- 	200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. Provide a table 
-- 	that includes the level associated with each account. You should provide the account name, 
-- 	the total sales of all orders for the customer, and the level. Order with the top spending 
-- 	customers listed first.


SELECT a.name, SUM(total_amt_usd) total_spent,
	CASE WHEN SUM(o.total_amt_usd) > 200000 THEN '1st level'
		WHEN SUM(o.total_amt_usd) < 200000 AND SUM(o.total_amt_usd) <= 100000 THEN '2nd level'
		ELSE '3rd level' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id  = a.id 
GROUP BY a.name
ORDER BY 2 DESC;


-- 4. We would now like to perform a similar calculation to the first, but we want to obtain the total 
-- 	amount spent by customers only in 2016 and 2017. Keep the same levels as in the previous 
-- 	question. Order with the top spending customers listed first.

SELECT a.name, DATE_PART('year', o.occurred_at) date, SUM(total_amt_usd) total_spent,
	CASE WHEN SUM(o.total_amt_usd) > 200000 THEN '1st level'
		WHEN SUM(o.total_amt_usd) < 200000 AND SUM(o.total_amt_usd) <= 100000 THEN '2nd level'
		ELSE '3rd level' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
WHERE o.occurred_at > '2015-12-31'
GROUP BY 1, 2
ORDER BY 3 DESC;


SELECT a.name, SUM(total_amt_usd) total_spent, 
        CASE WHEN SUM(total_amt_usd) > 200000 THEN 'top'
        WHEN  SUM(total_amt_usd) > 100000 THEN 'middle'
        ELSE 'low' END AS customer_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id
WHERE occurred_at > '2015-12-31' 
GROUP BY 1
ORDER BY 2 DESC;


-- 5. We would like to identify top performing sales reps, which are sales reps associated with more 
	-- than 200 orders. Create a table with the sales rep name, the total number of orders, and a 
	-- column with top or not depending on if they have more than 200 orders. Place the top sales 
	-- people first in your final table.

SELECT s.name, COUNT(*) total_orders,
	CASE WHEN COUNT(*) > 200 THEN 'TOP'
	ELSE 'NO TOP' END AS sales_performance
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 2 DESC;


-- 6. The previous didn't account for the middle, nor the dollar amount associated with the sales. 
	-- Management decides they want to see these characteristics represented as well. 
	-- We would like to identify top performing sales reps, which are sales reps associated with 
	-- more than 200 orders or more than 750000 in total sales. The middle group has any rep with 
	-- more than 150 orders or 500000 in sales. Create a table with the sales rep name, 
	-- the total number of orders, total sales across all orders, and a column with top, middle, 
	-- or low depending on this criteria. Place the top sales people based on dollar amount of 
	-- sales first in your final table. You might see a few upset sales people by this criteria!

SELECT s.name, COUNT(*) total_orders, SUM(total_amt_usd) total_sales,
	CASE WHEN COUNT(*) > 200 OR SUM(total_amt_usd) > 75000 THEN 'Top'
	WHEN COUNT(*) <= 200 AND COUNT(*) > 150 OR SUM(total_amt_usd) > 75000 THEN 'Middle'
	ELSE 'bottom' END AS sales_performance
FROM orders o
JOIN accounts a
ON o.account_id = a.id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 3 DESC;


SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent, 
        CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
        WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
        ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;






























