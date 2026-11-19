-- PROJECT: Retail Sales SQL Analysis
-- DATABASE: project1
-- TABLES: orders, details
-- PURPOSE: Analyse sales, profit, customers, products, and monthly performance.
-- Prerequisite: Data cleaning and the orders-details foreign key setup are complete.
-- The queries below use the same straightforward SQL style practiced in this project.
-- Note: The Details table has no product-name or product-cost column.
-- Overall result from the completed queries: sales = 437,624; profit = 36,938;
-- quantity sold = 5,611; profit margin = approximately 8.44%.
-- In simple terms, the dataset shows about 8.44 in profit for every 100 in sales.
-- These figures describe this dataset; they are not a calculation of net profit.


-- The table structure and key relationship were created and checked during setup.
-- This file focuses on analysis queries.


-- 1. What are the total sales?
select sum(amount) as total_sales from details;
-- Insight: This gives the overall revenue generated in the dataset.

-- 2. What is the total profit?
select sum(profit) as total_profit from details;
-- Insight: Compare total profit with total sales to understand overall profitability.

 -- 3. What is the total quantity sold?
select sum(Quantity) as total_quantity_sell from details;
-- Insight: This shows the total number of units sold.

-- 4. What are the total sales by state?
select orders.state,sum(details.amount) as total_sale
from orders 
inner join details 
on orders.order_id=details.order_id 
group by orders.state
order by total_sale desc;
-- Count how many distinct states are present in the orders table.
select count(distinct(state)) AS total_states from orders;
-- Insight: The state-wise result helps identify the strongest and weakest sales markets.

-- 5. What are the total sales and profit by category?
select category,sum(amount) as total_sale,sum(profit) 
from details 
group by category
order by total_sale desc;
-- Insight: The highest row is the leading category by sales; compare its profit before judging performance.

-- 6. Who are the top 10 customers by total purchase amount?
select o.customer_name as customer,
sum(d.amount)as total_purchase,
sum(d.Profit)as total_profit
from orders o 
left join details d
on o.order_id=d.order_id
group by customer
order by total_purchase desc
limit 10;
-- Insight: These are the customers with the highest total purchase value.

-- 7. Which payment mode is used most often?
select paymode,
count(paymode) AS payment_count,
sum(Amount)as total_sale
from details 
group by PayMode 
order by payment_count desc
limit 1;
-- Insight: This identifies the most frequently used payment mode, not necessarily the mode with highest sales.

-- 8. What is the monthly sales trend?
select date_format(o.order_date,'%Y-%m')as sales_month,  -- it converts all rows date into yyyy-mm
round(sum(d.amount),2) as total_sales  -- converts values up to desired decimal no
from orders o
inner join details d
on o.order_id=d.order_id
group by sales_month
order by sales_month
;
-- Insight: Use the monthly pattern to spot peak and slow sales periods.

-- 9. What are the top 10 sub-categories by profit?
select Sub_Category,
sum(profit)as total_profit,
sum(amount) as total_sales
from details 
group by Sub_Category 
order by total_profit desc
limit 10;
-- Insight: The first rows are the most profitable sub-categories.


-- 10. Which sub-categories have an overall loss?
select sub_category as loss_making_sub_category,
sum(amount) as total_sales,
sum(profit) as total_profit
from details 
group by sub_category 
having sum(profit)<0
order by total_profit 
;
-- Insight: Negative-profit sub-categories need attention even when they generate sales.


-- MEDIUM-LEVEL SQL: 10 QUESTIONS
-- Q1. Find total sales for each state.
select 
	o.state as state,
    sum(d.amount) as total_sale
from orders o
inner join details d
on o.order_id=d.order_id
group by State
order by total_sale desc
;
-- Insight: The top rows show states with the highest sales.
-- This repeats the earlier state-sales question as medium-level JOIN practice.

-- Q2. Find total sales for each city.
select 
	o.city as city,
    round(sum(d.amount),2)as total_sale
from orders o
inner join details d
on o.order_id=d.order_id
group by city
order by total_sale desc
;
-- Insight: The top rows show cities with the highest sales and help compare local markets.


-- Q3. Find the total amount for each order.
select
	o.order_id as id,
    o.customer_name as customer,
    round(sum(d.amount),2)as total_sale
from orders o
inner join details d
on o.order_id=d.order_id
group by id,customer
order by total_sale desc
;
-- Insight: This shows the total value of each order and helps identify large orders.


-- Q4. Find the 10 highest-value orders.
select 
	o.order_id as id,
    o.customer_name as customer,
    round(sum(d.amount),2)as total_sale
