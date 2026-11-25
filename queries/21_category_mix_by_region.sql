-- Share of each region's delivered revenue that comes from each category (a pivot with CASE).
WITH rev AS (
    SELECT c.region, p.category, SUM(i.quantity * i.unit_price) AS revenue
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    JOIN order_items i ON i.order_id = o.order_id
    JOIN products p ON p.product_id = i.product_id
    WHERE o.status = 'delivered'
    GROUP BY c.region, p.category
)
SELECT region,
       ROUND(SUM(revenue), 0) AS total_revenue,
       ROUND(100.0 * SUM(CASE WHEN category = 'Electronics' THEN revenue END) / SUM(revenue), 1) AS electronics_pct,
       ROUND(100.0 * SUM(CASE WHEN category = 'Books' THEN revenue END) / SUM(revenue), 1) AS books_pct,
       ROUND(100.0 * SUM(CASE WHEN category NOT IN ('Electronics', 'Books') THEN revenue END) / SUM(revenue), 1) AS other_pct
FROM rev
GROUP BY region
ORDER BY total_revenue DESC;
