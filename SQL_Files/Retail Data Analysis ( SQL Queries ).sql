
------------------------------------------------SQL CASE STUDY--------------------------------------------------------



-----------------------------------Data Preparation-------------------------------------------------------------------

-- Q1) What is the total number of rows in each of the 3 tables in the database?

-- Soln:

SELECT 'TRANSACTION' AS TABLE_NAME, COUNT(*) AS TOTAL_ROWS_IN_EACH_TABLE
FROM TRANSACTIONS
UNION ALL
SELECT 'PROD_CAT_INFO', COUNT(*) 
FROM prod_cat_info
UNION ALL
SELECT 'CUSTOMERS', COUNT(*) 
FROM Customer;


-- Q2) What is the total number of transactions that have a return?

-- Soln:

SELECT 'RETURNS' AS TRAN_STATUS, COUNT(*) AS TOT_NO_TRANSACTIONS
FROM Transactions
WHERE Qty<0;


-- Q3) As you would have noticed, the date provided across the dataset is not in the correct format. 
-- As first steps, pls convert the date variables into valid date formats before proceeding ahead..

-- Soln:

SELECT DOB, CONVERT(varchar(10), DOB,105) AS CONVERTED_DATE
FROM Customer;


-- Q4) What is the time range of the transaction data available for the analysis? Show the output in number of days, 
-- months and years simultaneously in different columns.

-- Soln:

SELECT 
DATEDIFF(DAY, MIN(TRAN_DATE) ,MAX(TRAN_DATE)) NO_DAYS ,
DATEDIFF(MONTH, MIN(TRAN_DATE),MAX(TRAN_DATE)) NO_MONTHS, 
DATEDIFF(YEAR, MIN(TRAN_DATE),MAX(TRAN_DATE)) NO_YEARS
FROM
Transactions;


-- Q5) Which product category does the sub-category 'DIY' belongs to?

-- Soln:

SELECT prod_cat
FROM prod_cat_info
WHERE prod_subcat= 'DIY';


------------------------------------------DATA ANALYSIS-----------------------------------------------------------------



-- Q1) Which channel is most frequently used for transactions?

-- Soln:

SELECT TOP 1
Store_type, COUNT(Store_type) AS TOT_CHANELS_TRANS
FROM Transactions
GROUP BY Store_type
ORDER BY TOT_CHANELS_TRANS DESC;


-- Q2) What is the count of Male and Female customers in the database?

-- Soln:
SELECT Gender, COUNT(Gender) AS TOTAL_NO_CUS
FROM Customer
GROUP BY Gender;


-- Q3) From which city do we have the maximum number of customers and how many?

-- Soln:

SELECT  TOP 1 City_Code, COUNT(city_code) AS TOT_NO_CUST
FROM Customer
GROUP BY city_code
ORDER BY TOT_NO_CUST DESC;


-- Q4) How many sub_categories are there under the Books category?

-- Soln:

SELECT prod_cat, COUNT(prod_subcat) as NO_SUB_CAT
FROM prod_cat_info
WHERE prod_cat = 'Books'
group by prod_cat;


-- Q5) What is the maximum quantity of products ever ordered?

-- Soln:

SELECT max(Qty) as Max_Qty
from 
Transactions
where Qty> 0;


-- Q6) What is the net total revenue generated in the categories of Electronics and Books?

-- Soln:

select
prod_cat, sum(total_amt) as Total_Amount
from
Transactions as a 
inner join prod_cat_info as b on a.prod_cat_code = b.prod_cat_code
where
prod_cat in ('electronics', 'books')
group by
prod_cat;


-- Q7) How many customers have >10 transactions with us, excluding returns?

-- Soln:

with cte1 as
(
select
cust_id, count(cust_id)  AS COUNT_CUSTOMERS
from
Transactions
group by
cust_id
having
count(cust_id)>10
)
select
count(cust_id) AS COUNT_CUSTOMERS
from
cte1;


-- Q8) What is the combined revenue earned from the 'Electronics' & 'Clothing' categories, from 'Flaghship stores'?

-- Soln:

