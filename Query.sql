DROP TABLE IF EXISTS #shop;
-- Merging Orders from all years via CTE
WITH Orders AS 
(
    SELECT [OrderID],
           [CustomerID],
           [ProductID],
           [OrderDate],
           [Quantity],
           [Revenue],
           [COGS],
           [SourceFile]
    FROM [grid_sales].[dbo].[Orders_2023]

    UNION ALL

    SELECT [OrderID],
           [CustomerID],
           [ProductID],
           [OrderDate],
           [Quantity],
           [Revenue],
           [COGS],
           [SourceFile]
    FROM [grid_sales].[dbo].[Orders_2024]

    UNION ALL

    SELECT [OrderID],
           [CustomerID],
           [ProductID],
           [OrderDate],
           [Quantity],
           [Revenue],
           [COGS],
           [SourceFile]
    FROM [grid_sales].[dbo].[Orders_2025]
)

-- Merge customer and order table into a single table

SELECT e.OrderDate, p.ProductID, c.CustomerID, e.Quantity,(p.Price * e.Quantity) AS Revenue ,(p.Base_Cost * e.Quantity ) AS TOTAL_COST ,p.ProductName,p.ProductCategory,c.Region 

INTO #shop 

FROM Orders e
LEFT JOIN [grid_sales].[dbo].[products] p ON p.ProductID = e.ProductID
LEFT JOIN [grid_sales].[dbo].[customers] c  ON c.CustomerID = e.CustomerID


DELETE FROM #shop
WHERE 
    OrderDate IS NULL OR
    ProductID IS NULL OR
    CustomerID IS NULL OR
    Quantity IS NULL OR
    Revenue IS NULL OR
    TOTAL_COST IS NULL OR
    ProductName IS NULL OR
    ProductCategory IS NULL OR
    Region IS NULL;
--Q1
SELECT  ProductCategory, SUM(Revenue) AS TotalRevenue  FROM #shop
GROUP BY ProductCategory 
ORDER BY TotalRevenue DESC; 

--Q2
SELECT Region, ProductName, Totalorders
FROM (
    SELECT 
        Region, 
        ProductName, 
        SUM(Quantity) AS Totalorders,
        RANK() OVER (PARTITION BY Region ORDER BY SUM(Quantity) DESC) AS rn
    FROM #shop
    GROUP BY Region, ProductName
) t
WHERE rn = 1;

--Q3
SELECT  CustomerID, AVG(Revenue) AS AVG_Revenue  FROM #shop
GROUP BY CustomerID ORDER BY AVG_Revenue DESC;

-- Q4 
SELECT TOP (5) ProductName , SUM(Revenue - TOTAL_COST) AS Net_Profit FROM #shop
GROUP BY ProductName ORDER BY Net_Profit DESC;

-- Q5
SELECT 
    YEAR(OrderDate) AS OrderYear, 
    MONTH(OrderDate) AS OrderMonth, 
    SUM(Quantity) AS TotalQuantity
FROM #shop
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;

-- Q6
SELECT
    (SUM((Revenue - TOTAL_COST)) / SUM(Revenue))  AS Profit_Margin ,
    ProductName
FROM #shop
GROUP BY ProductName
HAVING (SUM((Revenue - TOTAL_COST)) / SUM(Revenue)) <= 0.2;

-- Q7
SELECT Region, CustomerID, Revenue , RN
FROM (
    SELECT Region , CustomerID , SUM(Revenue) AS Revenue,
    RANK() OVER (PARTITION BY Region ORDER BY SUM(Revenue) DESC ) as RN
    FROM #shop
    GROUP BY Region, CustomerID 
    ) t
WHERE RN = 1;

-- Q8
SELECT ProductCategory,
       SUM(Revenue) * 100.0 / SUM(SUM(Revenue)) OVER () AS ContributionPct
FROM #shop
GROUP BY ProductCategory;

-- Q9
SELECT ProductName, 
       SUM(Quantity) AS Total_Quantity,
       AVG(Revenue - TOTAL_COST) AS AVG_Revenue_Product
