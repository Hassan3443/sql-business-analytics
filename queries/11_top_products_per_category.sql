-- Top 3 products by revenue inside each category.
-- Window function: RANK() OVER (PARTITION BY category ORDER BY revenue DESC)
WITH product_revenue AS (
    SELECT p.category,
           p.product_name,
           SUM(i.quantity * i.unit_price) AS revenue
    FROM order_items i
    JOIN products p ON p.product_id = i.product_id
    JOIN orders o ON o.order_id = i.order_id AND o.status = 'delivered'
    GROUP BY p.category, p.product_name
),
ranked AS (
    SELECT category, product_name, revenue,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank
    FROM product_revenue
)
SELECT category, category_rank, product_name, ROUND(revenue, 2) AS revenue
FROM ranked
WHERE category_rank <= 3
ORDER BY category, category_rank;
