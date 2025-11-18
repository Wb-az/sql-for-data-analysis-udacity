
-- 1.19

SELECT id, occurred_at, total_amt_usd FROM orders
ORDER BY occurred_at LIMIT 10;


SELECT id, account_id, total_amt_usd FROM orders
ORDER BY total_amt_usd DESC LIMIT 5;

SELECT id, account_id, total_amt_usd 
	FROM orders
	ORDER BY total_amt_usd 
	LIMIT 20;

-- ORDER Part II

SELECT account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC;


SELECT account_id, total_amt_usd
FROM orders
ORDER BY total_amt_usd DESC, account_id;


-- 1.22 ORDER BY

SELECT id, account_id, total_amt_usd
FROM orders 
ORDER BY account_id, total_amt_usd DESC;


SELECT id, account_id, total_amt_usd
FROM orders 
ORDER BY total_amt_usd DESC, account_id;

-- 1.25 WHERE before order

SELECT *
FROM orders
	WHERE gloss_amt_usd >= 1000
LIMIT 5; 


SELECT * FROM orders
WHERE total_amt_usd < 500
LIMIT 10

-- 1.27 WHERE with no numerical

SELECT name, website, primary_poc
	FROM accounts 
	WHERE name = 'Exxon Mobil';


SELECT name, website, primary_poc
	FROM accounts 
	WHERE name LIKE 'Exxon Mobil';


-- 1.31 Arithmetic Operators / Derived columns

SELECT id, (standard_amt_usd/total_amt_usd)*100 AS std_percent, total_amt_usd
FROM orders
LIMIT 10


SELECT id, account_id, (standard_amt_usd/standard_qty) AS unit_price 
FROM orders
LIMIT 10;


SELECT id, account_id, 
	poster_amt_usd/(standard_amt_usd + gloss_amt_usd + poster_amt_usd)*100 AS poster_percent
FROM orders
LIMIT 10;


-- Logical Operators
-- 1.35 LIKE

SELECT name
FROM accounts
WHERE name LIKE 'C%';

SELECT name
FROM accounts
WHERE name LIKE '%one%';

SELECT name
FROM accounts
WHERE name LIKE '%s';


-- IN 1.38

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom'); 

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords'); 


-- NOT 1.41

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name  NOT IN ('Walmart', 'Target', 'Nordstrom'); 

SELECT *
FROM web_events
WHERE channel NOT IN ('organic', 'adwords'); 

SELECT name
FROM accounts
WHERE name NOT LIKE 'C%';

SELECT name
FROM accounts
WHERE name NOT LIKE '%one%';

SELECT name
FROM accounts
WHERE name NOT LIKE '%s';


-- 1.44 AND and BETWEEN


SELECT *
FROM orders
WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0;

SELECT name
FROM accounts
WHERE name NOT LIKE 'C%' AND name LIKE '%s';

SELECT occurred_at, gloss_qty 
FROM orders
WHERE gloss_qty BETWEEN 24 AND 29;

SELECT *
FROM web_events
WHERE channel IN ('organic', 'adwords') AND occurred_at BETWEEN '2016-01-01' AND '2017-01-01'
ORDER BY occurred_at DESC;


-- 1.46 AND and BETWEEN


SELECT id
FROM orders
WHERE gloss_qty > 4000 OR poster_qty > 4000;


SELECT *
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);


SELECT * --My query
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') 
	AND (primary_poc NOT LIKE '%eana' 
	AND lower(primary_poc) 
	LIKE '%ana%');


SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') 
              AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') 
              AND primary_poc NOT LIKE '%eana%');


-- FIND size of table

select
  table_name,
  pg_size_pretty(pg_total_relation_size(quote_ident(table_name))),
  pg_total_relation_size(quote_ident(table_name))
from information_schema.tables
where table_schema = 'public'
order by 3 desc;

select count(*) from orders;
