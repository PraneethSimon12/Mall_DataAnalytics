-- Dimensions and Measures

-- In any type of data dimenions and measures are very imp to group the data accordingly

-- Measures - if the vals are integers and can be aggregated
-- Eg: sales, quantity, age
-- Dimension - if the vals are integers and can be aggregated
-- Eg: category, product and birthdate

select distinct
customer_id
from gold.dim_customers;

select 
sum(sales_amount) as total_sales
from gold.fact_sales;

select * 
from INFORMATION_SCHEMA.TABLES;

select * 
from INFORMATION_SCHEMA.COLUMNS;

select * 
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME = 'dim_customers';

select distinct country
from gold.dim_customers;

select distinct category 
from gold.dim_products;
