-- Which 10 products sell the most units, and what revenue do they bring?
SELECT
    p.product_name,
    p.category,
    SUM(i.quantity) AS units_sold,
    ROUND(SUM(i.quantity * i.unit_price), 2) AS revenue
FROM order_items i
JOIN orders o ON o.order_id = i.order_id AND o.status = 'delivered'
JOIN products p ON p.product_id = i.product_id
GROUP BY p.product_id
ORDER BY units_sold DESC
LIMIT 10;
