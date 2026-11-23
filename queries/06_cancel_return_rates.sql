-- How healthy is fulfillment? Order counts and rates by status.
SELECT
    status,
    COUNT(*) AS orders,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 1) AS pct_of_orders
FROM orders
GROUP BY status
ORDER BY orders DESC;
