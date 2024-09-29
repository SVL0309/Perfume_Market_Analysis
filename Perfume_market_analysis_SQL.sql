USE perfume_market;

### 1. Product Category Analysis

### 1.1. General Overview

SELECT category AS Product_Category,
	ROUND(SUM(total_revenue) / (SELECT SUM(total_revenue) FROM sql_perfume_check) * 100, 2) AS Market_Share,
	COUNT(DISTINCT brand) AS Number_of_Brands,
	COUNT(DISTINCT grouped_category) AS Number_of_ProductTypes,
	COUNT(DISTINCT title) AS Number_of_Products,
	COUNT(DISTINCT itemLocation) AS Number_of_Items,
	ROUND(MIN(price), 1) AS Min_Price,
	ROUND(MAX(price), 1) AS Max_Price,
	ROUND(AVG(price), 1) AS Avg_Price,
	ROUND(SUM(total_revenue)/SUM(sold), 1)AS Weighted_Avg_Price
FROM sql_perfume_check
GROUP BY category
ORDER BY Market_Share DESC
LIMIT 0, 200;

### 1.2. Product Category Analysis - Sales

##### 1.2.1. Analysis of product shipments over a period by product categories as a whole and by gender. Identification of the most popular product categories.

SELECT category AS Product_Category,
	SUM(sold) AS Total_Sales_Units,
	SUM(CASE WHEN gender = 'man' THEN sold ELSE 0 END) AS Man_Sales_Units,
	SUM(CASE WHEN gender = 'woman' THEN sold ELSE 0 END) AS Woman_Sales_Units
FROM sql_perfume_check
GROUP BY category
ORDER BY Total_Sales_Units DESC
LIMIT 0, 200;

##### 1.2.2. Analysis of revenue inflow over a period by product categories as a whole and by gender. Identification of the most profitable product categories.

SELECT category AS Product_Category,
	SUM(total_revenue) AS Total_Sales_USD,
	SUM(CASE WHEN gender = 'man' THEN total_revenue ELSE 0 END) AS Man_Sales_USD,
	SUM(CASE WHEN gender = 'woman' THEN total_revenue ELSE 0 END) AS Woman_Sales_USD
FROM sql_perfume_check
GROUP BY category
ORDER BY Total_Sales_USD DESC
LIMIT 0, 200;

### 1.3. Product Category Analysis - Inventory

##### 1.3.1. Quantitative analysis of inventory levels by product categories as a whole and by gender. Identification of categories with the largest stock levels.

SELECT 
    category AS Product_Category,
    SUM(CASE
        WHEN gender = 'man' THEN available
        ELSE 0
    END) AS Man_Inventory_Units,
    SUM(CASE
        WHEN gender = 'woman' THEN available
        ELSE 0
    END) AS Woman_Inventory_Units,
    SUM(available) AS Total_Inventory_Units
FROM
    sql_perfume_check
GROUP BY category
ORDER BY Total_Inventory_Units DESC
LIMIT 0 , 200;

##### 1.3.2. Analysis of inventory in monetary terms by product categories as a whole and by gender. Identification of categories with the largest stock values.


SELECT category AS Product_Category,
       ROUND(SUM(CASE WHEN gender = 'man' THEN available*price ELSE 0 END),1) AS Man_Inventory_USD,
       ROUND(SUM(CASE WHEN gender = 'woman' THEN available*price ELSE 0 END),1) AS Woman_Inventory_USD,
       ROUND(SUM(available*price),1) AS Total_Inventory_USD
FROM sql_perfume_check
GROUP BY category
ORDER BY Total_Inventory_USD DESC
LIMIT 0, 200;

### 1.4. Calculation of Inventory Utilization Ratios by product categories as a whole and by gender.

SELECT category AS Product_Category,
       ROUND(IFNULL(SUM(CASE WHEN gender = 'man' THEN total_revenue ELSE 0 END) / NULLIF(SUM(CASE WHEN gender = 'man' THEN price * available ELSE 0 END), 0), 0), 1) AS Man_IUR,
       ROUND(IFNULL(SUM(CASE WHEN gender = 'woman' THEN total_revenue ELSE 0 END) / NULLIF(SUM(CASE WHEN gender = 'woman' THEN price * available ELSE 0 END), 0), 0), 1) AS Woman_IUR,
       ROUND(IFNULL(SUM(total_revenue) / NULLIF(SUM(price * available), 0), 0), 1) AS Total_IUR
