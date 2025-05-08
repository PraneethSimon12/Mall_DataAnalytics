--basic measures like sum, avg, count and use of distinct

--total sales
select
sum(sales_amount) as total_sales
from gold.fact_sales;

--items sold

select
count(order_number) as total_items
from gold.fact_sales;

select
count(distinct order_number) as total_items
from gold.fact_sales;

--avg selling price

select 
avg(price) as avg_price
from gold.fact_sales;

--tot products

select
count(product_name) as total_products
from gold.dim_products;

select
count(distinct product_name) as total_products
from gold.dim_products;

--tot cust

select 
count(customer_key) as total_cust
from gold.dim_customers;

--customer who placed orders

select 
count(distinct customer_key) as total_cust
from gold.fact_sales;


--final report

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(product_name) FROM gold.dim_products
UNION ALL
SELECT 'Total Nr. Customers', COUNT(customer_key) FROM gold.dim_customers;
