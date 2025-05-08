--cumulative analysis of the data

--aggregrating the data progressively over the time 
-- helps to understand if the business is growing or declining
-- [CUMULATIVE MEASURE] BY [DATE DIMENSION]


--Calculating the total sales per month and the running total of sales over time

select order_date, total_sales,
sum(total_sales) over (order by order_date) as running_total_sales
from
(
select datetrunc(month,order_date) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by datetrunc(month,order_date)
) as t;


--with any running total we can use partition by 


select order_date, total_sales,
sum(total_sales) over (partition by order_date order by order_date) as running_total_sales
from
(
select datetrunc(month,order_date) as order_date,
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by datetrunc(month,order_date)
) as t;

--sorting the running total by year

select order_date, total_sales,
sum(total_sales) over (order by order_date) as running_total_sales 
from
(
select DATETRUNC(year,order_date) as order_date, 
sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by DATETRUNC(year,order_date)
) as t;

-- adding an additional average total functionality
select order_date, total_sales,
sum(total_sales) over (order by order_date) as running_total_sales,
avg(avg_sales) over (order by order_date) as running_avg_sales
from
(
select datetrunc(year, order_date) as order_date,
sum(sales_amount) as total_sales,
avg(sales_amount) as avg_sales
from gold.fact_sales
where order_date is not null
group by datetrunc(year, order_date)
) as t;


