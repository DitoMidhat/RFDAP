ALTER VIEW v_inventory_transactions AS
SELECT
    t.transaction_id,
    t.transaction_date,
    t.product_id,
    p.product_name,
    p.brand_name,
    p.category,
    CAST(p.unit_cost AS DECIMAL(18, 2)) AS unit_cost,
    CAST(p.unit_price AS DECIMAL(18, 2)) AS unit_price,
    t.warehouse_id,
    w.location_name,
    w.city,
    w.region,
    t.transaction_type,
    t.quantity AS transaction_qty,
    CAST(t.quantity * p.unit_cost AS DECIMAL(18, 2)) AS transaction_value,
    t.channel,
    t.order_id
FROM inventory_transactions t
JOIN products p ON t.product_id = p.product_id
JOIN warehouses w ON t.warehouse_id = w.warehouse_id;



-- Test
SELECT *
FROM v_inventory_transactions;