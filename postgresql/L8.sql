-- 8.3 Full outer join

Select * from sales_reps s
FULL JOIN accounts a
ON s.id = a.sales_rep_id
WHERE s.id is NULL OR a.sales_rep_id is NULL; --Extra No ummatch rows


-- 8.5 Inequality JOIN (aka comporison operators)

SELECT o.id, o.occurred_at AS order_date, w.*
FROM orders o
LEFT JOIN web_events w
ON w.account_id = o.account_id
AND w.occurred_at < o.occurred_at
WHERE DATE_TRUNC('month', o.occurred_at) =
	(SELECT DATE_TRUNC('month', MIN(o.occurred_at)) 
	FROM orders o)
	ORDER BY o.account_id, o.occurred_at;

/* Expert Tip

The join clause is evaluated before the where clause -- filtering in the join clause 
will eliminate rows before they are joined, while filtering in the WHERE clause will leave those 
rows in and produce some nulls. */

/* 8.6 Write a query that left joins the accounts table and the sales_reps tables on each 
sale rep's ID number and joins it using the < comparison operator on accounts.primary_poc 
and sales_reps.name, like so: accounts.primary_poc < sales_reps.name 
The query results should be a table with three columns: the account name (e.g. Johnson Controls),
the primary contact name (e.g. Cammy Sosnowski), and the sales representative's name 
(e.g. Samuel Racine). Then answer the subsequent multiple choice question.*/

SELECT a.name account_name, a.primary_poc, s.name
FROM accounts a
LEFT JOIN sales_reps s
ON a.sales_rep_id = s.id 
AND a.primary_poc < s.name;


-- 8.8 SELF JOINS

SELECT o1.id AS o1_id,
		o1.account_id AS o1_account_id,
		o1.occurred_at AS o1_occurred_at, 
		o2.id AS o2_id,
		o2.account_id AS o2_account_id,
		o2.occurred_at AS o2_occurred_at
FROM orders o1
LEFT JOIN orders o2
ON o1.account_id = o2.account_id
AND o2.occurred_at > o1.occurred_at
AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at;


/* 8.9 One of the most common use cases for self JOINs is in cases where two events occurred, 
one after another. Using inequalities in conjunction with self JOINs is common. 
Modify the previous query to perform the same interval analysis except 
for the web_events table. Also: change the interval to 1 day to find those web events 
that occurred after, but not more than 1 day after, another web event
add a column for the channel variable in both instances of the table in your query */


SELECT w1.id AS web_id,
       w1.account_id AS w1_account_id,
       w1.occurred_at AS w1_occurred_at,
	   w1.channel AS w1_channel,
       w2.id AS w2_id,
       w2.account_id AS w2_account_id,
       w2.occurred_at AS w2_occurred_at,
	   w2.channel AS wb_channel
  FROM web_events w1
 LEFT JOIN web_events w2
   ON w1.account_id = w2.account_id
   AND w2.occurred_at > w1.occurred_at
   AND w2.occurred_at <= w1.occurred_at + INTERVAL '1 day'
ORDER BY w1.account_id, w1.occurred_at;


SELECT we1.id AS we_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we1.channel AS we1_channel,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at,
       we2.channel AS we2_channel
  FROM web_events we1 
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we1.occurred_at > we2.occurred_at
  AND we1.occurred_at <= we2.occurred_at + INTERVAL '1 day'
ORDER BY we1.account_id, we2.occurred_at;

		
-- 8.11 Performing Operations on a Combined Dataset
WITH web_events AS (SELECT *
FROM web_events as web_events_1

UNION ALL
SELECT * 
FROM web_events AS web_events_2)

SELECT channel, COUNT(*) AS sessions
FROM web_events
GROUP BY 1
ORDER BY 2 DESC;

/* 8.12A Appending Data via UNION Appending Data via UNION
Write a query that uses UNION ALL on two instances (and selecting all columns) 
of the accounts table. Then inspect the results and answer the subsequent quiz.
A. Without rewriting and running the query, how many results would be returned if
you used UNION instead of UNION ALL in the above query? */


With stacked_accounts AS (SELECT *
	FROM accounts a1
	
	UNION ALL
	
	SELECT * FROM accounts a2)

SELECT * FROM stacked_accounts;


/* 8.12 B Pretreating Tables before doing a UNION. Add a WHERE clause to each of the tables that
you unioned in the query above, filtering the first table where name equals Walmart and 
filtering the second table where name equals Disney. Inspect the results then answer 
the subsequent quiz.*/


