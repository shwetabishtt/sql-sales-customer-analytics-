/*
Project: SQL Sales & Customer Analytics
File: 01_sales_product_customer_analysis.sql
Purpose: Sales, product, category, and customer analysis
*/
-- ============================================================
-- 1. SALES TREND ANALYSIS
-- ============================================================

-- Business Question: How has sales performance changed across years?

SELECT 
    DATEPART(YEAR, order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEPART(YEAR, order_date)
ORDER BY order_year;

-- Business Question: Which months generate the highest sales?

SELECT 
    DATEPART(YEAR, order_date) AS order_year,
    DATENAME(MONTH, order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATEPART(YEAR, order_date), DATENAME(MONTH, order_date)
ORDER BY total_sales DESC;

-- Insight: 2013 recorded the strongest annual sales performance.
-- December generated the highest overall monthly sales,
-- suggesting a potential seasonal purchasing pattern.


-- ============================================================
-- 2. CUMULATIVE SALES ANALYSIS
-- ============================================================

-- Business Question: How does sales accumulate over time at a monthly level?

SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
    SELECT
        DATE_TRUNC(MONTH, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC(MONTH, order_date)
) AS monthly_sales
ORDER BY order_date;

-- Business Question: How does sales accumulate over time at a yearly level?

SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales
FROM (
    SELECT
        DATE_TRUNC(YEAR, order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC(YEAR, order_date)
) AS yearly_sales
ORDER BY order_date;


-- ============================================================
-- 3. PRODUCT PERFORMANCE ANALYSIS
-- ============================================================

-- Business Question: Which products perform above or below
-- their historical average?

-- Method 1: Derived Table Approach

SELECT 
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS average_sales_yearly,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS difference_from_average,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 
            THEN 'Above Average'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 
            THEN 'Below Average'
        ELSE 'Average'
    END AS vs_average_status
FROM (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
) AS yearly_product_sales
ORDER BY product_name, order_year;


-- Method 2: CTE Approach
-- Extends the analysis with year-over-year performance.

WITH yearly_product_sales AS (
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT 
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS average_sales_yearly,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS difference_from_average,
    CASE 
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 
            THEN 'Above Average'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 
            THEN 'Below Average'
        ELSE 'Average'
    END AS vs_average_status,
    LAG(current_sales) OVER (
        PARTITION BY product_name ORDER BY order_year
    ) AS previous_year_sales,
    current_sales - LAG(current_sales) OVER (
        PARTITION BY product_name ORDER BY order_year
    ) AS yoy_sales_difference,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (
            PARTITION BY product_name ORDER BY order_year
        ) > 0 THEN 'Increased Sales'
        WHEN current_sales - LAG(current_sales) OVER (
            PARTITION BY product_name ORDER BY order_year
        ) < 0 THEN 'Decreased Sales'
        ELSE 'No Change'
    END AS yoy_sales_status
FROM yearly_product_sales
ORDER BY product_name, order_year;


-- ============================================================
-- 4. CATEGORY CONTRIBUTION ANALYSIS
-- ============================================================

-- Business Question: Which categories contribute the most to overall sales?

WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    GROUP BY p.category
)
SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(
        ROUND(
            CAST(total_sales AS FLOAT) / SUM(total_sales) OVER () * 100, 2
        ),
        '%'
    ) AS category_total_percentage
FROM category_sales
ORDER BY total_sales DESC;

-- Insight: Sales are heavily concentrated in the Bikes category,
-- creating revenue concentration risk and highlighting an opportunity
-- to diversify revenue across other categories.


-- ============================================================
-- 5. PRODUCT PORTFOLIO SEGMENTATION
-- ============================================================

-- Business Question: How is the product portfolio distributed
-- across different cost ranges?

WITH product_segments AS (
    SELECT 
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost < 500 THEN '100-499'
            WHEN cost < 1000 THEN '500-999'
            ELSE '1000+'
        END AS cost_range
    FROM gold.dim_products
)
SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;


-- ============================================================
-- 6. CUSTOMER SEGMENTATION
-- ============================================================

-- Business Question: How are customers distributed across
-- spending and purchasing-lifespan segments?

-- VIP: More than 12 months history and spending > 5,000
-- Regular: At least 12 months history and spending <= 5,000
-- New: Less than 12 months history

WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c
        ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
),
customer_segments AS (
    SELECT
        customer_key,
        total_spending,
        first_order,
        last_order,
        lifespan,
        CASE
            WHEN lifespan > 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
)
SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM customer_segments
GROUP BY customer_segment
ORDER BY total_customers DESC;
