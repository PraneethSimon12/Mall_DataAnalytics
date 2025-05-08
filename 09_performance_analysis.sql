-- Performance analysis

-- comparing the current val to the target val (measure successe and compare perf)
-- analyzing the yearly performance of products by comparing each products's sales 
-- to both its avg sales performance and the previous year's sales

-- CURRENT[MEASURE] - TARGET[MEASURE]


select * from gold.dim_products;

select * from gold.fact_sales;

-- required info

select 
f.order_date,
p.product_name,
f.sales_amount
from gold.dim_products p 
left join gold.fact_sales f
on p.product_key = f.product_key;

--sorting by year total sales of products
--below is the query of total sum of sales for each prod in a particular year

select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f 
left join gold.dim_products p
on p.product_key = f.product_key
where f.order_date is not null
group by year(f.order_date), p.product_name;


--now get the sales for diff years so to compare sales over target and current parameters
--making using cte

with yearly_product_sales as(
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f 
left join gold.dim_products p
on p.product_key = f.product_key
where f.order_date is not null
group by year(f.order_date), p.product_name
)
select 
order_year,
product_name,
current_sales,
avg(current_sales) over (partition by product_name ) avg_sales
from yearly_product_sales;


--getting the diff of the change in sales 

with yearly_product_sales as(
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f 
left join gold.dim_products p
on p.product_key = f.product_key
where f.order_date is not null
group by year(f.order_date), p.product_name
)
select 
order_year,
product_name,
current_sales,
avg(current_sales) over (partition by product_name ) avg_sales,
current_sales - avg(current_sales) over (partition by product_name) as diff_avg
from yearly_product_sales;


--now giving the result if avg or not 
select *
from gold.fact_sales;

select * 
from gold.dim_products;

with yearly_sales as
(
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
where f.order_date is not null
group by year(f.order_date), p.product_name
)
select 
order_year,
product_name,
current_sales,
AVG(current_sales) over(partition by product_name) as avg_sales,
current_sales - avg(current_sales) over(partition by product_name) as diff_avg,
case when current_sales - avg(current_sales) over(partition by product_name) > 0 then 'Above Avg' 
	 when current_sales - avg(current_sales) over(partition by product_name) < 0 then 'Below Avg'
	 else 'Avg'
end Avg_Change
from yearly_sales
order by product_name, order_year;


--getting the sales of the previous year using window function

with yearly_sales as
(
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
where f.order_date is not null
group by year(f.order_date), p.product_name
)
select 
order_year,
product_name,
current_sales,
AVG(current_sales) over(partition by product_name) as avg_sales,
current_sales - avg(current_sales) over(partition by product_name) as diff_avg,
case when current_sales - avg(current_sales) over(partition by product_name) > 0 then 'Above Avg' 
	 when current_sales - avg(current_sales) over(partition by product_name) < 0 then 'Below Avg'
	 else 'Avg'
end Avg_Change,
lag(current_sales) over(partition by product_name order by order_year) as previous_yr_sales
from yearly_sales
order by product_name, order_year;

--diff in yearly sales i.e. year over year analysis

with yearly_sales as
(
select 
year(f.order_date) as order_year,
p.product_name,
sum(f.sales_amount) as current_sales
from gold.fact_sales f
left join gold.dim_products p
on f.product_key=p.product_key
where f.order_date is not null
group by year(f.order_date), p.product_name
)
select 
order_year,
product_name,
current_sales,
AVG(current_sales) over(partition by product_name) as avg_sales,
current_sales - avg(current_sales) over(partition by product_name) as diff_avg,
case when current_sales - avg(current_sales) over(partition by product_name) > 0 then 'Above Avg' 
	 when current_sales - avg(current_sales) over(partition by product_name) < 0 then 'Below Avg'
	 else 'Avg'
end Avg_Change,
lag(current_sales) over(partition by product_name order by order_year) as previous_yr_sales,
current_sales - lag(current_sales) over(partition by product_name order by order_year) as yearly_diff,
case when current_sales - lag(current_sales) over(partition by product_name order by order_year) > 0 then 'Increasing' 
	 when current_sales - lag(current_sales) over(partition by product_name order by order_year) < 0 then 'Decreasing'
	 else 'No Change'
end Previous_yr_change
from yearly_sales
order by product_name, order_year;