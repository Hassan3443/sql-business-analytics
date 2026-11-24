-- Average days between consecutive orders per repeat customer.
-- Window function: LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)
WITH gaps AS (
    SELECT customer_id,
           order_date,
           julianday(order_date)
             - julianday(LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id)) AS days_since_prev
    FROM orders
    WHERE status IN ('delivered', 'shipped')
)
SELECT customer_id,
       COUNT(days_since_prev) AS repeat_orders,
       ROUND(AVG(days_since_prev), 1) AS avg_days_between_orders,
       MIN(days_since_prev) AS shortest_gap,
       MAX(days_since_prev) AS longest_gap
FROM gaps
WHERE days_since_prev IS NOT NULL
GROUP BY customer_id
ORDER BY repeat_orders DESC, avg_days_between_orders
LIMIT 20;