FROM sql_perfume_check
GROUP BY category
ORDER BY Total_IUR DESC
LIMIT 0, 200;

### 1.5. Sales analysis by the Product Caregory

SELECT category AS Product_Category,
	SUM(total_revenue) AS Total_Sales_USD,
	SUM(DISTINCT CASE WHEN gender = 'man' THEN total_revenue ELSE 0 END) AS MAN_Sales_USD,
	SUM(DISTINCT CASE WHEN gender = 'woman' THEN total_revenue ELSE 0 END) AS WOMAN_Sales_USD,
	SUM(sold)AS Total_sold_UNITS,
	SUM(DISTINCT CASE WHEN gender = 'man' THEN sold ELSE 0 END) AS MAN_sold_UNITS,
	SUM(DISTINCT CASE WHEN gender = 'woman' THEN sold ELSE 0 END) AS WOMAN_sold_UNITS
FROM sql_perfume_check
GROUP BY Product_Category
ORDER BY Total_Sales_USD DESC;

### 2. Sales analysis by brands and product types, and identification of top positions.

##### 2.1. General Overview by Brand

SELECT brand AS Brand,
	SUM(total_revenue) AS Revenue,
	SUM(CASE WHEN gender = 'man' THEN total_revenue ELSE NULL END) AS Revenue_MAN,
	SUM(CASE WHEN gender = 'woman' THEN total_revenue ELSE NULL END) AS Revenue_WOMAN,
	SUM(sold) AS Items_sold,
	SUM(CASE WHEN gender = 'man' THEN sold ELSE NULL END) AS Items_sold_MAN,
	SUM(CASE WHEN gender = 'woman' THEN sold ELSE NULL END) AS Items_sold_WOMAN,
	COUNT(DISTINCT grouped_category) AS Number_of_fragrancies,
	COUNT(DISTINCT CASE WHEN gender = 'man' THEN grouped_category ELSE NULL END) AS Fragrancies_MAN,
	COUNT(DISTINCT CASE WHEN gender = 'woman' THEN grouped_category ELSE NULL END) AS Fragrancies_WOMAN,
	COUNT(DISTINCT title) AS Tital_items,
	COUNT(DISTINCT CASE WHEN gender = 'man' THEN title ELSE NULL END) AS Items_MAN,
	COUNT(DISTINCT CASE WHEN gender = 'woman' THEN title ELSE NULL END) AS Items_WOMAN
FROM sql_perfume_check
GROUP BY Brand
ORDER BY Revenue DESC;

##### 2.1.1. A list of 20 TOP brands sorted by sales volume from the highest-selling to the lowest-selling, indicating the category to which each brand belongs.

SELECT brand, 
	SUM(sold) AS total_sold, 
	SUM(total_revenue) AS revenue,
	ROUND(AVG(total_revenue/sold),2) AS AVG_Price,
	ROUND(NULLIF(SUM(price * available)/IFNULL(SUM(total_revenue), 0), 0)*100, 2) AS 'IUR_%',
	category AS Product_Category
FROM sql_perfume_check
GROUP BY category, brand
ORDER BY revenue DESC
LIMIT 20;

##### 2.1.2. A list of Bottom 20 brands sorted by sales volume from the highest-selling to the lowest-selling, indicating the category to which each brand belongs.

SELECT brand, 
	SUM(sold) AS total_sold, 
	SUM(total_revenue) AS revenue,
	ROUND(AVG(total_revenue/sold),2) AS AVG_Price,
	ROUND(NULLIF(SUM(price * available)/IFNULL(SUM(total_revenue), 0), 0)*100, 2) AS 'IUR_%',
	category AS Product_Category
FROM sql_perfume_check
GROUP BY category, brand
ORDER BY revenue ASC
LIMIT 20;

##### 2.1.3. Top Brands by product category

