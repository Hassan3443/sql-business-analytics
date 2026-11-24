-- For every customer: first order, latest order, and order count, using
-- ROW_NUMBER() to pick the first and latest rows. Shows the 20 most recent first orders.
WITH numbered AS (
    SELECT o.customer_id,
           o.order_id,
           o.order_date,
           ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date, o.order_id) AS rn_first,
           ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date DESC, o.order_id DESC) AS rn_last,
           COUNT(*) OVER (PARTITION BY o.customer_id) AS total_orders
    FROM orders o
)
SELECT f.customer_id,
       f.order_date AS first_order_date,
       l.order_date AS latest_order_date,
       f.total_orders,
       CAST(julianday(l.order_date) - julianday(f.order_date) AS INTEGER) AS customer_lifetime_days
FROM numbered f
JOIN numbered l ON l.customer_id = f.customer_id AND l.rn_last = 1
WHERE f.rn_first = 1
ORDER BY f.order_date DESC, f.customer_id
LIMIT 20;
