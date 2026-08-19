/*
Customer Report
Purpose: Consolidates customer-level metrics, purchasing behavior,
         segmentation, and customer KPIs into a single report.

Analysis:
- Customer demographics and age groups
- Customer segmentation: VIP, Regular, New
- Total orders, sales, quantity, and products
- Customer lifespan and recency
- Average order value and monthly spend
*/

-- 1. Base Customer Transaction Dataset
-- Combines customer and transaction data to create the foundation
-- for customer-level analysis.

WITH base_query AS (
    SELECT 
        f.order_number, f.product_key, f.order_date, f.sales_amount, f.quantity,
        c.customer_key, c.birthdate, c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age
    FROM gold.dim_customers AS c
    LEFT JOIN gold.fact_sales AS f
        ON c.customer_key = f.customer_key
    WHERE order_date IS NOT NULL
)

-- 2. Customer-Level Aggregation
-- Summarizes transaction-level data to calculate customer purchasing
-- activity, sales contribution, product diversity, and lifespan.

, customer_aggregation AS (
    SELECT 
        customer_key, customer_name, age, customer_number,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY customer_key, customer_name, customer_number, age
)

-- 3. Customer Segmentation & KPI Analysis
-- Classifies customers by age and purchasing behavior, then calculates
-- customer-level KPIs such as recency, average order value, and spend.

SELECT 
    customer_key,
    customer_name,
    customer_number,
    age,
    lifespan,

    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and Above'
    END AS age_group,

    CASE 
        WHEN lifespan > 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment, 

    last_order_date,
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recenct_orders,

    total_orders,
    total_sales,
    total_quantity,
    total_products,
    last_order_date,
    lifespan,

    -- Average revenue generated per order
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_Sales / total_orders 
    END AS avg_order_value,

    -- Average monthly customer spend
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_Sales / lifespan 
    END AS avg_monthly_spent

FROM customer_aggregation;