SELECT 
    sql_perfume_check.category AS Product_Category, 
    sql_perfume_check.brand AS Brand,
    COUNT(DISTINCT sql_perfume_check.grouped_category) AS Fragrancies,
    COUNT(DISTINCT sql_perfume_check.title) AS Products,
    ROUND(AVG(total_revenue/sold),2) AS AVG_Price,
    ROUND(NULLIF(SUM(price * available)/IFNULL(SUM(total_revenue), 0), 0)*100, 2) AS 'IUR_%',
    SUM(sql_perfume_check.sold) AS Sales_Units, 
    SUM(sql_perfume_check.total_revenue) AS Sales_USD,
    SUM(CASE WHEN sql_perfume_check.gender = 'man' THEN sql_perfume_check.sold ELSE 0 END) AS Man_Sales_Units,
    SUM(CASE WHEN sql_perfume_check.gender = 'woman' THEN sql_perfume_check.sold ELSE 0 END) AS Woman_Sales_Units,
    SUM(CASE WHEN sql_perfume_check.gender = 'man' THEN sql_perfume_check.total_revenue ELSE 0 END) AS Man_Sales_USD,
    SUM(CASE WHEN sql_perfume_check.gender = 'woman' THEN sql_perfume_check.total_revenue ELSE 0 END) AS Woman_Sales_USD
FROM 
    sql_perfume_check
GROUP BY 
    sql_perfume_check.category, sql_perfume_check.brand
HAVING 
(sql_perfume_check.category, SUM(sql_perfume_check.total_revenue)) IN 
	(SELECT category, MAX(total_rev)
	FROM 
		(SELECT 
		category, 
		brand, 
		SUM(total_revenue) AS total_rev 
		FROM sql_perfume_check 
		GROUP BY category, brand
	) AS sales
GROUP BY category);

### 2.2. General Overview by Product

SELECT title AS Product,
	SUM(total_revenue) AS Revenue,
	SUM(CASE WHEN gender = 'man' THEN total_revenue ELSE 0 END) AS Revenue_MAN,
	SUM(CASE WHEN gender = 'woman' THEN total_revenue ELSE 0 END) AS Revenue_WOMAN,
	SUM(sold) AS Items_sold,
	SUM(CASE WHEN gender = 'man' THEN sold ELSE 0 END) AS Items_sold_MAN,
	SUM(CASE WHEN gender = 'woman' THEN sold ELSE 0 END) AS Items_sold_WOMAN,
	COUNT(DISTINCT grouped_category) AS Number_of_fragrancies,
	COUNT(DISTINCT CASE WHEN gender = 'man' THEN grouped_category ELSE NULL END) AS Fragrancies_MAN,
	COUNT(DISTINCT CASE WHEN gender = 'woman' THEN grouped_category ELSE NULL END) AS Fragrancies_WOMAN,
	COUNT(DISTINCT title) AS Tital_items,
	COUNT(DISTINCT CASE WHEN gender = 'man' THEN title ELSE NULL END) AS Items_MAN,
	COUNT(DISTINCT CASE WHEN gender = 'woman' THEN title ELSE NULL END) AS Items_WOMAN
FROM sql_perfume_check
GROUP BY Product
ORDER BY Revenue DESC;

##### 2.2.1. A list of 20 TOP Products sorted by sales volume from the highest-selling to the lowest-selling, indicating the category and brand to which each product belongs.

SELECT title, 
	SUM(sold) AS total_sold, 
	SUM(total_revenue) AS revenue,
	ROUND(AVG(total_revenue/sold),2) AS AVG_Price,
	ROUND(IFNULL(SUM(price * available)/NULLIF(SUM(total_revenue), 0), 0)*100, 2) AS 'IUR_%',
	category AS Product_Category,
	brand AS Brand
FROM sql_perfume_check
GROUP BY title, brand, category
ORDER BY revenue DESC
LIMIT 20;

##### 2.2.2. A list of Bottom 20 products sorted by sales volume from the highest-selling to the lowest-selling, indicating the category and brand to which each product belongs.

SELECT title, 
	SUM(sold) AS total_sold, 
	SUM(total_revenue) AS revenue,
	ROUND(AVG(IFNULL(total_revenue / NULLIF(sold, 0), 0)), 2) AS AVG_Price,
	ROUND(IFNULL(SUM(price * available)/NULLIF(SUM(total_revenue), 0), 0)*100, 2) AS 'IUR_%',
	category AS Product_Category,
	brand AS Brand