SELECT  sum(total_amt) as Combined_Revenue_Earned
from
Transactions as a
inner join prod_cat_info  as b on a.prod_cat_code=b.prod_cat_code
where 
prod_cat in ('clothing' , 'electronics') and Store_type = 'flagship store';


-- Q9) What is the total revenue generated from 'Male' customers in 'Electronics' category? 
-- Output should display total revenue by prod sub-cat.

-- Soln:

SELECT 
sum(total_amt) as Revenue_Generated
FROM customer a
inner join Transactions b on a.customer_Id=b.cust_id
inner join prod_cat_info c on b.prod_cat_code=c.prod_cat_code
where
Gender= 'M' and prod_cat='Electronics'
group by 
prod_cat
order by 
Revenue_Generated;


-- Q10) What is the percentage of sales and returns by product sub category; 
-- display only the top 5 subcategories in terms of sales.

-- Soln:

with cte1 as
(SELECT 
sum(case
when total_amt > 0 then total_amt else 0 end) as total_sale ,
sum(case
when total_amt < 0 then total_amt else 0 end) as total_ret
from Transactions
)
select
prod_subcat_code, 
100.0 * sum(case when total_amt > 0 then total_amt else 0 end)/ (select total_sale from cte1)  Per_Sales,
100.0 * sum(case when total_amt < 0 then total_amt else 0 end) / (select total_ret from cte1)  Per_Returns
from
Transactions
group by
prod_subcat_code;


-- Q11) For all customers aged between 25 to 35 years find what is the net total revenue generated 
-- by these consumers in the last 30 days of the transaction from max transactions date available in the data?

-- Soln:

with cte1 as
(
select
*, datediff(YY,DOB,getdate()) as age, max(tran_date) over () as max_date
from
Transactions a
join
Customer b
on
a.cust_id = b.customer_Id
)
select
sum(total_amt) Tot_Revenue_Earned
from
cte1
where
tran_date >= dateadd(DAY, -30, max_date) 
and 
age between 25 and 35;


-- Q12) Which product category has seen the max value of returns in the last 3 months of the transaction?

-- Soln:

with cte1 as 
(Select prod_cat , sum(total_amt) as Tot_Ret_Amt, max(tran_date) as Max_Trans_Date
From transactions as t 
inner join prod_cat_info as p 
on t.prod_cat_code = p.prod_cat_code
Where 
total_amt < 0 
Group by prod_cat
) 
select
top 1
*
from
cte1
where
Max_Trans_Date >= dateadd(month, -3 , Max_Trans_Date)
order by
tot_ret_amt;


-- Q13) Which store type sells the maximum products; by value of sales amount and quantity sold?

-- Soln:

with cte1 as 
( 
select
store_type, max(total_amt) Max_Sales, max(qty) Max_Qty
from
Transactions
where
qty>0
group by
Store_type
),
cte2 as 
(
select
store_type, dense_rank() over (order by max_sales desc) dr
from
cte1
) 
select
store_type
from
cte2
where
dr = 1;


-- Q14) What are the categories for which average revenue is above the overall average?

-- Soln:

select 
prod_cat, avg(total_amt) Avg_Sal
from
Transactions a
inner join
prod_cat_info b
on
a.prod_cat_code = b.prod_cat_code
group by
prod_cat
having 
avg(total_amt) > (select avg(total_amt) tot_avg_amt from Transactions);


-- Q15) Find the average and total revenue by each subcategory for the categories which are 
-- among the top 5 categories in terms of quantity sold.

-- Soln:

select
prod_cat, prod_subcat_code, avg(total_amt) Avg_Revenue, sum(total_amt) Tot_Revenue
from
Transactions a
inner join prod_cat_info b on a.prod_cat_code=b.prod_cat_code
where
a.prod_cat_code in (
select
prod_cat_code
from
(
select
top 5
prod_cat_code, count(Qty) Tot_Qty
from
Transactions
group by
prod_cat_code
order by
tot_qty desc) as a
)
group by
prod_cat, prod_subcat_code
order  by
prod_cat, prod_subcat_code;


---------------------------------------------------------END--------------------------------------------------------------





















