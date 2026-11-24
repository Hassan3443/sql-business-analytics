-- Running (cumulative) delivered revenue by month, with each month's share of the total.
-- Window functions: SUM() OVER (ORDER BY ...), SUM() OVER ()
WITH monthly AS (
    SELECT strftime('%Y-%m', o.order_date) AS month,
           SUM(i.quantity * i.unit_price) AS revenue
    FROM orders o
    JOIN order_items i ON i.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS cumulative_revenue,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 2) AS pct_of_total
FROM monthly
ORDER BY month;
