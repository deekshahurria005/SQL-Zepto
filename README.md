# 🛒 Zepto SQL Data Analysis Project

---

## Project Background

**Zepto** is one of India's fastest-growing quick-commerce grocery delivery platforms, promising 10-minute delivery across major cities. This project analyses Zepto's product catalogue data using **MySQL**, covering product categories, pricing, discounts, stock availability, and inventory weight.

The goal is to simulate the kind of **data exploration and business analysis** a data analyst would perform to derive actionable insights from an e-commerce product dataset.

---

## 🎯 Objectives

- Explore and clean raw product data
- Understand the product catalogue structure across categories
- Answer business-relevant questions using SQL queries

---

## Dataset Overview

The dataset contains **3,727 rows** of product data from Zepto's catalogue.

| Column | Description |
|---|---|
| `id` | Auto-incremented unique product identifier |
| `category` | Product category (e.g., Cooking Essentials, Fruits & Vegetables) |
| `name` | Product name |
| `mrp` | Maximum Retail Price (in ₹, converted from paise) |
| `discountPercent` | Discount offered on the product (%) |
| `discountedSellingPrice` | Final selling price after discount (in ₹) |
| `availableQuantity` | Number of units currently available |
| `weightInGms` | Product weight in grams |
| `outOfStock` | Boolean — TRUE if out of stock |
| `quantity` | Quantity per pack |

---

## Tools Used

- **MySQL 8.0** — Query writing and data analysis
- **MySQL Workbench** — GUI for database management
- **GitHub** — Version control and project documentation

---

## Database Setup

```sql
CREATE DATABASE zepto_sql;
USE zepto_sql;
```

---

## Data Exploration

### Count of Total Rows
```sql
SELECT COUNT(*) FROM zepto;
```

### Sample Data Preview
```sql
SELECT * FROM zepto LIMIT 10;
```

### Checking for NULL Values
```sql
SELECT * FROM zepto
WHERE category IS NULL
   OR name IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR availableQuantity IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;
```

### Distinct Product Categories
```sql
SELECT DISTINCT category
FROM zepto
ORDER BY category;
```

### Products In Stock vs Out of Stock
```sql
SELECT outOfStock, COUNT(id) AS total
FROM zepto
GROUP BY outOfStock;
```

### Products with Duplicate Names
```sql
SELECT name, COUNT(id) AS "Number of id's"
FROM zepto
GROUP BY name
HAVING COUNT(id) > 1
ORDER BY COUNT(id) DESC;
```

---

## 🧹 Data Cleaning

### Step 1 — Add Primary Key Column
```sql
ALTER TABLE zepto
ADD COLUMN id INT AUTO_INCREMENT PRIMARY KEY FIRST;
```

### Step 2 — Rename Column for Consistency
```sql
ALTER TABLE zepto
CHANGE Category category VARCHAR(50);
```

### Step 3 — Remove Products with Zero Price
```sql
-- Identify zero-price products
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

-- Delete invalid records
DELETE FROM zepto
WHERE mrp = 0;
```

### Step 4 — Convert Prices from Paise to Rupees
```sql
UPDATE zepto
SET mrp = mrp / 100,
    discountedSellingPrice = discountedSellingPrice / 100;
```

---

## 📊 Business Analysis & SQL Queries

---

### Q1 — Top 10 Best Value Products by Discount Percentage

> *Which products offer the highest discounts to customers?*

```sql
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;
```

---

### Q2 — High MRP Products That Are Out of Stock

> *Premium products currently unavailable — potential revenue loss.*

```sql
SELECT DISTINCT name, mrp, outOfStock
FROM zepto
WHERE mrp > 300 AND outOfStock = TRUE
ORDER BY mrp DESC;
```

---

### Q3 — Estimated Revenue by Category

> *Which categories generate the most potential revenue based on current stock?*

```sql
SELECT category,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;
```

---

### Q4 — Premium Products with Low Discounts

> *Products priced above ₹500 with less than 10% discount.*

```sql
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;
```

---

### Q5 — Top 5 Categories by Average Discount

> *Which categories offer the best average deals to shoppers?*

```sql
SELECT DISTINCT category,
       ROUND(AVG(discountPercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;
```

---

### Q6 — Best Price per Gram (Products Above 100g)

> *Value-for-money analysis — lowest cost per gram among heavier products.*

```sql
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
       ROUND(discountedSellingPrice / weightInGms, 2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram ASC;
```

---

### Q7 — Product Weight Category Classification

> *Classifying products by weight into Low, Medium, and Bulk segments.*

```sql
SELECT DISTINCT name, weightInGms,
    CASE
        WHEN weightInGms < 1000 THEN 'Low'
        WHEN weightInGms < 5000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_category
FROM zepto;
```

---

### Q8 — Total Inventory Weight per Category

> *How much total stock (in grams) does each category hold?*

```sql
SELECT DISTINCT category,
       SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight DESC;
```

---
### Q9 — Top Revenue-Generating Products (Pareto Insight)

> *Which products contribute the highest revenue, indicating potential top 20% performers?*

```sql
SELECT name,
       category,
       ROUND(discountedSellingPrice * availableQuantity, 2) AS product_revenue
FROM zepto
GROUP BY name, category, discountedSellingPrice, availableQuantity
ORDER BY product_revenue DESC
LIMIT 50;
```

---

### Q10 — Stock-Out Rate by Price Tier

> *How does stock availability vary across different pricing segments?*

```sql
SELECT 
  CASE 
    WHEN mrp < 100 THEN 'Budget (<₹100)'
    WHEN mrp < 300 THEN 'Mid (₹100–300)'
    WHEN mrp < 500 THEN 'Premium (₹300–500)'
    ELSE 'Luxury (>₹500)'
  END AS price_tier,
  COUNT(*) AS total_products,
  SUM(
    CASE 
      WHEN outOfStock = 1 OR outOfStock = 'true' OR outOfStock = 'TRUE' 
      THEN 1 ELSE 0 
    END
  ) AS out_of_stock,
  ROUND(
    SUM(
      CASE 
        WHEN outOfStock = 1 OR outOfStock = 'true' OR outOfStock = 'TRUE' 
        THEN 1 ELSE 0 
      END
    ) * 100.0 / COUNT(*), 1
  ) AS stockout_rate_pct
FROM zepto
GROUP BY price_tier
ORDER BY MIN(mrp);
```
```
## 💡 Key Insights

- **Cooking Essentials** and **Fruits & Vegetables** are the dominant categories in the dataset.
- Several **premium products (MRP > ₹300)** are currently out of stock, representing missed revenue.
- A subset of high-MRP products (> ₹500) carry **less than 10% discount**, indicating low promotional push.
- The **price-per-gram** analysis reveals significant variation in value across product categories.
- **Bulk inventory weight** is concentrated in a few key categories, useful for warehouse planning.

---

## 📁 Repository Structure

```
zepto-sql-analysis/
│
├── README.md               ← Project documentation (this file)
└── zepto_workbook.sql      ← All SQL queries (exploration, cleaning, analysis)
└── zepto_v1                ← Complete dataset from Kaggle)
```

---

## 🙋‍♀️ About Me

I'm an aspiring data analyst passionate about turning raw data into meaningful insights using SQL, Excel, and data visualisation tools.

📫 Connect with me on [LinkedIn](https://in.linkedin.com/in/deeksha-hurria?original_referer=https%3A%2F%2Fwww.bing.com%2F) | 🐙 More projects on [GitHub]()

---

*⭐ If you found this project helpful, feel free to star the repository!*