FROM sql_perfume_check
GROUP BY title, brand, category
ORDER BY revenue ASC
LIMIT 20;

##### 2.2.3. Top Products by product category

SELECT 
    p.category AS Product_Category,
    p.title AS Product,
    p.brand AS Brand,
    p.grouped_category AS Fragrancy,
    p.price AS Price,
	ROUND(COALESCE(SUM(p.price * p.available), 0) / NULLIF(SUM(p.total_revenue), 0) * 100, 2) AS 'IUR_%',
    SUM(p.sold) AS Sales_Units, 
    SUM(p.total_revenue) AS Sales_USD,
    SUM(CASE WHEN p.gender = 'man' THEN p.sold ELSE 0 END) AS Man_Sales_Units,
    SUM(CASE WHEN p.gender = 'woman' THEN p.sold ELSE 0 END) AS Woman_Sales_Units,
    SUM(CASE WHEN p.gender = 'man' THEN p.total_revenue ELSE 0 END) AS Man_Sales_USD,
    SUM(CASE WHEN p.gender = 'woman' THEN p.total_revenue ELSE 0 END) AS Woman_Sales_USD
FROM 
    sql_perfume_check p
JOIN 
    (SELECT 
        category, 
        MAX(total_revenue) AS max_revenue
     FROM 
        sql_perfume_check
     GROUP BY 
        category) AS max_sales
ON 
    p.category = max_sales.category AND p.total_revenue = max_sales.max_revenue
GROUP BY 
    p.category, p.title, p.brand, p.grouped_category, p.price;

##### 2.2.4. Top Products fragrancy

SELECT 
    p.grouped_category AS Fragrancy,
    p.title AS Product,
    p.brand AS Brand,
    p.category AS Product_Category,
    p.price AS Price,
	ROUND(COALESCE(SUM(p.price * p.available), 0) / NULLIF(SUM(p.total_revenue), 0) * 100, 2) AS 'IUR_%',
    SUM(p.sold) AS Sales_Units, 
    SUM(p.total_revenue) AS Sales_USD,
    SUM(CASE WHEN p.gender = 'man' THEN p.sold ELSE 0 END) AS Man_Sales_Units,
    SUM(CASE WHEN p.gender = 'woman' THEN p.sold ELSE 0 END) AS Woman_Sales_Units,
    SUM(CASE WHEN p.gender = 'man' THEN p.total_revenue ELSE 0 END) AS Man_Sales_USD,
    SUM(CASE WHEN p.gender = 'woman' THEN p.total_revenue ELSE 0 END) AS Woman_Sales_USD
FROM 
    sql_perfume_check p
JOIN 
    (SELECT 
        grouped_category, 
        MAX(total_revenue) AS max_revenue
     FROM 
        sql_perfume_check
     GROUP BY 
        grouped_category) AS max_sales
ON 
    p.grouped_category = max_sales.grouped_category AND p.total_revenue = max_sales.max_revenue
GROUP BY 
    p.category, p.title, p.brand, p.grouped_category, p.price;

SELECT DISTINCT(category) FROM sql_perfume_check;

##### 2.3. General Overview by Fragrancies

SELECT grouped_category AS Fragrancy,
	SUM(total_revenue) AS Revenue,
	SUM(CASE WHEN gender = 'man' THEN total_revenue ELSE NULL END) AS Revenue_MAN,
	SUM(CASE WHEN gender = 'woman' THEN total_revenue ELSE NULL END) AS Revenue_WOMAN,
	SUM(sold) AS Items_sold,
	SUM(CASE WHEN gender = 'man' THEN sold ELSE NULL END) AS Items_sold_MAN,
	SUM(CASE WHEN gender = 'woman' THEN sold ELSE NULL END) AS Items_sold_WOMAN,
	COUNT(DISTINCT grouped_category) AS Number_of_fragrancies,
	COUNT(DISTINCT CASE WHEN gender = 'man' THEN grouped_category ELSE NULL END) AS Fragrancies_MAN,
	COUNT(DISTINCT CASE WHEN gender = 'woman' THEN grouped_category ELSE NULL END) AS Fragrancies_WOMAN,
	COUNT(DISTINCT title) AS Tital_items,
	COUNT(DISTINCT CASE WHEN gender = 'man' THEN title ELSE NULL END) AS Items_MAN,
	COUNT(DISTINCT CASE WHEN gender = 'woman' THEN title ELSE NULL END) AS Items_WOMAN