With stacked_accounts AS (SELECT *
	FROM accounts a1
	WHERE a1.name = 'Walmart'
	
	UNION ALL
	
	SELECT * FROM accounts a2
	WHERE a2.name = 'Disney')

SELECT * FROM stacked_accounts;


/* 8.12C How else could the above query results be generated?*/

SELECT * FROM accounts
WHERE accounts.name = 'Disney' OR accounts.name = 'Walmart';

/* 8.12D Performing Operations on a Combined Dataset
Perform the union in your first query (under the Appending Data via UNION header) 
in a common table expression and name it double_accounts. Then do a COUNT the number of 
times a name appears in the double_accounts table. If you do this correctly, 
your query results should have a count of 2 for each name.*/


With double_count AS (SELECT *
	FROM accounts a1
	
	UNION ALL
	
	SELECT * FROM accounts a2)

SELECT name, COUNT(*) AS name_count
FROM double_count
GROUP BY 1
ORDER BY 2 DESC;


/* 8.15 Performance Tunning - reduce data . Filter to only include only waht you need  or use to test a query
in a subset of data. Aggregartion are undertaken befor the LIMIT,
Therefore the is not much benefit of it. It can help if t=it is used in a subquery
to test a query logic in a subset*/

SELECT account_id, 
	SUM(poster_qty) AS sum_poster_qty
	FROM(SELECT * FROM orders LIMIT 100) sub
WHERE occurred_at >='2016-01-01'
	AND occurred_at < '2016-07-01'
GROUP BY 1;


/* 8.16 Performance Tunning 2 using subquery - join less complecated
aggregate before joining, accuracy most important than speed*/

SELECT name, sub.web_events
FROM (SELECT account_id, COUNT(*) AS web_events
	FROM web_events events
	GROUP BY 1) sub
JOIN accounts a ON sub.account_id = a.id
ORDER BY 2 DESC;

/* 8.17 Performance Tuning 3 - EXPLAIN added to the begining of every query will
to get a sense ogf how long it would take - Query Plan is output - use for reference*/

EXPLAIN
SELECT * FROM orders
WHERE occurred_at  >= '2016-01-01'
AND occurred_at < '2016-02-01'
LIMIT 100;


/* 8.18 Joining Subqueries to Improve Performance */

-- 8.18A One Big Query - data explation

SELECT o.occurred_at AS date,
	a.sales_rep_id,
	o.id AS orders,
	we.id AS website
FROM accounts a
JOIN orders o
ON o.account_id = a.id
JOIN web_events we
ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
ORDER BY 1 DESC;


-- 8.18B Aggregate the table to prevent data explotion

SELECT DATE_TRUNC('day', o.occurred_at) AS date, -- first subquery
	COUNT(a.sales_rep_id) AS active_sales_reps,
	COUNT(o.id) AS orders
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1;

SELECT DATE_TRUNC('day', we.occurred_at) AS date, -- second subquery
	COUNT(we.id) AS web_visits
FROM web_events we
GROUP BY 1;


-- 8.18C Aggregate the table to prevent data explotion - COALESCE

SELECT COALESCE(orders.date, web_events.date) AS date,
	orders.active_sales_reps,
	orders.orders, web_events.web_visits
FROM (
SELECT DATE_TRUNC('day', o.occurred_at) AS date, -- first subquery
	COUNT(a.sales_rep_id) AS active_sales_reps,
	COUNT(o.id) AS orders
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1) orders

	FULL JOIN -- cature all dates in the table
(
SELECT DATE_TRUNC('day', we.occurred_at) AS date, -- second subquery
	COUNT(we.id) AS web_visits
FROM web_events we
GROUP BY 1) web_events
	ON web_events.date = orders.date
ORDER BY 1 DESC;




-- SELECT DATE_TRUNC('day', o.occurred_at) AS date,
-- 	COUNT(DISTINCT a.sales_rep_id) AS active_sales_reps,
-- 	COUNT(DISTINCT o.id) AS orders,
-- 	COUNT(DISTINCT we.id) AS website
-- FROM accounts a
-- JOIN orders o
-- ON o.account_id = a.id
-- JOIN web_events we
-- ON DATE_TRUNC('day', we.occurred_at) = DATE_TRUNC('day', o.occurred_at)
-- GROUP BY 1
-- ORDER BY 1 DESC;











