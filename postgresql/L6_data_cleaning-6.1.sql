-- SQL Data Cleaning - general expressions

--6.3 quizz

/* 1. In the accounts table, there is a column holding the website for each company. 
	The last three digits specify what type of web address they are using. 
	A list of extensions (and pricing) is provided here(opens in a new tab). 
	Pull these extensions and provide how many of each website type exist in the accounts table. */

Select COUNT(*),
	RIGHT(website, 3) AS web_address
	--RIGHT(phone_number, LENGTH(phone_number) - 4) AS phone_number_alt
FROM accounts
GROUP BY web_address

/* 2. There is much debate about how much the name (or even the first letter of a company name)
(opens in a new tab) matters. Use the accounts table to pull the first letter of each 
company name to see the distribution of company names that begin with each letter (or number).*/

Select LEFT(UPPER(name), 1) AS company_initial, COUNT(*)
	--RIGHT(phone_number, LENGTH(phone_number) - 4) AS phone_number_alt
FROM accounts
GROUP BY company_initial
ORDER BY company_initial


/* 3. Use the accounts table and a CASE statement to create two groups: one group of 
company names that start with a number and a second group of those company 
names that start with a letter. What proportion of company names start with a letter? */

SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 1 ELSE 0 END AS num, 
            CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                          THEN 0 ELSE 1 END AS letter
         FROM accounts) t1;


/* 4. Consider vowels as a, e, i, o, and u. What proportion of company names 
start with a vowel, and what percent start with anything else? */

SELECT SUM(vowels) vowels, SUM(other) other, (SUM(vowels) + sum(other)) as total_count
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                           THEN 1 ELSE 0 END AS vowels, 
             CASE WHEN LEFT(UPPER(name), 1) IN ('A','E','I','O','U') 
                          THEN 0 ELSE 1 END AS other
            FROM accounts) t1;

--6.6 quizz

/* 1. Use the accounts table to create first and last name columns that hold the 
first and last names for the primary_poc. */

SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1) AS poc_name,
	RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name
FROM accounts;


/* 2.Now see if you can do the same thing for every rep name in the sales_reps table. 
Again provide first and last name columns.*/


SELECT LEFT(name, STRPOS(name, ' ') -1) AS poc_name,
	RIGHT(name, LENGTH(name) - STRPOS(name, ' ')) AS last_name
FROM sales_reps;


--6.9 Concat

/* 1. Each company in the accounts table wants to create an email address for each 
primary_poc. The email address should be the first name of the primary_poc . last name
primary_poc @ company name .com. use table of expressions*/ 

With tb1 as (SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1) AS poc_name,
	RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name,
	name
	FROM accounts)
SELECT concat(lower(poc_name), '.', lower(last_name), '@', lower(name), '.com') 
FROM tb1;
 

/* 2. You may have noticed that in the previous solution some of the company names 
include spaces, which will certainly not work in an email address. See if you can 
create an email address that will work by removing all of the spaces in the account name,
but otherwise your solution should be just as in question 1. Some helpful documentation 
is here(opens in a new tab).*/

With tb1 as (SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1) AS poc_name,
	RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name,
	-- replace(name, ' ', '') as name
	name
	FROM accounts)
SELECT first_name, last_name, concat(lower(poc_name), '.', lower(last_name), '@', 
	lower(replace(name, ' ', '')), '.com') 
FROM tb1;


/* 3. We would also like to create an initial password, which they will change after their
first log in. The first password will be the first letter of the primary_poc's first 
name (lowercase), then the last letter of their first name (lowercase), the first letter of 
their last name (lowercase), the last letter of their last name (lowercase), the number of 
letters in their first name, the number of letters in their last name, and then the name 
of the company they are working with, all capitalized with no spaces. */


With tb1 as (SELECT LEFT(primary_poc, STRPOS(primary_poc, ' ') -1) AS first_name,
	RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) AS last_name,
	-- replace(name, ' ', '') as name
	name
	FROM accounts)