FROM sql_perfume_check
GROUP BY Fragrancy
ORDER BY Revenue DESC;

##### 2.3.1. Top fragrancies by product category

SELECT 
    sql_perfume_check.category AS Product_Category, 
    sql_perfume_check.grouped_category AS Fragrancy,
    COUNT(DISTINCT sql_perfume_check.brand) AS Brands,
    COUNT(DISTINCT sql_perfume_check.title) AS Products,
    ROUND(AVG(total_revenue/sold),2) AS AVG_Price,
    ROUND(NULLIF(SUM(price * available)/IFNULL(SUM(total_revenue), 0), 0)*100, 2) AS 'IUR_%',
    SUM(sql_perfume_check.sold) AS Sales_Units, 
    SUM(sql_perfume_check.total_revenue) AS Sales_USD,
    SUM(CASE WHEN sql_perfume_check.gender = 'man' THEN sql_perfume_check.sold ELSE 0 END) AS Man_Sales_Units,
    SUM(CASE WHEN sql_perfume_check.gender = 'woman' THEN sql_perfume_check.sold ELSE 0 END) AS Woman_Sales_Units,
    SUM(CASE WHEN sql_perfume_check.gender = 'man' THEN sql_perfume_check.total_revenue ELSE 0 END) AS Man_Sales_USD,
    SUM(CASE WHEN sql_perfume_check.gender = 'woman' THEN sql_perfume_check.total_revenue ELSE 0 END) AS Woman_Sales_USD
FROM 
    sql_perfume_check
GROUP BY 
    sql_perfume_check.category, sql_perfume_check.grouped_category
HAVING 
(sql_perfume_check.category, SUM(sql_perfume_check.total_revenue)) IN 
	(SELECT category, MAX(total_rev)
	FROM 
		(SELECT 
		category, 
		grouped_category, 
		SUM(total_revenue) AS total_rev 
		FROM sql_perfume_check 
		GROUP BY category, grouped_category
	) AS sales
GROUP BY category);
    
##### 2.3.2. Top brands by Fragrancy

SELECT 
    sql_perfume_check.grouped_category AS Fragrancy,
    sql_perfume_check.brand AS Brand, 
    sql_perfume_check.category AS Product_Categoties,
    COUNT(DISTINCT sql_perfume_check.title) AS Products,
    ROUND(AVG(total_revenue/sold),2) AS AVG_Price,
    ROUND(NULLIF(SUM(price * available)/IFNULL(SUM(total_revenue), 0), 0)*100, 2) AS 'IUR_%',
    SUM(sql_perfume_check.sold) AS Sales_Units, 
    SUM(sql_perfume_check.total_revenue) AS Sales_USD,
    SUM(CASE WHEN sql_perfume_check.gender = 'man' THEN sql_perfume_check.sold ELSE 0 END) AS Man_Sales_Units,
    SUM(CASE WHEN sql_perfume_check.gender = 'woman' THEN sql_perfume_check.sold ELSE 0 END) AS Woman_Sales_Units,
    SUM(CASE WHEN sql_perfume_check.gender = 'man' THEN sql_perfume_check.total_revenue ELSE 0 END) AS Man_Sales_USD,
    SUM(CASE WHEN sql_perfume_check.gender = 'woman' THEN sql_perfume_check.total_revenue ELSE 0 END) AS Woman_Sales_USD
FROM 
    sql_perfume_check
GROUP BY 
    sql_perfume_check.brand, sql_perfume_check.grouped_category, sql_perfume_check.category
HAVING 
(sql_perfume_check.grouped_category, SUM(sql_perfume_check.total_revenue)) IN 
	(SELECT grouped_category, MAX(total_rev)
	FROM 
		(SELECT 
		grouped_category, 
		brand, 
		SUM(total_revenue) AS total_rev 
		FROM sql_perfume_check 
		GROUP BY brand, grouped_category
	) AS sales
GROUP BY grouped_category)
ORDER BY Sales_USD DESC; 

### 3. Pricing

