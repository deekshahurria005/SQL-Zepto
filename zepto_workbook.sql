
create database zepto_sql;
use zepto_sql;

-- data exploration

-- count of rows
select count(*) from zepto; 

-- sample data
select * from zepto limit 10;

-- null values
select * from zepto where
Category is null
OR
name is null
OR
mrp is null
OR
discountPercent is null
OR
availableQuantity is null
OR
discountedSellingPrice is null
OR
weightInGms is null
OR
outOfStock is null
OR
quantity is null;

-- alter/ modify values

Alter table zepto 
change Category category varchar(50); 

alter table zepto 
add column id int auto_increment primary key first;

-- different product categories

select distinct category
from zepto
order by category;

-- products in stock vs out of stock

select outOfStock, COUNT(id) as total
from zepto
group by outOfStock;

-- product names present multiple times

select name, count(id) as "Number of id's"
from zepto
group by name 
having count(id) > 1
order by count(id) desc;

-- data cleaning

-- products with price =0

select* from zepto where
mrp= 0 or discountedSellingPrice = 0;

delete from zepto where
mrp = 0;

-- convert paise to rupees

update zepto 
set mrp =mrp/100, 
discountedSellingPrice= discountedSellingPrice/100;

select*from zepto

-- Q1 Find the top 10 best value products based on the discount percentage.

Select distinct name, mrp, discountPercent
from zepto
order by discountPercent desc
limit 10;

-- Q2 What are the products with high mrp but out of stock?

select distinct name, mrp, outOfStock from zepto
where mrp > 300 and outOfStock = TRUE
order by mrp desc;

-- Q3 Calculate estimated revenue for each category

select category, sum(discountedSellingPrice* availableQuantity) as total_revenue
from zepto
group by category
order by total_revenue;

-- Q4 Find all products where mrp is greater than rs 500 and discount is less than 10%

select distinct name, mrp, discountPercent from zepto 
where mrp> 500 and discountPercent< 10
order by mrp desc,
discountPercent desc;

-- Q5 Identify the top 5 categories offering highest avg discount percentage

select distinct category, Round(avg (discountpercent),2) as avg_discount
from zepto 
group by category
order by avg_discount desc
limit 5;

-- Q6 Find the price per gram of products above 100gm and sort by best value

select distinct name , weightINGms, discountedSellingPrice, 
round(discountedSellingPrice/ weightInGms, 2) as price_per_gram
 from zepto
where weightInGms >= 100
order by price_per_gram;

-- Q7 Group the products into categories like Low, Medium, Bulk

select distinct name , weightInGms,
case when weightInGms < 1000 then 'Low'
  when weightInGms < 5000 then 'Medium'
else 'Bulk'
end as weight_category
from zepto;

-- Q8 What is the total inventory weight per category

select distinct category, sum(weightInGms* availableQuantity) as total_weight
from zepto
group by category
order by total_weight;

-- Q9 Pareto / Top 20% products by revenue
SELECT name, category,
       ROUND(discountedSellingPrice * availableQuantity, 2) AS product_revenue
FROM zepto
GROUP BY name, category, discountedSellingPrice, availableQuantity
ORDER BY product_revenue DESC
LIMIT 50;

-- 	Q10 Stock-out rate by price tier
SELECT 
  CASE 
    WHEN mrp < 100 THEN 'Budget (<₹100)'
    WHEN mrp < 300 THEN 'Mid (₹100–300)'
    WHEN mrp < 500 THEN 'Premium (₹300–500)'
    ELSE 'Luxury (>₹500)'
  END AS price_tier,
  COUNT(*) AS total_products,
  SUM(CASE WHEN outOfStock = 1 OR outOfStock = 'true' OR outOfStock = 'TRUE' THEN 1 ELSE 0 END) AS out_of_stock,
  ROUND(SUM(CASE WHEN outOfStock = 1 OR outOfStock = 'true' OR outOfStock = 'TRUE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS stockout_rate_pct
FROM zepto
GROUP BY price_tier
ORDER BY MIN(mrp);