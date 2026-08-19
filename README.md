# SQL Sales & Customer Analytics

## Project Overview

The **SQL Sales & Customer Analytics** project is a business-focused analysis of sales, product, and customer data using **Microsoft SQL Server**. The project applies SQL techniques such as **CTEs, JOINs, aggregate functions, CASE statements, and window functions** to transform transactional data into meaningful business insights.

The analysis focuses on **sales trends, product performance, category contribution, customer segmentation, and customer-level KPIs**, providing a structured view of business and customer performance.

## Data Overview

The analysis uses a dimensional data model consisting of:

- **Fact Sales** – transactional information including order date, sales amount, quantity, product, and customer.
- **Dimension Products** – product-level information including product name, category, and cost.
- **Dimension Customers** – customer information including customer name, customer number, and birthdate.

These tables are combined using SQL JOINs to perform analysis across sales, products, and customers.

## Steps of Analysis

### 1. Sales Trend Analysis

Sales performance was analyzed across different time periods using:

- Total sales
- Total quantity sold
- Total customers
- Yearly sales performance
- Monthly sales performance

The analysis identified **2013 as the strongest year in terms of sales**, while **December recorded the highest overall monthly sales**, highlighting a potential seasonal purchasing pattern.

### 2. Cumulative Sales Analysis

Cumulative sales were calculated at both monthly and yearly levels using **SQL window functions**.

The analysis uses:

- `SUM() OVER()`
- `DATE_TRUNC()`
- Aggregation by month and year

This helps understand how revenue accumulates over time and provides visibility into overall sales growth.

### 3. Product Performance Analysis

Product performance was evaluated across years by comparing current sales with historical performance.

The analysis calculates:

- Current yearly sales
- Average yearly sales
- Difference from average
- Previous year's sales
- Year-over-year sales change

The `AVG() OVER()` and `LAG()` window functions were used to identify products performing **above or below their historical average** and products experiencing **year-over-year growth or decline**.

### 4. Category Contribution Analysis

The contribution of each product category to overall sales was calculated using:

**Category Sales / Overall Sales × 100**

The analysis showed that **Bikes contribute the majority of overall revenue**, indicating significant revenue concentration within the category.

This highlights a potential business risk and an opportunity to diversify revenue across other product categories.

### 5. Product Cost Segmentation

Products were grouped into different cost ranges using `CASE WHEN` statements:

- Below 100
- 100–500
- 500–1000
- Above 1000

This segmentation provides an overview of how the product portfolio is distributed across different cost ranges.

### 6. Customer Segmentation

Customers were segmented based on their **total spending and purchasing lifespan**.

The segmentation framework consists of:

- **VIP** – more than 12 months of purchasing history and spending above 5,000
- **Regular** – at least 12 months of purchasing history and spending of 5,000 or less
- **New** – less than 12 months of purchasing history

This segmentation can support targeted **customer retention, upselling, and engagement strategies**.

### 7. Customer Analytics Report

A reusable customer-level reporting view was created to consolidate key customer metrics.

The report includes:

- Customer name and customer number
- Age and age group
- Customer segment
- Total orders
- Total sales
- Total quantity purchased
- Total products purchased
- Customer lifespan
- Recency
- Average Order Value
- Average Monthly Spend

This transforms transaction-level data into a **customer-level analytical dataset that can be used for reporting and business intelligence dashboards**.

## Key Business Insights

- **2013 recorded the strongest annual sales performance.**
- **December generated the highest overall monthly sales**, suggesting a seasonal sales pattern.
- **Bikes dominate overall revenue**, creating significant category concentration.
- Customer segmentation enables differentiated strategies for **VIP, Regular, and New customers**.
- Year-over-year product analysis helps identify **growth and declining product performance**.
- Customer-level KPIs provide a structured foundation for **customer behavior analysis and BI reporting**.

## SQL Skills Demonstrated

- SQL Server
- CTEs
- JOINs
- Aggregate Functions
- `GROUP BY`
- `CASE WHEN`
- `DATEPART()`
- `DATENAME()`
- `DATEDIFF()`
- `DATE_TRUNC()`
- Window Functions
- `SUM() OVER()`
- `AVG() OVER()`
- `LAG()`
- `COUNT(DISTINCT)`
- Subqueries
- Customer Segmentation
- KPI Development

## Repository Structure

```text
sql-sales-customer-analytics/
│
├── README.md
│
├── scripts/
│   ├── 01_sales_trend_analysis.sql
│   ├── 02_cumulative_analysis.sql
│   ├── 03_product_performance_analysis.sql
│   ├── 04_category_analysis.sql
│   ├── 05_product_segmentation.sql
│   ├── 06_customer_segmentation.sql
│   └── 07_customer_report.sql
│
└── docs/
    └── data_dictionary.md
