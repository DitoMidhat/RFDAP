ALTER VIEW v_inventory_snapshot AS
SELECT
    i.inventory_id,
    i.product_id,
    p.product_name,
    p.brand_name,
    p.category,
    CAST(p.unit_cost AS DECIMAL(18, 2)) AS unit_cost,
    CAST(p.unit_price AS DECIMAL(18, 2)) AS unit_price,
    p.is_active,
    i.warehouse_id,
    w.location_name,
    w.city,
    w.region,
    i.stock_qty,
    i.reorder_level,
    i.last_updated,
    CAST(i.stock_qty * p.unit_cost AS DECIMAL(18, 2)) AS stock_value
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN warehouses w ON i.warehouse_id = w.warehouse_id;


-- 
SELECT *
FROM v_inventory_snapshot;
