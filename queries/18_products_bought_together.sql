-- Which pairs of products are ordered together most often? Self-join on order_items.
-- Only orders that are not cancelled are counted.
SELECT p1.product_name AS product_a,
       p2.product_name AS product_b,
       COUNT(*) AS orders_together
FROM order_items a
JOIN order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
JOIN orders o ON o.order_id = a.order_id AND o.status <> 'cancelled'
JOIN products p1 ON p1.product_id = a.product_id
JOIN products p2 ON p2.product_id = b.product_id
GROUP BY a.product_id, b.product_id
ORDER BY orders_together DESC, product_a, product_b
LIMIT 15;
