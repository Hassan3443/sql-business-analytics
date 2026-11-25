-- How does order value change with the number of line items in the basket?
WITH basket AS (
    SELECT o.order_id,
           COUNT(*) AS line_items,
           SUM(i.quantity) AS units,
           SUM(i.quantity * i.unit_price) AS order_value
    FROM orders o
    JOIN order_items i ON i.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.order_id
)
SELECT line_items,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM basket), 1) AS pct_of_orders,
       ROUND(AVG(units), 2) AS avg_units,
       ROUND(AVG(order_value), 2) AS avg_order_value
FROM basket
GROUP BY line_items
ORDER BY line_items;