from orders o
inner join details d
on o.order_id=d.order_id
group by id,Customer
order by total_sale desc
limit 10
;
-- Insight: Use this list to identify the largest orders and their customers.


-- Q5. Calculate the average order value (AOV).
with order_summery as(
	select 
		o.order_id as id,
        sum(d.amount) as total_sale
	from orders o
	inner join details d
	on o.order_id=d.order_id
    group by id
	)
		select 
			round(avg(total_sale),2)as avg_order_value
		from order_summery
        ;
-- Insight: AOV is the average amount spent per order.


-- Q6. Find monthly sales and the number of orders.
select 
	date_format(o.order_date,'%Y-%m')as months,
	sum(d.amount)as total_sale,
	count(distinct(o.order_id))as total_orders
from orders o
inner join details d
on o.order_id=d.order_id
group by months
order by months
;
-- Insight: Compare monthly sales and order counts to see whether changes come from order volume or order value.


-- Q7. Find customers who have placed more than three orders.			
select
	Customer_Name as customer,
	count(distinct(order_id)) as order_count
from orders
group by Customer
having order_count>3
order by order_count desc
;
-- Insight: These customers have ordered more than three times and may be repeat customers.

-- Q8. Find the number of orders and average order value by state.
with state_sales as (
	select
		o.order_id as id,
		o.state as state,
		sum(d.amount)as total_sale
	from orders o
    inner join details d
    on o.order_id=d.order_id
    group by id,state
)
	select
		state,
        count(*) as total_order,
        round(avg(total_sale),2)as avg_order_value
	from state_sales
    group by state
    order by avg_order_value desc
    ;
-- Insight: A higher average order value means customers spend more per order in that state.


-- Q9. Find orders with an amount above the average order amount.
with orders1 as(
	select 
		o.order_id ,
        o.customer_name ,
		sum(d.amount)as total_amount
	from orders o
    inner join details d
    on o.order_id=d.order_id
    group by o.order_id,o.Customer_Name
    )
		select
			order_id,
            customer_name,
            round(total_amount,2)as total_amount
		from orders1
        where total_amount >(select avg(total_amount)from orders1)
        order by total_amount desc
        ;
-- Insight: These orders are larger than the dataset's average order value.
    
        
-- Q10. Find each state's percentage contribution to total sales.
	select
		o.state as state,
		round(sum(d.amount)) as total_amt,
		round(sum(d.amount)/(select sum(amount)from details)*100,2)as sale_per
	from orders o
	inner join details d
	on o.order_id=d.order_id
	group by o.state
	order by sale_per desc
    ;
-- Insight: The percentage shows how much each state contributes to all sales.


-- ADVANCED-LEVEL SQL: 10 QUESTIONS

-- LEVEL 1: Advanced aggregation
-- Q1. Which product category has the highest profit margin, 
  -- and what is its profit margin percentage?
select 
      category,
      round(sum(Profit),2) as profit,
      round(sum(amount),2)as sales,
      round((sum(profit)/nullif (sum(amount),0))*100,2) as profit_margin_percentage
from details
group by category
order by profit_margin_percentage desc 
;
      
-- Q2. Which sub-categories have high sales but zero or negative profit?
select 
      sub_category,
      round(sum(profit),2) as profit,
      round(sum(amount),2) as sales,
      round(sum(profit)/nullif(sum(amount),0)*100,2) as profit_margin_percentage
from details
group by Sub_Category
having sum(amount)>10000 and sum(profit) <=0
order by profit asc
;
-- Insight: Review these sub-categories to understand where sales are not converting into profit.

-- Q3. Which state contributes the highest percentage of total sales?
select o.state as region,
       sum(d.amount) as amount,
       round(sum(d.amount)/(select sum(amount)from details)*100,2) as sales_percentage
from orders o
inner join details d
on o.order_id=d.order_id
group by o.state
order by sales_percentage desc
;
-- Insight: The first row is the state with the largest share of total sales.

-- LEVEL 2: Advanced joins and subqueries
-- Q4. Find customers whose total sales are higher than the average customer sales.
-- Concepts: CTE, GROUP BY, subquery.
-- Customer sales are aggregated across ALL of each customer's orders.
WITH customer_sale AS (
    SELECT
        o.customer_name AS customer,
        SUM(d.amount) AS total_sales
    FROM orders o
    INNER JOIN details d
        ON o.order_id = d.order_id
    GROUP BY o.customer_name
)
SELECT
    customer,
    ROUND(total_sales, 2) AS total_sales
