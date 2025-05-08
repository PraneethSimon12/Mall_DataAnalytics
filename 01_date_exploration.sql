-- min and max of order dates, created dates, birthdates

--dates of the first and last order date
select 
min(order_date) as first_order_date
from gold.fact_sales;

select 
max(order_date) as last_order_date
from gold.fact_sales;

--diff in the dates

select 
datediff(year,min(order_date),max(order_date)) as order_range_years
from gold.fact_sales;

--combine all the above

select
min(order_date) as first_order_date,
max(order_date) as last_order_date,
datediff(year,min(order_date),max(order_date)) as order_range_years
from gold.fact_sales;

--find the youngest and the oldest customer

