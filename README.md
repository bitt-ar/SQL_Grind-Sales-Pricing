# Grid Sales Database Analysis Project ☕

![Dashboard Image](https://github.com/user-attachments/assets/8f3ff611-d59a-47d7-9405-064190615443)

## Project Overview
This project presents a comprehensive data analysis of the Grid Sales Database, covering multi-year sales data from 2023 to 2025. The scope includes detailed analysis of orders, products, and customers across four distinct geographical regions (North, South, East, West).

The goal of this project is to transform raw relational data into actionable business intelligence through progressive SQL analysis, uncovering insights related to revenue concentration, regional performance, customer behavior, and product profitability.

## Repository Contents
- `Query.sql`: Contains the complete set of SQL queries used for data extraction and analysis.
- `Sales_Analysis_Report.md`: A detailed report documenting the methodology, queries, results, and business interpretations for 22 specific analytical questions.
- `dashboard.pbix`: Power BI dashboard file providing interactive visual representations of the key metrics and findings.

## Analysis Framework
The analysis is structured linearly, progressing from fundamental metrics to advanced statistical concepts and actionable business recommendations:

### 1. Data Architecture & Preparation
- **Unified Dataset:** Combined annual order tables (`Orders_2023`, `Orders_2024`, `Orders_2025`) using `UNION ALL` CTEs.
- **Data Enrichment:** Joined transactional data with `products` and `customers` dimension tables to append metadata (revenue, cost, categories, regions).
- **Data Integrity:** Cleansed the dataset by removing records containing critical `NULL` values to ensure analytical accuracy.

### 2. Basic to Intermediate Analysis
Exploratory data analysis focusing on core performance indicators:
- Total revenue breakdowns by product category.
- Identification of best-selling products by volume per region.
- Analysis of average order value (AOV) per customer.
- Ranking of the top 5 most profitable products.
- Monthly order volume trend analysis outlining strong seasonal patterns (Q4 spikes).

### 3. Advanced Analysis
Deeper exploration utilizing complex aggregations and logic:
- Identification of underperforming products (margins < 20%).
- Top regional customers by cumulative spend.
- Revenue contribution percentages illustrating the dominance of the 'Grinders & Brewers' hardware category.
- Isolation of high-volume products yielding below-average profit margins (pricing issue detection).
- Month-over-Month (MoM) revenue growth measurement.

### 4. Window Functions — Advanced SQL
Leveraging advanced SQL capabilities for nuanced insights:
- Regional top 3 product rankings utilizing `RANK() OVER (PARTITION BY...)`.
- Calculation of running revenue totals over time indicating growth inflection points.
- Time-based intervals (days elapsed) between consecutive orders per customer using `LAG()` functions.
- Extraction of the first and last transaction dates to determine customer lifespan.

### 5. Business-Oriented Insights
Translating data points into strategic business segments:
- **Churn Identification:** Flagging customers with no purchases in the last 90 days.
- **Customer Segmentation:** Tiering customers into High, Medium, and Low value categories based on lifetime spend thresholds.
- **Customer Lifetime Value (CLV):** Aggregating total historical spend per user.

### 6. Expert Level — Real-World Thinking
Applying commercial consulting frameworks:
- **Matrix Views:** Restructuring data using `PIVOT` to analyze Region vs. Product Category performance simultaneously.
- **Pareto Principle (80/20 Rule):** Determining that just 10 products out of the catalog drive 80% of total revenue.
- **Behavioral Analysis:** Quantifying average inter-purchase intervals (34–57 days) to target retention efforts effectively.

## Key Executive Insights
1. **Revenue Concentration:** ~58% of revenue is reliant on the 'Grinders & Brewers' category. The top 10 products generate 80% of all sales. Diversification is necessary.
2. **Seasonality:** Extreme Q4 volume spikes (specifically December) require embedded operational planning well in advance.
3. **Pricings Gaps:** Specific high-volume, low-margin products (e.g., Chemex Filters, keychains) are priced inefficiently and represent immediate opportunities for margin improvement via slight price increases.
4. **Subscription Potential:** Subscriptions account for ~19% of revenue. Given the 34-55 day average repurchase cycle, converting transactional buyers to subscriptions is a massive opportunity for stable recurring revenue.

## Technologies Used
- SQL Server (T-SQL)
- Power BI
- Markdown for documentation
