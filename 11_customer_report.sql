 -- Complete customer report to get all the results and solutions under one view table(s) for better use in future

 --getting the core columns from all the tables
 -- creating a BASE QUERY	

 with base_query as 
 (
 select 
 f.order_number,
 f.product_key,
 f.order_date,
 f.sales_amount,
 f.quantity,
 c.customer_key,
 c.customer_number,
 concat(c.first_name, ' ', c.last_name) as customer_name,
 datediff(year,c.birthdate,getdate()) as age
 from gold.fact_sales f
 left join gold.dim_customers c
 on c.customer_key = f.customer_key
 where order_date is not null
 )
 select 
 customer_key,
 customer_number,
 customer_name,
 age,
 COUNT(distinct order_number) as total_orders,
 sum(sales_amount) as total_sales,
 sum(quantity) as total_quantity,
 count(distinct product_key) as total_products,
 max(order_date) as last_order_date,
 datediff(month,min(order_date),max(order_date)) as lifespan
 from base_query
 group by 
 customer_key,
 customer_number,
 customer_name,
 age;


 -- now segmenting the base query written above into diff
 -- customer segments like vip, regular and new


 with base_query as 
 (
 select 
 f.order_number,
 f.product_key,
 f.order_date,
 f.sales_amount,
 f.quantity,
 c.customer_key,
 c.customer_number,
 concat(c.first_name, ' ', c.last_name) as customer_name,
 datediff(year,c.birthdate,getdate()) as age
 from gold.fact_sales f
 left join gold.dim_customers c
 on c.customer_key = f.customer_key
 where order_date is not null)
 , customer_aggregation as(
 select 
 customer_key,
 customer_number,
 customer_name,
 age,
 COUNT(distinct order_number) as total_orders,
 sum(sales_amount) as total_sales,
 sum(quantity) as total_quantity,
 count(distinct product_key) as total_products,
 max(order_date) as last_order_date,
 datediff(month,min(order_date),max(order_date)) as lifespan
 from base_query
 group by 
 customer_key,
 customer_number,
 customer_name,
 age
 )
select
customer_key,
customer_number,
customer_name,
age, 
case when age < 20 then 'Under 20'
	 when age between 20 and 29 then '20-29'
	 when age between 30 and 39 then '30-39'
	 when age between 40 and 49 then '40-49'
	 Else '50 and above'
end as age_group,
case when lifespan >= 12 and total_sales > 3000 then 'VIP'
	 when lifespan >= 12 and total_sales <= 3000 then 'Regular'
	 else 'New'
end customer_segment,
total_orders,
total_sales,
total_quantity,
total_products,
last_order_date,
lifespan
from customer_aggregation;


--calculating the kpi's life recency, average order value and average monthly spend

 create view gold.report_customers as
 with base_query as 
 (
 select 
 f.order_number,
 f.product_key,
 f.order_date,
 f.sales_amount,
 f.quantity,
 c.customer_key,
 c.customer_number,
 concat(c.first_name, ' ', c.last_name) as customer_name,
 datediff(year,c.birthdate,getdate()) as age
 from gold.fact_sales f
 left join gold.dim_customers c
 on c.customer_key = f.customer_key
 where order_date is not null)
 , customer_aggregation as(
 select 
 customer_key,
 customer_number,
 customer_name,
 age,
 COUNT(distinct order_number) as total_orders,
 sum(sales_amount) as total_sales,
 sum(quantity) as total_quantity,
 count(distinct product_key) as total_products,
 max(order_date) as last_order_date,
 datediff(month,min(order_date),max(order_date)) as lifespan
 from base_query
 group by 
 customer_key,
 customer_number,
 customer_name,
 age
 )
select
customer_key,
customer_number,
customer_name,
age, 
case when age < 20 then 'Under 20'
	 when age between 20 and 29 then '20-29'
	 when age between 30 and 39 then '30-39'
	 when age between 40 and 49 then '40-49'
	 else '50 and above'
end as age_group,
case when lifespan >= 12 and total_sales > 3000 then 'VIP'
	 when lifespan >= 12 and total_sales <= 3000 then 'Regular'
	 else 'New'
end customer_segment,
last_order_date,
DATEDIFF(month, last_order_date, getdate()) as recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
case when total_sales = 0 then 0 
	 else total_sales / total_orders
end as avg_order_value,
case when lifespan = 0 then total_sales 
	 else total_sales / lifespan
end as avg_monthly_spend
from customer_aggregation;

select *
from gold.report_customers;