# To conduct a pricing analysis, we will create a table that assigns a price category to each product.
DROP TABLE IF EXISTS price_bins;
CREATE TABLE price_bins AS
SELECT title, 
CASE 
        WHEN price < 10 THEN "< $10"
        WHEN price >= 10 AND price < 30 THEN "$10 - $30"
        WHEN price >= 30 AND price < 50 THEN "$30 - $50"
        WHEN price >= 50 AND price < 80 THEN "$50 - $80"
        WHEN price >= 80 AND price < 100 THEN "$80 - $100"
        ELSE ">= $100"
    END AS Price_Bin
FROM sql_perfume_check;

### 3.1. General Overview by Pricing

SELECT price_bins.Price_Bin,
SUM(sql_perfume_check.total_revenue) AS Revenue,
COUNT(DISTINCT sql_perfume_check.category) AS Categories,
COUNT(DISTINCT sql_perfume_check.grouped_category) AS Fragrancies,
COUNT(DISTINCT sql_perfume_check.brand) AS Brands,
COUNT(DISTINCT sql_perfume_check.title) AS Product,
COUNT(DISTINCT sql_perfume_check.itemLocation) AS Sellers
FROM sql_perfume_check
JOIN price_bins ON sql_perfume_check.title = price_bins.title
GROUP BY price_bins.Price_Bin
ORDER BY Revenue DESC;

### 3.2. Distribution of sales, taking price bins into account.

##### 3.2.1. Distribution of sales revenue by categories, taking price bins into account.

SELECT 
    p.category AS Product_Category,
    SUM(CASE WHEN b.Price_Bin = "< $10" THEN total_revenue ELSE 0 END) AS "< $10",
    SUM(CASE WHEN b.Price_Bin = "$10 - $30" THEN total_revenue ELSE 0 END) AS "$10 - $30",
    SUM(CASE WHEN b.Price_Bin = "$30 - $50" THEN total_revenue ELSE 0 END) AS "$30 - $50",
    SUM(CASE WHEN b.Price_Bin = "$50 - $80" THEN total_revenue ELSE 0 END) AS "$50 - $80",
    SUM(CASE WHEN b.Price_Bin = "$80 - $100" THEN total_revenue ELSE 0 END) AS "$80 - $100",
    SUM(CASE WHEN b.Price_Bin = ">= $100" THEN total_revenue ELSE 0 END) AS ">= $100"
FROM 
    sql_perfume_check p
JOIN 
    price_bins b ON p.title = b.title
GROUP BY 
    p.category
ORDER BY 
    p.category;

##### 3.2.2. Distribution of sales revenue by fragrancies, taking price bins into account.

SELECT 
    p.grouped_category AS Fragrancy,
    SUM(CASE WHEN b.Price_Bin = "< $10" THEN total_revenue ELSE 0 END) AS "< $10",
    SUM(CASE WHEN b.Price_Bin = "$10 - $30" THEN total_revenue ELSE 0 END) AS "$10 - $30",
    SUM(CASE WHEN b.Price_Bin = "$30 - $50" THEN total_revenue ELSE 0 END) AS "$30 - $50",
    SUM(CASE WHEN b.Price_Bin = "$50 - $80" THEN total_revenue ELSE 0 END) AS "$50 - $80",
    SUM(CASE WHEN b.Price_Bin = "$80 - $100" THEN total_revenue ELSE 0 END) AS "$80 - $100",
    SUM(CASE WHEN b.Price_Bin = ">= $100" THEN total_revenue ELSE 0 END) AS ">= $100"
FROM 
    sql_perfume_check p
JOIN 
    price_bins b ON p.title = b.title
GROUP BY 
    p.grouped_category
ORDER BY 
    p.grouped_category;

### 3.3. Sales share for each price bin as a proportion of the total sales.

##### 3.3.1. Sales share for each price bin as a proportion of the total sales for the product category.

