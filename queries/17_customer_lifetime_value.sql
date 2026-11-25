-- Customer lifetime value so far: delivered revenue, orders, average order value and
-- active days for each customer, with a value tier. Window function: NTILE(4)
WITH per_order AS (
    SELECT o.customer_id, o.order_id, o.order_date,
           SUM(i.quantity * i.unit_price) AS order_value
    FROM orders o
    JOIN order_items i ON i.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.customer_id, o.order_id, o.order_date
),
per_customer AS (
    SELECT customer_id,
           COUNT(*) AS orders,
           ROUND(SUM(order_value), 2) AS lifetime_value,
           ROUND(AVG(order_value), 2) AS avg_order_value,
           CAST(julianday(MAX(order_date)) - julianday(MIN(order_date)) AS INTEGER) AS active_days
    FROM per_order
    GROUP BY customer_id
)
SELECT customer_id, orders, lifetime_value, avg_order_value, active_days,
       CASE NTILE(4) OVER (ORDER BY lifetime_value DESC)
            WHEN 1 THEN 'Top 25%' WHEN 2 THEN 'Upper middle'
            WHEN 3 THEN 'Lower middle' ELSE 'Bottom 25%' END AS value_tier
FROM per_customer
ORDER BY lifetime_value DESC;
