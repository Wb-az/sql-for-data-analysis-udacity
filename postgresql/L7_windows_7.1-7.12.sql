-- 7 Advanced -SQL Window Functions

--7.2 Example 1 OVER

Select standard_qty, -- aggregation without group by
	SUM(standard_qty) OVER(ORDER BY occurred_at) AS runing_total
FROM orders;


--7.2 Example 2 Using partition

Select standard_qty, -- aggregation without group by
	DATE_TRUNC('month', occurred_at) AS month,
	SUM(standard_qty) OVER(PARTITION BY DATE_TRUNC('month', occurred_at)
	ORDER BY occurred_at) AS running_total
FROM orders;

-- 7.3 Quizz
/*Using Derek's previous video as an example, create another running total. This time, create a 
running total of standard_amt_usd (in the orders table) over order time with no date truncation. 
Your final table should have two columns: one with the amount being added for each new row, 
and a second with the running total.*/

SELECT standard_amt_usd, SUM(standard_amt_usd) 
	OVER(ORDER BY occurred_at) AS running_total
FROM orders;

-- 7.5 Creating a Partitioned Running Total Using Window Functions

/*Now, modify your query from the previous quiz to include partitions. 
Still create a running total of standard_amt_usd (in the orders table) over order time, 
but this time, date truncate occurred_at by year and partition by that same 
year-truncated occurred_at variable. Your final table should have three 
columns: One with the amount being added for each row, one for the truncated date, 
and a final column with the running total within each year. */


SELECT standard_amt_usd, DATE_TRUNC('year', occurred_at), SUM(standard_amt_usd) 
	OVER(PARTITION BY DATE_TRUNC('year', occurred_at) 
	ORDER BY occurred_at) AS running_total
FROM orders;


-- 7.7 ROW_NUMBER & RANK

-- ROW_NUMBER

-- 1. In this example the row number is always equal to the id
SELECT id, account_id, occurred_at,
	ROW_NUMBER() OVER(ORDER BY id) AS row_num
FROM orders; 

-- 2. In this example the row number and the id differs
SELECT id, account_id, occurred_at,
	ROW_NUMBER() OVER(ORDER BY occurred_at) AS row_num
FROM orders; 

-- 3. Shows the row number within each account id where row 1 is the first order that occurred.
SELECT id, account_id, occurred_at,
	ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY occurred_at) AS row_num
FROM orders; 

-- RANK

/* 1. If two lines in a row have the same value for occurred_at, they are rank the same and
row number gives different numbers */

SELECT id, account_id, occurred_at,
	RANK() OVER(PARTITION BY account_id ORDER BY occurred_at) AS row_num
FROM orders; 

/* 2. If two lines in a row have the same value for occurred_at, they are rank the same. 
In this example the date is truncated by month. Entries of the same month are
given the same rank. It also skipped some values*/

SELECT id, account_id, DATE_TRUNC('month', occurred_at) as month,
	RANK() OVER(PARTITION BY account_id 
	ORDER BY DATE_TRUNC('month', occurred_at)) AS row_num
FROM orders; 


--DENSE_RANK

/* DENSE_RANK() does not skipped rank values, the query below go straigth from 
ranks order 1, 2, 3... */

SELECT id, account_id, DATE_TRUNC('month', occurred_at) as month,
	DENSE_RANK() OVER(PARTITION BY account_id 
	ORDER BY DATE_TRUNC('month', occurred_at)) AS row_num
FROM orders; 


-- 7.8 QUIZZ ROW_NUMBER & RANK

/*Select the id, account_id, and total variable from the orders table, then create a column 
called total_rank that ranks this total amount of paper ordered (from highest to lowest) 
for each account using a partition. Your final table should have these four columns. */

SELECT id, account_id, total,
	RANK() OVER(PARTITION BY account_id ORDER BY total DESC)
	AS total_rank
FROM orders

-- 7.10 Aggregates in Window Functions 

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id ORDER BY DATE_TRUNC('month',occurred_at)) AS max_std_qty
FROM orders

-- 7.11 Quizz: Aggregates in window functions

/*Now remove ORDER BY DATE_TRUNC('month',occurred_at) in each line of the query that contains it 
in the SQL Explorer below. Evaluate your new query, compare it to the results 
in the SQL Explorer above, and answer the subsequent quiz questions. */

SELECT id,
       account_id,
       standard_qty,
       DATE_TRUNC('month', occurred_at) AS month,
       DENSE_RANK() OVER (PARTITION BY account_id) AS dense_rank,
       SUM(standard_qty) OVER (PARTITION BY account_id) AS sum_std_qty,
       COUNT(standard_qty) OVER (PARTITION BY account_id) AS count_std_qty,
       AVG(standard_qty) OVER (PARTITION BY account_id) AS avg_std_qty,
       MIN(standard_qty) OVER (PARTITION BY account_id) AS min_std_qty,
       MAX(standard_qty) OVER (PARTITION BY account_id) AS max_std_qty
FROM orders
WHERE account_id  IN ('1001', '1011', '1021');

-- Q1 What is the value of dense_rank in every row for the following account_id values?
/*
account_id  | dense_rank
1001        | 1
1011        | 1
1021        | 1


-- Question 2 

What is the value of sum_std_qty in the first row for the following account_id values?

account_id  | sum_std_qty
1001        | 7896
1011        | 527
1021        | 3152


What is happening when you omit the ORDER BY clause when doing aggregates with window functions? 
Use the results from the queries above to guide your thoughts then jot these thoughts down in 
a few sentences in the text box below.

Your reflection:

The results are the same for all rows with the same account_id. The ORDER BY add an extra 
requirement to output results that occurred within a determined time.