SELECT first_name, last_name,
	concat(lower(first_name), '.', lower(first_name), '@', 
	lower(replace(name, ' ', '')), '.com'),
	concat(LEFT(lower(first_name), 1) || RIGHT(lower(first_name), 1) ||
	LEFT(lower(last_name), 1) || RIGHT(lower(last_name), 1))
FROM tb1;


-- 6.11 CAST

/* Write a query to look at the top 10 rows to understand the columns and the raw data
in the dataset called sf_crime_data. */

SELECT * FROM sf_crime_data2
LIMIT 10;


/* 2. Look at the date column at the sf_crime table. Notice the date is not in the 
correct format. Write a query to change the date into the correct SQL data format. 
Format of the data yyyy-mm-dd (correct format in sql). */

/*You will need to use at least substract
and concat to perform this opertion. Once you have created a colum in the correct format,
use either CAST or :: to convert this to a date.*/

--My solution 1

SELECT date original_date, (REPLACE(SUBSTR(date, 1,10), '/', '-'))::date  AS formatted_date
FROM sf_crime_data;
                                  
-- My solution 2 in two steps using concat                  
SELECT date original_date, CONCAT(RIGHT(SUBSTR(date, 1,10), 4), '-', LEFT(SUBSTR(date, 1, 5), 2),
'-', SUBSTR(date, 4,2))
FROM sf_crime_data;
            
SELECT date original_date, (CONCAT(RIGHT(SUBSTR(date, 1,10), 4), '-', LEFT(SUBSTR(date, 1, 5), 2),
			'-', SUBSTR(date, 4,2)))::date AS formatted_date 
FROM sf_crime_data;
                        

- udacity sol

SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2)) new_date
FROM sf_crime_data;
                                                       
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2))::DATE new_date
FROM sf_crime_data; 
                      

-- 6.15 Coalesce

/* 1. Run the Query below */

SELECT *
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;


/* 2. Use coalesce to fill the accounts.id column with account.id for 
the NULL value for table in 1. */

SELECT COALESCE(o.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, 
a.sales_rep_id, o.* 
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;


/* 3 Use coalesce to fill the orders.account_id column with account.id for 
the NULL value for table in 1. */

SELECT COALESCE(o.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, 
a.sales_rep_id, COALESCE(o.account_id,  a.id) account_id, o.occurred_at, 
o.standard_qty, o.gloss_qty, o.poster_qty, o.total, 
o.standard_amt_usd, o.gloss_amt_usd, o.poster_amt_usd, o.total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;


/*4 Use coalesce to fill each of the qty and usd columns with 0 for table 1. */

SELECT COALESCE(o.id, a.id) filled_id, a.name, a.website, 
a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id,  a.id) 
account_id, o.occurred_at, COALESCE(o.standard_qty,0) standard_qty, 
COALESCE(o.gloss_qty, 0) gloss_qty, COALESCE(o.poster_qty,0) poster_qty, 
COALESCE(o.total,0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, 
COALESCE(o.gloss_amt_usd, 0) gloss_amt_usd, COALESCE( o.poster_amt_usd,0) poster_amt_usd, 
COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;


/* 5. Run the query in 1 with WHERE removed and count the number of ids. */

SELECT COUNT(*)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;

/* 6. Run the query in 5 but with the coalescence functions used from 2 - 4 */

SELECT COALESCE(o.id, a.id) filled_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, 
COALESCE(o.account_id,  a.id) account_id, o.occurred_at, 
COALESCE(o.standard_qty,0) standard_qty, COALESCE(o.gloss_qty, 0) gloss_qty, 
COALESCE(o.poster_qty,0) poster_qty, COALESCE(o.total,0) total, 
COALESCE(o.standard_amt_usd,0) satandard_amt_usd, COALESCE(o.gloss_amt_usd, 0) gloss_amt_usd, 
COALESCE( o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id ;




                      



