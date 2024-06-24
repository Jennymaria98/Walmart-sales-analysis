CREATE TABLE sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10,2) NOT NULL,
quantity INT(20) NOT NULL,
vat FLOAT(6,4) NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12, 4),
rating FLOAT(2, 1)
);




------------------- Feature Engineering ------------------------------

select time,
CASE
		WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
END AS Time_of_day
From sales;
ALTER TABLE sales ADD COLUMN Time_of_day VARCHAR(20);

-- Disable safe update mode for the session
SET SQL_SAFE_UPDATES = 0;
-- Perform the update
UPDATE sales
SET Time_of_day = (
	CASE 
		WHEN  time  BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
		WHEN  time  BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
		ELSE 'Evening'
	END
);

--- -day name
select date,
DAYNAME(date) AS day_name
From Sales;
ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date); 

--- -month_name
select date,
monthname(date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);


-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

select * from Sales;
---------------- Exploratory Data Analysis (EDA) ----------------------

#Generic Questions
-- 1.How many distinct cities are present in the dataset?
select distinct city from sales;

-- 2.In which city is each branch situated?
select distinct branch , city from sales;

#Product Analysis
-- 1.How many distinct product lines are there in the dataset?
select Count( distinct product_line ) from sales;

-- 2.What is the most common payment method?
select payment , count(payment) AS common_payment_method
from sales group by payment order by common_payment_method desc limit 1;

-- 3.What is the most selling product line?
select product_line , count(product_line) AS most_selling_product
from sales group by product_line order by most_selling_product desc limit 1;

-- 4.What is the total revenue by month?
select month_name , SUM(total) AS total_revenue
from sales group by month_name order by total_revenue desc ;

-- 5.Which month recorded the highest Cost of Goods Sold (COGS)?
select month_name , SUM(cogs) AS total_cogs
from sales group by month_name order by total_cogs desc;

-- 6.Which product line generated the highest revenue?
select product_line , SUM(total) AS revenue
from sales group by product_line order by revenue desc limit 1;

-- 7.Which city has the highest revenue?
select city ,SUM(total) AS revenue
from sales group by city order by revenue desc limit 1;

-- 8.Which product line incurred the highest VAT?
select product_line , SUM(vat) AS Highest_vat
from sales group by product_line order by Highest_vat desc limit 1;

-- 9.Retrieve each product line and add a column product_category, indicating 'Good' or 'Bad,'whether its sales are above the average.

alter table sales add column product_category varchar(20);

UPDATE sales 
JOIN (
    SELECT AVG(total) AS avg_total FROM sales
) AS subquery
SET sales.product_category = 
  CASE 
    WHEN sales.total >= subquery.avg_total THEN 'Good'
    ELSE 'Bad'
  END;
  
-- Sales Analysis

-- 1.Number of sales made in each time of the day per weekday
select day_name , Time_of_day , count(invoice_id) AS total_sales
from sales group by day_name ,Time_of_day Having day_name NOT IN ('sunday','Saturday');

-- 2.Identify the customer type that generates the highest revenue.
SELECT customer_type, SUM(total) AS total_sales
FROM sales GROUP BY customer_type ORDER BY total_sales DESC LIMIT 1;

-- 4.Which customer type pays the most in VAT?
SELECT customer_type, SUM(VAT) AS total_VAT
FROM sales GROUP BY customer_type ORDER BY total_VAT DESC LIMIT 1;

-- Customer Analysis

-- 1.How many unique customer types does the data have?
SELECT COUNT(DISTINCT customer_type) FROM sales;

-- 2.How many unique payment methods does the data have?
SELECT COUNT(DISTINCT payment) FROM sales;

-- 3.Which is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS common_customer
FROM sales GROUP BY customer_type ORDER BY common_customer DESC LIMIT 1;

-- 4.Which customer type buys the most?
SELECT customer_type, SUM(total) as total_sales
FROM sales GROUP BY customer_type ORDER BY total_sales LIMIT 1;

SELECT customer_type, COUNT(*) AS most_buyer
FROM sales GROUP BY customer_type ORDER BY most_buyer DESC LIMIT 1;

-- 5.What is the gender of most of the customers?
SELECT gender, COUNT(*) AS all_genders 
FROM sales GROUP BY gender ORDER BY all_genders DESC LIMIT 1;

-- 6.What is the gender distribution per branch?
SELECT branch, gender, COUNT(gender) AS gender_distribution
FROM sales GROUP BY branch, gender ORDER BY branch;

		











