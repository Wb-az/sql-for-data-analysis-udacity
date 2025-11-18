-- 7.13 Aliases for Multiple Window Functions

/* Original query */
SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS count_total_amt_usd,
       AVG(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS min_total_amt_usd,
       MAX(total_amt_usd) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS max_total_amt_usd
FROM orders;


/* Query with alias */

SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER main_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER main_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER main_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER main_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER main_window  AS max_total_amt_usd
FROM orders
WINDOW main_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at));

-- 7.14 Quizz Aliases for Multiple Window Functions

/* 1. Using the example in the previous window, deconstruct the window function alias into its 
two parts: the alias part and the window function part. */

-- A. Alias part - WINDOW main_window AS
-- B. WINDOW - (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))

/* 2. Now, create and use an alias to shorten the following query (which is different 
than the previous 7.13) that has multiple window functions. 
Name the alias account_year_window, which is more descriptive than 
main_window in the example above. */


SELECT id,
       account_id,
       DATE_TRUNC('year',occurred_at) AS year,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at)) AS dense_rank,
       total_amt_usd,
       SUM(total_amt_usd) OVER account_year_window AS sum_total_amt_usd,
       COUNT(total_amt_usd) OVER account_year_window AS count_total_amt_usd,
       AVG(total_amt_usd) OVER account_year_window AS avg_total_amt_usd,
       MIN(total_amt_usd) OVER account_year_window AS min_total_amt_usd,
       MAX(total_amt_usd) OVER account_year_window  AS max_total_amt_usd
FROM orders
WINDOW account_year_window AS (PARTITION BY account_id ORDER BY DATE_TRUNC('year',occurred_at))


-- 7.16 Comparing a Row to Previous Row - LAG & LEAD

SELECT account_id,
       standard_sum,
       LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) AS lead,
       standard_sum - LAG(standard_sum) OVER (ORDER BY standard_sum) AS lag_difference,
       LEAD(standard_sum) OVER (ORDER BY standard_sum) - standard_sum AS lead_difference
FROM (
SELECT account_id,
       SUM(standard_qty) AS standard_sum
  FROM orders 
 GROUP BY 1
 ) sub;


-- 7.17 Quizz: Comparing a Row to Previous Row

/* Comparing a row to a previous or subsequent row technique can be useful when analyzing time-based events. 
Imagine you're an analyst at Parch & Posey and you want to determine how the current order's total 
revenue ("total" meaning from sales of all types of paper) compares to the next order's total revenue.
Modify query 7.16 to perform this analysis. You'll need to use occurred_at and total_amt_usd in 
the orders table along with LEAD to do so. In your query results, 
here should be four columns: occurred_at, total_amt_usd, lead, and lead_difference. */

SELECT occurred_at, total_amt_usd,
       LEAD(total_amt_usd) OVER (ORDER BY occurred_at) AS lead,
       LEAD(total_amt_usd) OVER (ORDER BY  occurred_at) - total_amt_usd AS lead_difference
FROM (
SELECT occurred_at,
       SUM(total_amt_usd) AS total_amt_usd
  FROM orders 
 GROUP BY 1
 ) sub;


-- 7.19 Percentiles

SELECT id, account_id, occurred_at, 
	standard_qty, 
	NTILE(4) OVER (ORDER BY standard_qty) AS quartile,
	NTILE(5) OVER (ORDER BY standard_qty) AS quintile,
	NTILE(100) OVER (ORDER BY standard_qty) AS percentile
FROM orders
ORDER BY standard_qty DESC;
	

/* Note: when you use a NTILE function but the number of rows in the partition is less 
than the NTILE(number of groups), then NTILE will divide the rows into as many 
groups as there are members (rows) in the set but then stop short of the requested
number of groups. If you’re working with very small windows, keep this 
in mind and consider using quartiles or similarly small bands.*/


-- 7.21 Quizz: Percentiles with Partitions

/*You can use partitions with percentiles to determine the percentile of a specific subset of all rows. 
Imagine you're an analyst at Parch & Posey and you want to determine the largest orders (in terms of quantity) 
a specific customer has made to encourage them to order more similarly sized large orders. 
You only want to consider the NTILE for that customer's account_id. Write three queries (separately) 
that reflect each of the following:

1. Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount 
of standard_qty for their orders. Your resulting table should have the account_id, 
the occurred_at time for each order, the total amount of standard_qty paper purchased, 
and one of four levels in a standard_quartile column.*/

SELECT account_id, occurred_at, standard_qty, 
	NTILE(4) OVER (PARTITION BY account_id ORDER BY standard_qty) AS standard_quartile
FROM orders
ORDER BY account_id DESC;


/*2. Use the NTILE functionality to divide the accounts into two levels in terms of 
the amount of gloss_qty for their orders. Your resulting table should have the account_id, 
the occurred_at time for each order, the total amount of gloss_qty paper purchased, and one 
of two levels in a gloss_half column.*/


SELECT account_id, occurred_at, gloss_qty, 
	NTILE(2) OVER (PARTITION BY account_id ORDER BY gloss_qty) AS gloss_half
FROM orders
ORDER BY account_id DESC;

/*3. Use the NTILE functionality to divide the orders for each account into 100 levels in terms of 
the amount of total_amt_usd for their orders. Your resulting table should have the account_id, 
the occurred_at time for each order, the total amount of total_amt_usd paper purchased, 
and one of 100 levels in a total_percentile column.
Note: To make it easier to interpret the results, order by the account_id in each of the queries*/

SELECT account_id, occurred_at, total_amt_usd, 
	NTILE(100) OVER (PARTITION BY account_id ORDER BY total_amt_usd) AS total_percentile
FROM orders
ORDER BY account_id DESC;
