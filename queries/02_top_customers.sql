-- Who are the top 10 customers by lifetime delivered revenue?
SELECT
    c.customer_id,
    c.name,
    c.region,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(i.quantity * i.unit_price), 2) AS lifetime_revenue
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'delivered'
JOIN order_items i ON i.order_id = o.order_id
GROUP BY c.customer_id
ORDER BY lifetime_revenue DESC
LIMIT 10;