FROM customer_sale
WHERE total_sales > (
    SELECT AVG(total_sales)
    FROM customer_sale
)
ORDER BY total_sales DESC;
-- Insight: Customers above the average are the higher-value customer group.


-- Q5. Find the top 3 sub-categories by sales within each category.
-- Note: The supplied Details table has Category and Sub_Category, but no product-name column.
-- Concepts: CTE, ROW_NUMBER(), PARTITION BY.
WITH subcategory_sales AS (
    SELECT
        category,
        sub_category,
        SUM(amount) AS total_sales
    FROM details
    GROUP BY category, sub_category
),
subcategory_ranking AS (
    SELECT
        category,
        sub_category,
        total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY category
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM subcategory_sales
)
SELECT
    category,
    sub_category,
    ROUND(total_sales, 2) AS total_sales,
    sales_rank
FROM subcategory_ranking
WHERE sales_rank <= 3
ORDER BY category, sales_rank;
-- Insight: This shows the strongest-selling sub-categories within each category.


-- Q6. Which customers have placed more than 5 orders and generated
-- total profit above the average customer profit?
-- Concepts: COUNT(DISTINCT), GROUP BY, CTE, subquery.
WITH customer_details AS (
    SELECT
        o.customer_name AS customer,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(d.profit) AS total_profit
    FROM orders o
    INNER JOIN details d
        ON o.order_id = d.order_id
    GROUP BY o.customer_name
)
SELECT
    customer,
    order_count,
    ROUND(total_profit, 2) AS total_profit
FROM customer_details
WHERE order_count > 5
  AND total_profit > (
      SELECT AVG(total_profit)
      FROM customer_details
  )
ORDER BY total_profit DESC;


-- LEVEL 3: Window functions and business analysis
-- Q7. Calculate month-over-month sales growth percentage.
-- Concepts: LAG(), OVER(), window functions, percentage calculation.
with monthly_sale as (
	select
        date_format(o.order_date,'%Y-%m') as sale_month,
        sum(d.amount)as total_sale
	from orders o
	inner join details d
	on o.order_id=d.order_id
	group by date_format(o.order_date,'%Y-%m')
	),
		sale_comparison as(
			select 
				sale_month,
                total_sale,
			lag(total_sale)over(order by sale_month) as previous_month_sales
			from monthly_sale
			)
					select
						sale_month,
                        round(total_sale,2)current_month_sale,
                        round(previous_month_sales,2) AS previous_month_sales,
                        round((total_sale-previous_month_sales)/nullif(previous_month_sales,0)*100,2)as sales_growth_percentage
					from sale_comparison
                    order by sale_month;
-- Insight: A positive percentage indicates growth; a negative percentage indicates a decline.
                        
                        
-- Q8. Find each customer's first order date, latest order date, and total number of orders.
-- Concepts: MIN(), MAX(), COUNT(DISTINCT).
select 
	customer_name,
    min(order_date)as first_order_date,
    max(order_date)as latest_order_date,
    count(distinct order_id)as total_orders
from orders
group by customer_name
order by total_orders desc;
-- Insight: First and latest dates show customer activity span; order count shows repeat activity.


-- Q9. Calculate the running total of sales month by month.
-- Concepts: CTE, SUM() OVER(), window functions.
with monthly_sale as(
	select 
		date_format(o.order_date,'%Y-%m')as sale_month,
        sum(d.amount)as total_sale
	from orders o
    inner join details d
    on o.order_id=d.order_id
    group by sale_month
)
		select
			sale_month,
			round(total_sale,2)as current_sale,
			round(sum(total_sale)over(order by sale_month rows between unbounded preceding and current row),2)as running_total_sale
		from monthly_sale
		order by sale_month;
	

-- Q10. Identify the top 10% of customers based on total sales.
-- Concepts: CTE, NTILE(), window functions.
WITH customer_sale AS (
    SELECT
        o.customer_name AS customer,
        SUM(d.amount) AS total_sales
    FROM orders o
    INNER JOIN details d
        ON o.order_id = d.order_id
    GROUP BY o.customer_name
),
customer_ranking AS (
    SELECT
        customer,
        total_sales,
        NTILE(10) OVER (ORDER BY total_sales DESC) AS sales_group
    FROM customer_sale
)
SELECT
    customer,
    ROUND(total_sales, 2) AS total_sales,
    ROUND(
        total_sales / NULLIF((SELECT SUM(amount) FROM details), 0) * 100,
        2
    ) AS sales_contribution_percent
FROM customer_ranking
WHERE sales_group = 1
ORDER BY total_sales DESC;
-- Insight: These customers are in the highest-sales 10% group; contribution shows their share of overall sales.
