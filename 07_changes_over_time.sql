-- SALES PERFORMANCE BY TIME 

-- measure evolution over time 
--tracks trend and seasonality in the data
-- SUMMATION OF [MEASURE] BY [DATE DIMENSION]


select * 
from gold.fact_sales;


-- sale per day excluding nulls
select order_date, sales_amount
from gold.fact_sales
where order_date is not null
order by order_date;

--per years total sales
select year(order_date) as year, sum(sales_amount) as total_sales
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);

--total customer per year and sales per year

select year(order_date) as year, sum(sales_amount) as total_sales, count(distinct customer_key) as customer
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);


--quantity per year

select year(order_date) as year, 
sum(sales_amount) as total_sales, 
count(distinct customer_key) as customer,
sum(quantity) as quantity
from gold.fact_sales
where order_date is not null
group by year(order_date)
order by year(order_date);

--aggregate data by months

select month(order_date) as month,
sum(sales_amount) as total_sales,
count(distinct customer_key) as customers,
count(quantity) as quantity
from gold.fact_sales
where order_date is not null
group by month(order_date)
order by month(order_date);

--aggreagate data by month and year

select year(order_date) as year ,month(order_date) as month,
sum(sales_amount) as total_sales,
count(distinct customer_key) as customers,
count(quantity) as quantity
from gold.fact_sales
where order_date is not null
group by year(order_date), month(order_date)
order by year(order_date), month(order_date);

--instead 2 columns of month and year use datetrun to have them in one col

select DATETRUNC(month,order_date) as order_date,
sum(sales_amount) as total_sales,
count(distinct customer_key) as customers,
count(quantity) as quantity
from gold.fact_sales
where order_date is not null
group by DATETRUNC(month,order_date)
order by DATETRUNC(month,order_date);

--better formatting of the date

select FORMAT(order_date,'yyyy-MMM') as order_date,
sum(sales_amount) as total_sales,
count(distinct customer_key) as customers,
count(quantity) as quantity
from gold.fact_sales
where order_date is not null
group by FORMAT(order_date,'yyyy-MMM')
order by FORMAT(order_date,'yyyy-MMM');
