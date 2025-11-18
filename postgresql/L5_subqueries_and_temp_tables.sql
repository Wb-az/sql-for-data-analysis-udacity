-- 5.3 QUIZZ


-- 1. FINd the number of events that occurred each day for channel and create a subquery that provides all the data
-- for the first query. 

SELECT DATE_TRUNC('day', occurred_at ) AS day, channel, COUNT(*) events
	FROM web_events 
	GROUP BY 1, 2
	ORDER BY 3 DESC;
	
-- 2. Find the average number of events for each channel since  you broke out by day earlier 
-- 	this is given yu an average per day

SELECT *
FROM (
	SELECT DATE_TRUNC('day', occurred_at ) AS day, channel, COUNT(*) events
	FROM web_events 
	GROUP BY 1, 2
	ORDER BY 3 DESC
	) AS table1; --subquery

-- 3. FULL New table with subquery

SELECT channel, AVG(events) avg_event_per_channel
FROM (
	SELECT DATE_TRUNC('day', occurred_at ) AS day, channel, COUNT(*) events
	FROM web_events 
	GROUP BY 1, 2
	) AS table1
GROUP BY 1
ORDER BY 2 DESC;


-- 5.6 More subqueries
SELECT * FROM orders
	WHERE DATE_TRUNC('month', occurred_at) =
(SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
	FROM orders) 
 ORDER BY occurred_at



-- 5.7 Quizz subqueries
-- 1.0
SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
	FROM orders;


-- 2. Use the quary only to find only the orders that took place  in the sam month 
-- 	an the year as the first order and then pull the average for each type OF
-- paper for this MONTH


SELECT * FROM orders
	WHERE DATE_TRUNC('month', occurred_at) =
(SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
	FROM orders);


SELECT AVG(standard_qty) as avg_std_qty, AVG(gloss_qty) as avg_gloss,
	AVG(poster_qty) as avg_poster, SUM (total_amt_usd) AS Total
	FROM orders
	WHERE DATE_TRUNC('month', occurred_at) =
(SELECT DATE_TRUNC('month', MIN(occurred_at)) AS min_month
	FROM orders); 


-- 5.9 Quiz Subquery Mania

-- 1.Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.

-- get sales name
SELECT s.name sales_rep, r.name region, SUM(o.total_amt_usd) total_amt
	FROM orders o
	JOIN accounts a ON o.account_id = a.id
	JOIN sales_reps s ON a.sales_rep_id = s.id
	JOIN region r ON s.region_id = r.id
GROUP BY 1, 2
ORDER BY 3 DESC; 


-- region max amount
SELECT region, MAX(total_amt) total_amt
	FROM(SELECT s.name sales_rep, r.name region, SUM(o.total_amt_usd) total_amt
		FROM orders o
		JOIN accounts a ON o.account_id = a.id
		JOIN sales_reps s ON a.sales_rep_id = s.id
		JOIN region r ON s.region_id = r.id
		GROUP BY 1, 2) t1
	GROUP BY 1;
	

SELECT t3.sales_rep, t3.region, t3.total_amt
FROM (SELECT region, MAX(total_amt) total_amt
	FROM(SELECT s.name sales_rep, r.name region, SUM(o.total_amt_usd) total_amt
		FROM orders o
		JOIN accounts a ON o.account_id = a.id
		JOIN sales_reps s ON a.sales_rep_id = s.id
		JOIN region r ON s.region_id = r.id
		GROUP BY 1, 2) t1
	GROUP BY 1) t2
JOIN (SELECT s.name sales_rep, r.name region, SUM(o.total_amt_usd) total_amt
		FROM orders o
		JOIN accounts a ON o.account_id = a.id
		JOIN sales_reps s ON a.sales_rep_id = s.id
		JOIN region r ON s.region_id = r.id
		GROUP BY 1, 2
		ORDER BY 3 DESC) t3
ON t3.region = t2.region AND t3.total_amt = t2.total_amt
	
      
/* 2.For the region with the largest (sum) of sales total_amt_usd, how many total (count) 
orders were placed? */     

-- 1. q
SELECT r.name region, SUM(o.total_amt_usd) total_amt
	FROM orders o
	JOIN accounts a ON o.account_id = a.id
	JOIN sales_reps s ON a.sales_rep_id = s.id
	JOIN region r ON s.region_id = r.id
GROUP BY 1; 

--2 q 

