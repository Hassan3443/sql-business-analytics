-- Each region's revenue, share of company revenue and rank, plus the gap to the leader.
-- Window functions: RANK(), SUM() OVER (), FIRST_VALUE()
WITH region_revenue AS (
    SELECT c.region,
           SUM(i.quantity * i.unit_price) AS revenue
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'delivered'
    JOIN order_items i ON i.order_id = o.order_id
    GROUP BY c.region
)
SELECT region,
       ROUND(revenue, 2) AS revenue,
       RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
       ROUND(100.0 * revenue / SUM(revenue) OVER (), 1) AS pct_of_total,
       ROUND(revenue - FIRST_VALUE(revenue) OVER (ORDER BY revenue DESC), 2) AS gap_to_leader
FROM region_revenue
ORDER BY revenue_rank;
