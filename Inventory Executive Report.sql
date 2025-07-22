USE rugaibCo

-- TASK 1: TABLEAU VIEW FOR Inventory Executive Report

CREATE VIEW v_inventory_dashboard AS
SELECT
    -- Date info for filtering/trending
    t.transaction_date,
    
    -- Product details
    p.product_id,
    p.product_name,
    p.brand_name,
    p.category,
    p.unit_cost,
    p.unit_price,
    p.is_active,

    -- Warehouse details
    w.warehouse_id,
    w.location_name,
    w.city,
    w.region,

    -- Inventory snapshot
    i.inventory_id,
    i.stock_qty,
    i.reorder_level,
    i.last_updated,
    (i.stock_qty * p.unit_cost) AS stock_value,

    -- Transactions
    t.transaction_id,
    t.transaction_type,
    t.quantity AS transaction_qty,
    t.channel,
    t.order_id

FROM inventory_transactions t
LEFT JOIN products p ON t.product_id = p.product_id
LEFT JOIN warehouses w ON t.warehouse_id = w.warehouse_id
LEFT JOIN inventory i ON t.product_id = i.product_id AND t.warehouse_id = i.warehouse_id;

-- TEST
SELECT *
FROM v_inventory_dashboard;


