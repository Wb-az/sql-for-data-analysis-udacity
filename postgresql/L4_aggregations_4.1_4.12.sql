-- 4.3 NULLS and Aggregations

SELECT *
FROM accounts
WHERE primary_poc IS NULL; -- null is aproperty but not a value therefere not =

SELECT *
FROM accounts
WHERE primary_poc IS NOT  NULL;

-- 4.4 COUNT

SELECT COUNT(*) as order_count
	FROM orders
	WHERE occurred_at >= '2016-12-01'
	AND occurred_at < '2017-01-01';

SELECT COUNT(*)
FROM accounts;

-- 4.5  Count & NULLS

SELECT COUNT(accounts.id)
FROM accounts;

SELECT COUNT(primary_poc)
FROM accounts;
	
SELECT *
FROM accounts
WHERE primary_poc IS NULL;

-- 3.7 SUM QUIZ only for numerical data

SELECT SUM(standard_qty) AS standard,
	SUM(gloss_qty) AS gloss, 
    SUM(poster_qty) AS poster
FROM orders;


-- 1. Find the total amount of poster_qty paper ordered in the orders table.

SELECT SUM(poster_qty) total_poster
FROM orders;

-- 2. Find the total amount of standard_qty paper ordered in the orders table.
SELECT SUM(standard_qty) total_poster
FROM orders;

-- 3. Find the total dollar amount of sales using the total_amt_usd in the orders table.
SELECT SUM(total_amt_usd) total_dollar
FROM orders;

-- 4. Find the total amount spent on standard_amt_usd and gloss_amt_usd paper 
-- 	for each order in the orders table. This should give a dollar amount for 
-- 	each order in the table.

SELECT standard_amt_usd + gloss_amt_usd total_amount_std_gloss
FROM orders;

-- 5. Find the standard_amt_usd per unit of standard_qty paper. 
-- 	Your solution should use both an aggregation and a mathematical operator.

SELECT SUM(standard_amt_usd)/SUM(standard_qty) total_amount_per_unit
FROM orders;

SELECT SUM(standard_amt_usd)/SUM(standard_qty) AS standard_price_per_unit
FROM orders;

-- 4.11 Min - MAx

SELECT Min(standard_qty) AS standard_min,
	min(poster_qty) AS poster_min,
	min(gloss_qty) AS gloss_min,
	max(standard_qty) AS standard_max,
	max(poster_qty) AS poster_max,
	max(gloss_qty) AS gloss_max
FROM orders;
 

-- AVERAGE
SELECT avg(standard_qty) AS standard_avg,
	avg(gloss_qty) AS gloss_avg,
	avg(poster_qty) AS poster_avg
FROM orders;


-- 4.11 QUIZZ AVG, MIN, MAX

-- 1. When was the earliest order ever placed? You only need to return the date.

SELECT MIN(occurred_at) earlier_order_date FROM orders;

-- 2. Try performing the same query as in question 1 without using an aggregation function.

SELECT occurred_at earlier_order_date FROM orders
	ORDER BY occurred_at LIMIT 1;

-- 3. When did the most recent (latest) web_event occur?
SELECT MAX(occurred_at) latest_web_event_date 
	FROM web_events;

-- 4. Try to perform the result of the previous query without using an aggregation function.
SELECT occurred_at latest_web_event_date 
	FROM web_events
	ORDER BY occurred_at DESC 
	LIMIT 1;

-- 5. Find the mean (AVERAGE) amount spent per order on each paper type, 
-- as well as the mean amount of each paper type purchased per order. Your final answer 
-- should have 6 values - one for each paper type for the average number of sales, 
-- as well as the average amount.

SELECT AVG(standard_amt_usd) AS standard_avg_usd,
	AVG(poster_amt_usd) AS poster_avg_usd,
	AVG(gloss_amt_usd) AS gloss_amt_usd,
	AVG(standard_qty) AS standard_avg_qty,
	AVG(poster_qty) AS poster_avg_qty,
	AVG(gloss_qty) AS gloss_avg_qty 
FROM orders;

-- 6. Via the video, you might be interested in how to calculate the MEDIAN. 
--	Though this is more advanced than what we have covered so far try finding 
-- - what is the MEDIAN total_usd spent on all orders?

--This is not the best approach
SELECT *
FROM (SELECT total_amt_usd
         FROM orders
         ORDER BY total_amt_usd
         LIMIT 3457) AS Table1 --half of the count 3456 & 3457 2483.16 and 2482.55. AVG 2482.855.
ORDER BY total_amt_usd DESC
LIMIT 2;


-- Median with percentile cont

SELECT 
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amt_usd) AS median
FROM
  orders
;

