--grouping data based on specific range to understand correlation between 2 measures
--here we are segmenting products into cost ranges and return
--the count of the no of products falling each segment

select * 
from gold.fact_sales;

select * 
from gold.dim_products;

--getting the cost of all products in asc order 

select 
product_name,
cost
from gold.dim_products
where cost is not null
order by cost;

--now group them in diff segments

select 
product_key,
product_name,
cost,
case when cost < 100 then 'Below 100'
	 when cost between 100 and 500 then '100-500'
	 when cost between 500 and 1000 then '500-1000'
	 else '1000+'
end cost_range
from gold.dim_products
where cost is not null
order by cost;


--aggregating based on the cte

with product_segments as
(
select 
product_key,
product_name,
cost,
case when cost < 100 then 'Below 100'
	 when cost between 100 and 500 then '100-500'
	 when cost between 500 and 1000 then '500-1000'
	 else '1000+'
end cost_range
from gold.dim_products
where cost is not null
)
select cost_range, 
count(product_key) as total_products
from product_segments
group by cost_range
order by total_products desc;

--grouping customers based on the spending behaviour 
-- grouping in terms of their spending in the last 12 months history

select *
from gold.dim_customers;

select * 
from gold.fact_sales;

select * 
from gold.dim_products;

select customer_key,
sum(sales_amount) as total_sales,
case when sum(sales_amount) < 1000 then 'Below 1000'
	 when sum(sales_amount) between 1000 and 2000 then '1000-2000'
	 when sum(sales_amount) between 2001 and 3000 then '2000-3000'
	 else 'Above 3000'
end Spending
from gold.fact_sales
group by customer_key;


--now use a cte and group the data accordingly as VIP, regular and new

with spending_class as
(
select customer_key,
sum(sales_amount) as total_sales,
case when sum(sales_amount) < 1000 then 'Below 1000'
	 when sum(sales_amount) between 1000 and 2000 then '1000-2000'
	 when sum(sales_amount) between 2001 and 3000 then '2000-3000'
	 else 'Above 3000'
end Spending
from gold.fact_sales
group by customer_key
)
select customer_key,
total_sales,
Spending,
case when Spending = 'Below 1000' then 'New'
	 when Spending = '1000-2000' then 'Regular'
	 else 'VIP'
end class
from spending_class
order by total_sales desc;

--now in order the order date and life span of a customer too into count 

select
c.customer_key,
sum(f.sales_amount) as total_spending,
MIN(order_date) as first_order,
max(order_date) as last_order,
DATEDIFF(month,min(order_date), max(order_date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c 
on f.customer_key = c.customer_key
group by c.customer_key;


--now using cte we divide customers into their respective classes 
--at least 12 months spending and above 3000 -> VIP
--at least 12 months spending and below 3000 -> Regular
--less than 12 months spending -> New

with customer_spending as
(
select
c.customer_key,
sum(f.sales_amount) as total_spending,
MIN(order_date) as first_order,
max(order_date) as last_order,
DATEDIFF(month,min(order_date), max(order_date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c 
on f.customer_key = c.customer_key
group by c.customer_key
)
select 
customer_key,
total_spending,
lifespan,
case when lifespan >= 12 and total_spending > 3000 then 'VIP'
	 when lifespan >= 12 and total_spending <= 3000 then 'Regular'
	 else 'New'
end customer_segment
from customer_spending
order by total_spending desc;



-- give the total count of customers in each segment

with customer_spending as
(
select
c.customer_key,
sum(f.sales_amount) as total_spending,
MIN(order_date) as first_order,
max(order_date) as last_order,
DATEDIFF(month,min(order_date), max(order_date)) as lifespan
from gold.fact_sales f
left join gold.dim_customers c 
on f.customer_key = c.customer_key
group by c.customer_key
)
select 
customer_segment,
count(customer_key) as total_customers
from(
	select 
	customer_key,
	case when lifespan >= 12 and total_spending > 3000 then 'VIP'
		 when lifespan >= 12 and total_spending <= 3000 then 'Regular'
		 else 'New'
	end customer_segment
	from customer_spending ) t
group by customer_segment
order by total_customers desc;