SELECT 
    p.category AS Product_Category,
    SUM(CASE WHEN b.Price_Bin = "< $10" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "< $10",
    SUM(CASE WHEN b.Price_Bin = "$10 - $30" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "$10 - $30",
    SUM(CASE WHEN b.Price_Bin = "$30 - $50" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "$30 - $50",
    SUM(CASE WHEN b.Price_Bin = "$50 - $80" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "$50 - $80",
    SUM(CASE WHEN b.Price_Bin = "$80 - $100" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "$80 - $100",
    SUM(CASE WHEN b.Price_Bin = ">= $100" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS ">= $100"
FROM 
    sql_perfume_check p
JOIN 
    price_bins b ON p.title = b.title
GROUP BY 
    p.category
ORDER BY 
    p.category;

##### 3.3.2. Sales share for each price bin as a proportion of the total sales for the fragrancy.

SELECT 
    p.grouped_category AS Fragrancy,
    SUM(CASE WHEN b.Price_Bin = "< $10" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "< $10",
    SUM(CASE WHEN b.Price_Bin = "$10 - $30" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "$10 - $30",
    SUM(CASE WHEN b.Price_Bin = "$30 - $50" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "$30 - $50",
    SUM(CASE WHEN b.Price_Bin = "$50 - $80" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "$50 - $80",
    SUM(CASE WHEN b.Price_Bin = "$80 - $100" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS "$80 - $100",
    SUM(CASE WHEN b.Price_Bin = ">= $100" THEN p.sold ELSE 0 END) / NULLIF(SUM(p.sold), 0) AS ">= $100"
FROM 
    sql_perfume_check p
JOIN 
    price_bins b ON p.title = b.title
GROUP BY 
    p.grouped_category
ORDER BY 
    p.grouped_category;


### 3.4. The share of sales in each price bin of a category compared to the total sales volume.

##### 3.4.1. The share of sales in each price bin of a category compared to the total sales volume across products categories.

SELECT 
    p.category AS Product_Category,
    ROUND(SUM(CASE WHEN b.Price_Bin = "< $10" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "< $10",
    ROUND(SUM(CASE WHEN b.Price_Bin = "$10 - $30" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "$10 - $30",
    ROUND(SUM(CASE WHEN b.Price_Bin = "$30 - $50" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "$30 - $50",
    ROUND(SUM(CASE WHEN b.Price_Bin = "$50 - $80" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "$50 - $80",
    ROUND(SUM(CASE WHEN b.Price_Bin = "$80 - $100" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "$80 - $100",
    ROUND(SUM(CASE WHEN b.Price_Bin = ">= $100" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS ">= $100"
FROM 
    sql_perfume_check p
JOIN 
    price_bins b ON p.title = b.title
JOIN 
    (SELECT SUM(total_revenue) AS total_revenue FROM sql_perfume_check) AS ts ON 1=1
GROUP BY 
    p.category, ts.total_revenue
ORDER BY 
    p.category;
    
##### 3.4.2. The share of sales in each price bin of a category compared to the total sales volume across fragrancies.

SELECT 
    p.grouped_category AS Product_Category,
    ROUND(SUM(CASE WHEN b.Price_Bin = "< $10" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "< $10",
    ROUND(SUM(CASE WHEN b.Price_Bin = "$10 - $30" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "$10 - $30",
    ROUND(SUM(CASE WHEN b.Price_Bin = "$30 - $50" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "$30 - $50",
    ROUND(SUM(CASE WHEN b.Price_Bin = "$50 - $80" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "$50 - $80",
    ROUND(SUM(CASE WHEN b.Price_Bin = "$80 - $100" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS "$80 - $100",
    ROUND(SUM(CASE WHEN b.Price_Bin = ">= $100" THEN p.total_revenue ELSE 0 END) / NULLIF(ts.total_revenue, 0) * 100, 1) AS ">= $100"
FROM 
    sql_perfume_check p
JOIN 
    price_bins b ON p.title = b.title
JOIN 
    (SELECT SUM(total_revenue) AS total_revenue FROM sql_perfume_check) AS ts ON 1=1
GROUP BY 
    p.grouped_category, ts.total_revenue
ORDER BY 
    p.grouped_category;
    

### 3.5. Sales analysis by price bin segmented by gender.

SELECT price_bins.Price_Bin AS Price_Bin,
SUM(CASE WHEN sql_perfume_check.gender = 'man' THEN sql_perfume_check.total_revenue END) AS MAN_SALES,
SUM(CASE WHEN sql_perfume_check.gender = 'woman' THEN sql_perfume_check.total_revenue END) AS WOMAN_SALES
FROM
price_bins
JOIN sql_perfume_check ON price_bins.title = sql_perfume_check.title
GROUP BY price_bins.Price_Bin;