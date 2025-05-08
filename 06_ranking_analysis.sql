--rankinbg dimensions by the measures

-- top 5 products generating the highest revenue

select *
from gold.dim_products;
select *
from gold.fact_sales;

select 
top 5
p.product_key,
p.product_name,
sum(sales_amount) as total_sales
from gold.dim_products p 
left join gold.fact_sales f
on p.product_key = f.product_key
group by p.product_key, p.product_name
order by total_sales desc;


-- top 5 worst performing products
-- here we are not considering the null sales products to be the worst products

with worst_performers as
(
select 
p.product_key as prod_key,
p.product_name as prod_name,
sum(sales_amount) as total_sales
from gold.dim_products p 
left join gold.fact_sales f
on p.product_key = f.product_key
group by p.product_key, p.product_name
)
select top 5 
prod_key,
prod_name,
total_sales
from worst_performers
where total_sales is not null
order by total_sales;

--5 best performing subcategories and their revenues

select 
top 5
p.subcategory,
p.product_name,
sum(sales_amount) as total_sales
from gold.dim_products p 
left join gold.fact_sales f
on p.product_key = f.product_key
group by p.subcategory, p.product_name
order by total_sales desc;

--5 worst subcategories

with worst_performers as
(
select 
p.subcategory as sub_category,
p.product_name as prod_name,
sum(sales_amount) as total_sales
from gold.dim_products p 
left join gold.fact_sales f
on p.product_key = f.product_key
group by p.subcategory, p.product_name
)
select top 5 
sub_category,
prod_name,
total_sales
from worst_performers
where total_sales is not null
order by total_sales;


--getting the top 5 using window functions
select * 
from(
select 
p.product_name,
sum(f.sales_amount) as total_revenue,
row_number() over(order by sum(f.sales_amount) desc) as rank_products
from gold.fact_sales f
left join gold.dim_products p
on p.product_key = f.product_key
group by p.product_name)t
where rank_products < 6;

