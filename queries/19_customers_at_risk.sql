-- Repeat customers who have gone quiet: at least 2 delivered orders, and no order of
-- any status in the 90 days before the last order date in the data.
WITH last_day AS (SELECT MAX(order_date) AS d FROM orders),
delivered AS (
    SELECT customer_id, COUNT(*) AS delivered_orders
    FROM orders WHERE status = 'delivered'
    GROUP BY customer_id HAVING COUNT(*) >= 2
),
latest AS (
    SELECT customer_id, MAX(order_date) AS last_order FROM orders GROUP BY customer_id
)
SELECT c.customer_id, c.name, c.region, d.delivered_orders, l.last_order,
       CAST(julianday((SELECT d FROM last_day)) - julianday(l.last_order) AS INTEGER) AS days_since_last_order
FROM delivered d
JOIN latest l ON l.customer_id = d.customer_id
JOIN customers c ON c.customer_id = d.customer_id
WHERE julianday((SELECT d FROM last_day)) - julianday(l.last_order) > 90
ORDER BY d.delivered_orders DESC, days_since_last_order DESC
LIMIT 25;
