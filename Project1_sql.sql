-- "----------------------------------------------------------------------------------------------------------------------------"

-- 													SQL Case study project	
use intq;		

CREATE TABLE credit_transaction (
    transaction_id INT,
    city VARCHAR(255),
    transaction_date DATE,
    card_type VARCHAR(50),
    exp_type VARCHAR(50),
    gender ENUM('M', 'F'),
    amount INT
);

set session sql_mode='';
LOAD DATA INFILE 'C:/credit_card_transcations.csv'
INTO TABLE credit_transaction
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(transaction_id, city, @transaction_date, card_type, exp_type, gender, amount)
SET transaction_date = STR_TO_DATE(@transaction_date, '%d-%b-%y');



select * from credit_transaction;
select min(transaction_date),max(transaction_date) from credit_transaction; -- 10-2013 - 05-2015
select distinct(card_type) from credit_transaction; -- card_type --> Gold,Platinum,Silver,Signature
select distinct(exp_type) from credit_transaction; 
/*
Entertainment
Food
Bills
Fuel
Travel
Grocery
*/
select distinct city from credit_transaction order by city; -- Almost all cities from India 

use intq;
/*
2- write a query to print highest spend month and amount spent in that month for each card type

4- write a query to find city which had lowest percentage spend for gold card type
5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
6- write a query to find percentage contribution of spends by females for each expense type
7- which card and expense type combination saw highest month over month growth in Jan-2014
9- during weekends which city has highest total spend to total no of transcations ratio 
10- which city took least number of days to reach its 500th transaction after the first transaction in that city

*/

-- 1- write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends
select * from credit_transaction where city = 'Delhi';

with cte1 as (
select city , sum(amount) as total_spend from credit_transaction group by city)
, total_spent as (select sum(amount) as total_amount from credit_transaction)
select cte1.*,total_amount,(total_spend*1.0/total_amount)*100 as percentage_contribution 
from cte1,total_spent order by total_spend desc limit 5;


-- 2- write a query to print highest spend month and amount spent in that month for each card type
select * from credit_transaction;

with cte as(
select card_type,year(transaction_date) as year_data,month(transaction_date) as month_data,sum(amount) as total_spend 
from credit_transaction group by card_type,year_data,month_data
-- order by card_type,total_spend desc
)
select * from(select *, rank() over(partition by card_type order by total_spend desc) as rn from cte)as rank_spend
where rn=1;

-- 3- write a query to print the transaction details(all columns from the table) for each card type when it 
-- reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)
select * from credit_transaction;
with cte as (
select *,sum(amount) over(partition by card_type order by transaction_date,transaction_id) as total_spend
from credit_transaction
-- order by card_type,total_spend desc
)
select * from(select *, rank() over(partition by card_type order by total_spend) as rn  
from cte where total_spend >= 1000000) as rank_t where rn=1;

-- 4 write a query to find city which had lowest percentage spend for gold card type
select * from credit_transaction;

with cte as(
select city,card_type, sum(amount) as amount,
sum(case when card_type='Gold' then amount end) as gold_amount
from credit_transaction
group by city,card_type)
select city,
(sum(gold_amount)*1.0/sum(amount))*100 as percent_spend_for_gold
from cte 
group by city 
having sum(gold_amount) is not null
order by percent_spend_for_gold;

-- 5- write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
use intq;
select * from credit_transaction;
