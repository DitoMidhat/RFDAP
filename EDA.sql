USE rugaibCo;
-------------------------------------------------------------
-- 1. Database Exploration

-- List tables and their columns (exclude system diagrams)
SELECT 
    TABLE_NAME, 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME != 'sysdiagrams';

-------------------------------------------------------------
-- 2. Dimensions Exploration

-- Product count by category (8 categories total)
SELECT 
    category,
    COUNT(*) AS product_count
FROM products
GROUP BY category
ORDER BY product_count DESC;

-- Count of distinct brands and total products (17 brands, 500 products)
SELECT 
    COUNT(DISTINCT brand_name) AS brand_count,
    COUNT(*) AS product_count
FROM products;

-- Count of active products (382 active products)
SELECT 
    COUNT(DISTINCT product_name) AS active_product_count
FROM products
WHERE is_active = 1;

-- Warehouses summary by region and city (5 regions, 10 cities, 10 locations)
SELECT 
    region,
    city,
    COUNT(*) AS location_count
FROM warehouses
GROUP BY region, city
ORDER BY region, location_count DESC;

-------------------------------------------------------------
-- 3. Dates Exploration

-- Transaction date range (6 months from 2025-01-12 to 2025-07-10)
SELECT 
    MIN(transaction_date) AS first_transaction, 
    MAX(transaction_date) AS last_transaction
FROM inventory_transactions;

-------------------------------------------------------------
-- 4. Measures Exploration

-- Total Sales Value ($) (after subtracting returns)
---- 90 Milions SAR

SELECT 
    ROUND(
        SUM(CASE 
                WHEN t.transaction_type = 'OUT' THEN t.quantity * p.unit_price
                WHEN t.transaction_type = 'RETURN' THEN -1 * t.quantity * p.unit_price
                ELSE 0
            END), 
        2
    ) AS total_net_sales_value
FROM inventory_transactions t
JOIN products p ON t.product_id = p.product_id
WHERE t.transaction_type IN ('OUT', 'RETURN');


-- Summary stats for cost, price, and margins
SELECT
    -- Cost stats
    ROUND(MIN(unit_cost), 2) AS min_cost,
    ROUND(MAX(unit_cost), 2) AS max_cost,
    ROUND(AVG(unit_cost), 2) AS avg_cost,

    -- Price stats
    ROUND(MIN(unit_price), 2) AS min_price,
    ROUND(MAX(unit_price), 2) AS max_price,
    ROUND(AVG(unit_price), 2) AS avg_price,

    -- Margin stats
    ROUND(AVG(unit_price - unit_cost), 2) AS avg_margin,
    CONCAT(
        ROUND(
            AVG(
                CASE 
                    WHEN unit_price > 0 THEN (unit_price - unit_cost) * 1.0 / unit_price
                    ELSE NULL 
                END
            ) * 100, 
            2
        ), 
        '%'
    ) AS avg_margin_percent
FROM products;

-- Transaction volume by type (exclude 'TRANSFER')
SELECT 
    transaction_type,
    SUM(quantity) AS total_quantity
FROM inventory_transactions
WHERE transaction_type != 'TRANSFER'
GROUP BY transaction_type;

-- Inventory shortage analysis (excluding inactive products)
-- Percentage of product-warehouse records where stock is below reorder level
SELECT 
    COUNT(*) AS total_active_inventory_records,
    SUM(CASE WHEN i.stock_qty < i.reorder_level THEN 1 ELSE 0 END) AS shortage_count,
    ROUND(
        100.0 * SUM(CASE WHEN i.stock_qty < i.reorder_level THEN 1 ELSE 0 END) * 1.0 / COUNT(*),
        2
    ) AS shortage_percentage
FROM inventory i
JOIN products p ON i.product_id = p.product_id
WHERE p.is_active = 1;

-------------------------------------------------------------
-- 5. Magnitude Analysis

-- Sales distribution by channel
-- Sales are evenly split; each channel contributes about one-third of total sales
SELECT 
    channel,
    ROUND(100.0 * COUNT(*) * 1.0 / SUM(COUNT(*)) OVER (), 2) AS channel_percentage
FROM inventory_transactions
WHERE transaction_type = 'OUT'
GROUP BY channel
ORDER BY channel_percentage DESC;

-- Sales share by region
-- West leads with 30.22%, followed by Central, North, East (~20% each), South lowest at 9.76%
SELECT 
    w.region,
    SUM(t.quantity) AS sales_qty,
    ROUND(100.0 * SUM(t.quantity) / SUM(SUM(t.quantity)) OVER (), 2) AS sales_share_percent
FROM inventory_transactions t
JOIN warehouses w ON t.warehouse_id = w.warehouse_id
WHERE t.transaction_type = 'OUT'
GROUP BY w.region
ORDER BY sales_share_percent DESC;