SELECT MAX(total_amt)
FROM (SELECT r.name region, SUM(o.total_amt_usd) total_amt
	FROM orders o
	JOIN accounts a ON o.account_id = a.id
	JOIN sales_reps s ON a.sales_rep_id = s.id
	JOIN region r ON s.region_id = r.id
GROUP BY 1) sub;

-- Pull together

SELECT r.name region, COUNT(o.total) total_count
	FROM orders o
	JOIN accounts a ON o.account_id = a.id
	JOIN sales_reps s ON a.sales_rep_id = s.id
	JOIN region r ON s.region_id = r.id
	GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT MAX(total_amt)
FROM (SELECT r.name region, SUM(o.total_amt_usd) total_amt
	FROM orders o
	JOIN accounts a ON o.account_id = a.id
	JOIN sales_reps s ON a.sales_rep_id = s.id
	JOIN region r ON s.region_id = r.id
GROUP BY 1) sub);


/*3 How many accounts had more total purchases than the account name which
which has bought the most standard_qty paper throughout their lifetime as a customer? */

--1. Find the account that had the most standard_qty paper
SELECT a.name account_name, SUM(o.standard_qty) total_std,  SUM(o.total) total
	FROM orders o
	JOIN accounts a ON o.account_id = a.id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 1
	
--2 Pull all the accounts with more total sales:

SELECT a.name FROM orders o
	JOIN accounts a
	ON o.account_id = a.id
	GROUP BY 1 
	HAVING SUM(o.total) > (SELECT total 
	FROM (SELECT a.name account_name, SUM(o.standard_qty) total_std,  
	SUM(o.total) total
	FROM orders o
	JOIN accounts a ON o.account_id = a.id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 1) sub);
	
--This is now a list of all the accounts with more total orders. 
-- We can get the count with just another simple subquery.


SELECT COUNT(*)
FROM(SELECT a.name FROM orders o
	JOIN accounts a
	ON o.account_id = a.id
	GROUP BY 1 
	HAVING SUM(o.total) > (SELECT total 
	FROM (SELECT a.name account_name, SUM(o.standard_qty) total_std,  
	SUM(o.total) total
	FROM orders o
	JOIN accounts a ON o.account_id = a.id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 1) sub)) counter_table;


/* 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, 
how many web_events did they have for each channel? */


SELECT a.name customer, a.id, SUM(o.total_amt_usd) total_exp
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1; 
         
   
SELECT a.name customer, w.channel, COUNT(w.channel) counts
FROM accounts a
JOIN web_events w
ON a.id = w.account_id 
         AND a.id = (SELECT id         
FROM(SELECT a.name customer, a.id id, SUM(o.total_amt_usd) total_exp
FROM orders o
JOIN accounts a
ON o.account_id = a.id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;


/* 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total 
spending accounts? */

         
SELECT AVG(total_exp)     
FROM (
/*get the sum for account*/
SELECT a.id, a.name, SUM(o.total_amt_usd) total_exp
FROM orders o
JOIN accounts a ON o.account_id = a.id
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10) inner_tb;

        
 
/*6. What is the lifetime average amount spent in terms of total_amt_usd, 
including only the companies that spent more per order, on average, than 
the average of all orders. */

         
/* get the overal avg */
SELECT AVG(o.total_amt_usd)
FROM orders o;

/* avg per company */

SELECT o.account_id, AVG(o.total_amt_usd) avg_above
FROM orders o
GROUP BY 1
/* Filters where the cust avg is greater than overal avg */
HAVING AVG(o.total_amt_usd) > /* get the overal avg */
	(SELECT AVG(o.total_amt_usd) overall_avg
	FROM orders o);

/* Avg of the companies above the overall avg */

SELECT AVG(avg_above)
FROM (SELECT o.account_id, AVG(o.total_amt_usd) avg_above
FROM orders o
GROUP BY 1
HAVING AVG(o.total_amt_usd) >
	(SELECT AVG(o.total_amt_usd) overall_avg
	FROM orders o)) t1;


---5.11 WITH Statment Common Table Expressions

WITH events AS (
	SELECT DATE_TRUNC('day', occurred_at ) AS day, channel, COUNT(*) event_count
	FROM web_events 
	GROUP BY 1, 2
	) 

SELECT channel, AVG(event_count) avg_event_count
FROM events
GROUP BY 1
ORDER BY 2 DESC;
