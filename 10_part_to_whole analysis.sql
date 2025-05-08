--Part to Whole analysis
-- how an individual component is performing compareed to the overall

select *
from gold.fact_sales;

select *
from gold.dim_products;

-- we have all products their categories and their sales 

select 
p.product_name,
p.category,
sum(f.sales_amount) as total_sales
from gold.dim_products p
left join gold.fact_sales f
on p.product_key = f.product_key
group by p.product_name, p.category
order by p.category;


-- now we group the category and respectively calculate their total sales
with comp_sales as 
(
select 
--p.product_name as product_name,
p.category as category_name,
sum(f.sales_amount) as total_sales
from gold.dim_products p
left join gold.fact_sales f
on p.product_key = f.product_key
where f.sales_amount is not null 
group by  p.category
)
select
--product_name,
category_name,
sum(total_sales) over(partition by category_name) as cat_sales
from comp_sales;


--the above query can also be written as
with category_sales as
(
select 
p.category as category,
sum(sales_amount) as total_sales
from gold.dim_products p
left join gold.fact_sales f
on p.product_key = f.product_key
where category is not null 
group by category
)
select 
category,
total_sales,
Sum(total_sales) over () as overall_total,
Round((cast(total_sales as float) / sum(total_sales) over())*100,2) as percent_sales
from category_sales;


--now lastly we can get the most dominating category


with category_sales as
(
select 
p.category as category,
sum(sales_amount) as total_sales
from gold.dim_products p
left join gold.fact_sales f
on p.product_key = f.product_key
where category is not null 
group by category
)
select 
category,
total_sales,
Sum(total_sales) over () as overall_sales,
concat(Round((cast(total_sales as float) / sum(total_sales) over())*100,2),'%') as percent_sales
from category_sales
order by total_sales desc;