-- How do regions compare on revenue, customers and average order value?
SELECT
    c.region,
    COUNT(DISTINCT c.customer_id) AS customers,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(i.quantity * i.unit_price), 2) AS revenue,
    ROUND(SUM(i.quantity * i.unit_price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'delivered'
JOIN order_items i ON i.order_id = o.order_id
GROUP BY c.region
ORDER BY revenue DESC;
