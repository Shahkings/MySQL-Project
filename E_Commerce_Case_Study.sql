create schema e_commerce;

use e_commerce;

# 1. Problem statement
# Describe the tables

desc customers;
desc orderdetails;
desc orders;
desc products;

select count(*) as null_values
from customers WHERE name IS NULL;

select count(*) as null_values
from orderdetails WHERE price_per_unit IS NULL;

select count(*) as null_values
from orders where order_date is null;

select count(*) as null_values
from products where name is null;

select *
from customers;

# 2. Problem statement
# Problem statement
# Identify the top 3 cities with the highest number of customers to determine key markets for targeted marketing and logistic optimization.

select location,
count(customer_id) as number_of_customers
from customers
group by location
order by number_of_customers DESC
limit 3;

# 3. Problem statement
# Problem statement
# Determine the distribution of customers by the number of orders placed.
# This insight will help in segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies.


select *
from orders;

select 
order_count as numberOfOrders,
COUNT(*) AS CustomerCount
from(
select
customer_id,
count(*) as order_count
from orders
group by customer_id
) as customerCount
group by order_count
order by numberoforders asc;

# 4. Problem statement
# Problem statement
# Identify products where the average purchase quantity per order is 2 but with a high total revenue, suggesting premium product trends.

select * 
from orderdetails;

select product_id,
avg(quantity) as AvgQuantity,
sum(quantity * price_per_unit) as totalrevenue
from orderdetails
group by product_id
having AvgQuantity = 2
order by totalrevenue DESC;

# 5. Problem statement
# Problem statement
# For each product category, calculate the unique number of customers purchasing from it.
# This will help understand which categories have wider appeal across the customer base.

select *
from products;
select *
from orderdetails;
select *
from orders;

select p.category, count(distinct o.customer_id) as unique_customers
from products p
join orderdetails od on p.product_id = od.product_id
join orders o on o.order_id = od.order_id
group by p.category
order by unique_customers DESC;

# 6. Problem statement
# Problem statement
# Analyze the month-on-month percentage change in total sales to identify growth trends.

select*
from orders;

with monthly_sales as(
select date_format(str_to_date(order_date, '%m/%d/%Y'), '%Y-%m') as Month,
sum(total_amount) as TotalSales
from orders
group by Month
)
select Month, TotalSales,
round(((TotalSales - lag(TotalSales) over (order by Month)) / lag(TotalSales) over (order by Month)) * 100, 2) as PercentageChange
from monthly_sales;

# 7. Problem statement
# Problem statement
# Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies to enhance order value.

with Avg_monthly_value as(
select date_format(str_to_date(order_date, '%m/%d/%Y'), '%Y-%m') as Month,
avg(total_amount) as AvgOrderValue
from orders
group by Month
)
select Month, AvgOrderValue,
Round((AvgOrderValue - lag(AvgOrderValue) over (order by Month)),2) as ChangeInValue
from Avg_monthly_value
order by ChangeInValue DESC;

# 8. Problem statement
# Problem statement
# Based on sales data, identify products with the fastest turnover rates, suggesting high demand and the need for frequent restocking.

Select *
from orderdetails;

select Product_id,
count(order_id) as SalesFrequency
from orderdetails
group by product_id
order by SalesFrequency DESC
limit 5;

# 9. Problem statement
# Problem statement
# List products purchased by less than 40% of the customer base, indicating potential mismatches between inventory and customer interest.
# Hint:
# Use the “Products”, “Orders”, “OrderDetails” and “Customers” table.
# Return the result table which will help you get the product names along with the count of unique customers who belong to the lower 40% of the customer pool.

select *
from products;
select *
from orders;
select *
from orderdetails;
select *
from customers;

-- Step 1: Get total unique customers
WITH TotalCustomers AS (
    SELECT COUNT(DISTINCT customer_id) AS total_count
    FROM customers
),

-- Step 2: Get unique customers per product
ProductCustomerCount AS (
    SELECT 
        p.product_id,
        p.name,
        COUNT(DISTINCT o.customer_id) AS UniqueCustomerCount
    FROM products p
    JOIN orderdetails od ON p.product_id = od.product_id
    JOIN orders o ON od.order_id = o.order_id
    GROUP BY p.product_id, p.name
)

-- Step 3: Filter products used by less than 40% of customers
SELECT 
    pcc.product_id,
    pcc.name,
    pcc.UniqueCustomerCount
FROM ProductCustomerCount pcc
JOIN TotalCustomers tc
  ON 1=1
WHERE pcc.UniqueCustomerCount < (tc.total_count * 0.4);

# 10. Problem statement
# Problem statement
# Evaluate the month-on-month growth rate in the customer base to understand the effectiveness of marketing campaigns and market expansion efforts.

-- with monthly_growth_rate as (
-- select date_format(str_to_date(order_date, '%m/%d/%Y'), '%Y-%m') as FirstPurchaseMonth,
-- count(customer_id) as TotalNewCustomers
-- from Orders
-- group by FirstPurchaseMonth
-- )

-- select FirstPurchaseMonth, TotalNewCustomers
-- from monthly_growth_rate
-- order by FirstPurchaseMonth ASC;

WITH FirstOrder AS (
  SELECT 
    customer_id,
    MIN(STR_TO_DATE(order_date, '%d/%m/%Y')) AS FirstOrderDate
  FROM Orders
    WHERE STR_TO_DATE(order_date, '%d/%m/%Y') IS NOT NULL
  GROUP BY customer_id
),
MonthlyGrowth AS (
  SELECT 
    DATE_FORMAT(FirstOrderDate, '%Y-%m') AS FirstPurchaseMonth,
    COUNT(DISTINCT customer_id) AS TotalNewCustomers
  FROM FirstOrder
  GROUP BY FirstPurchaseMonth
)
SELECT 
  FirstPurchaseMonth,
  TotalNewCustomers
FROM MonthlyGrowth
WHERE FirstPurchaseMonth IS NOT NULL
ORDER BY FirstPurchaseMonth ASC;


# 11. Problem statement
# Problem statement
# Identify the months with the highest sales volume, aiding in planning for stock levels, marketing efforts, and staffing in anticipation of peak demand periods.

select *
from Orders;

select date_format(str_to_date(order_date, '%d/%m/%Y'),'%Y-%m') as Month,
sum(total_amount) as TotalSales
from Orders
where str_to_date(order_date, '%d/%m/%Y') is not null
group by Month
order by TotalSales DESC
limit 3;

DESCRIBE orders;
