-- Quarterly active customers and how many of them were also active the previous quarter.
-- Uses a self-join on a CTE plus LAG() for the quarter-over-quarter change.
WITH active AS (
    SELECT DISTINCT o.customer_id,
           strftime('%Y', o.order_date) || '-Q' ||
               ((CAST(strftime('%m', o.order_date) AS INTEGER) + 2) / 3) AS quarter
    FROM orders o
    WHERE o.status IN ('delivered', 'shipped')
),
per_quarter AS (
    SELECT quarter, COUNT(*) AS active_customers FROM active GROUP BY quarter
),
retained AS (
    SELECT cur.quarter,
           COUNT(*) AS retained_customers
    FROM active cur
    JOIN active prev
      ON prev.customer_id = cur.customer_id
     AND prev.quarter = (
            CASE
              WHEN substr(cur.quarter, 7, 1) = '1'
                THEN CAST(CAST(substr(cur.quarter, 1, 4) AS INTEGER) - 1 AS TEXT) || '-Q4'
              ELSE substr(cur.quarter, 1, 6) || CAST(CAST(substr(cur.quarter, 7, 1) AS INTEGER) - 1 AS TEXT)
            END)
    GROUP BY cur.quarter
)
SELECT p.quarter,
       p.active_customers,
       COALESCE(r.retained_customers, 0) AS retained_from_prev_quarter,
       ROUND(100.0 * COALESCE(r.retained_customers, 0) / LAG(p.active_customers) OVER (ORDER BY p.quarter), 1) AS retention_pct,
       p.active_customers - LAG(p.active_customers) OVER (ORDER BY p.quarter) AS change_vs_prev_quarter
FROM per_quarter p
LEFT JOIN retained r ON r.quarter = p.quarter
ORDER BY p.quarter;