FROM #shop
GROUP BY ProductName
HAVING SUM(Quantity)  > 1
    AND
    AVG(Revenue - TOTAL_COST) < (SELECT AVG(AVG(Revenue - TOTAL_COST)) OVER() FROM #shop) ;

-- Q10
WITH MonthlySales AS (
    SELECT 
        YEAR(OrderDate) AS OrderYear, 
        MONTH(OrderDate) AS OrderMonth,
        SUM(Revenue) AS MonthlyRevenue
    FROM #shop
    GROUP BY YEAR(OrderDate), MONTH(OrderDate)
),
CalculatedSales AS (
      SELECT 
           OrderYear,
           OrderMonth,
           MonthlyRevenue,
           LAG(MonthlyRevenue, 1, 0) OVER (ORDER BY OrderYear, OrderMonth) AS Prev_Month_Revenue   
      FROM MonthlySales
)
SELECT 
      OrderYear,
      OrderMonth,
      MonthlyRevenue,
      Prev_Month_Revenue,
      CASE 
        WHEN Prev_Month_Revenue = 0  THEN NULL
        ELSE (((MonthlyRevenue - Prev_Month_Revenue ) * 100 ) / Prev_Month_Revenue) 
        END AS Month_Over_Month_Growth
FROM CalculatedSales
ORDER BY OrderYear, OrderMonth;

-- Q11
SELECT
    Region,
    ProductName,
    Revenue,
    RN
    FROM (
        SELECT Region,
               ProductName,
               SUM(Revenue) AS Revenue,
               RANK() OVER(PARTITION BY Region ORDER BY SUM(Revenue) DESC) as RN
        FROM #shop
        GROUP BY Region,ProductName
        ) t
WHERE RN <= 3  ORDER BY Region,RN;

-- Q12
SELECT 
    OrderDate,
    SUM(Revenue) OVER (ORDER BY OrderDate) AS RunningTotal
FROM #shop;

-- Q13
SELECT 
    CustomerID,
    OrderDate,
    DATEDIFF(DAY,
        LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate),
        OrderDate) AS DaysBetween
FROM #shop;

-- Q14
SELECT CustomerID,
       MIN(OrderDate) AS FirstOrder,
       MAX(OrderDate) AS LastOrder
FROM #shop
GROUP BY CustomerID;

-- Q15
SELECT 
    CustomerID, 
    MAX(OrderDate) AS Last_Order_Date
FROM #shop
GROUP BY CustomerID
HAVING MAX(OrderDate) <= DATEADD(MONTH, -3, GETDATE());

-- Q16
SELECT CustomerID,
       SUM(Revenue) AS TotalSpent,
       CASE 
           WHEN SUM(Revenue) > 1000 THEN 'High'
           WHEN SUM(Revenue) > 500 THEN 'Medium'
           ELSE 'Low'
       END AS Segment
FROM #shop
GROUP BY CustomerID;

-- Q17
SELECT CustomerID,
       SUM(Revenue) AS CLV
FROM #shop
GROUP BY CustomerID;

-- Q18
WITH T AS (
        SELECT 
              ProductName,
              SUM(Revenue - TOTAL_COST ) AS NET,
              SUM(Quantity) AS  Quantity
        FROM #shop
        GROUP BY ProductName
)
SELECT ProductName,
       NET,
       Quantity,
       (NET/Quantity) AS P
FROM T
ORDER BY P ;

-- Q19
SELECT *
FROM (
    SELECT Region, ProductCategory, Revenue
    FROM #shop
) src
PIVOT (
    SUM(Revenue)
    FOR ProductCategory IN ([Accessories],[Merchandise],[Subscriptions],[Grinders & Brewers],[Consumables])
) p;

-- Q20
SELECT TOP 1 Region, ProductCategory,
       SUM(Revenue) AS TotalRevenue
FROM #shop
GROUP BY Region, ProductCategory
ORDER BY TotalRevenue DESC;

-- Q21
WITH prod AS (
    SELECT ProductName,
           SUM(Revenue) AS Revenue
    FROM #shop
    GROUP BY ProductName
),
ranked AS (
    SELECT *,
           SUM(Revenue) OVER (ORDER BY Revenue DESC) * 1.0 /
           SUM(Revenue) OVER () AS CumPct
    FROM prod
)
SELECT *
FROM ranked
WHERE CumPct <= 0.8;

-- Q22
WITH OrderIntervals AS (
    SELECT 
        CustomerID,
        OrderDate,
        DATEDIFF(DAY, 
            LAG(OrderDate) OVER (PARTITION BY CustomerID ORDER BY OrderDate), 
            OrderDate
        ) AS DaysBetween
    FROM #shop
)
SELECT 
    CustomerID,
    COUNT(*) AS TotalOrders,
    AVG(CAST(DaysBetween AS FLOAT)) AS AvgDaysBetween
FROM OrderIntervals
WHERE DaysBetween IS NOT NULL 
GROUP BY CustomerID;