-- Month-over-month revenue growth and 3-month moving average.
-- Window functions: LAG(), AVG() OVER (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
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
       ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS prev_month_revenue,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct,
       ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly
ORDER BY month;
