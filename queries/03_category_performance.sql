-- Which product categories drive revenue and units sold?
SELECT
    p.category,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(i.quantity) AS units_sold,
    ROUND(SUM(i.quantity * i.unit_price), 2) AS revenue,
    ROUND(100.0 * SUM(i.quantity * i.unit_price) /
        (SELECT SUM(quantity * unit_price) FROM order_items i2
         JOIN orders o2 ON o2.order_id = i2.order_id AND o2.status = 'delivered'), 1) AS revenue_share_pct
FROM order_items i
JOIN orders o ON o.order_id = i.order_id AND o.status = 'delivered'
JOIN products p ON p.product_id = i.product_id
GROUP BY p.category
ORDER BY revenue DESC;
