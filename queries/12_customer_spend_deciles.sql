-- Split customers into 10 spend deciles (1 = biggest spenders) and show how
-- concentrated revenue is. Window function: NTILE(10)
WITH customer_spend AS (
    SELECT o.customer_id,
           SUM(i.quantity * i.unit_price) AS spend
    FROM orders o
    JOIN order_items i ON i.order_id = o.order_id
    WHERE o.status = 'delivered'
    GROUP BY o.customer_id
),
deciles AS (
    SELECT customer_id, spend,
           NTILE(10) OVER (ORDER BY spend DESC) AS spend_decile
    FROM customer_spend
)
SELECT spend_decile,
       COUNT(*) AS customers,
       ROUND(SUM(spend), 2) AS revenue,
       ROUND(100.0 * SUM(spend) / (SELECT SUM(spend) FROM customer_spend), 1) AS pct_of_revenue,
       ROUND(MIN(spend), 2) AS min_spend,
       ROUND(MAX(spend), 2) AS max_spend
FROM deciles
GROUP BY spend_decile
ORDER BY spend_decile;
