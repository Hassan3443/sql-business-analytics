-- Do older customer cohorts (by signup quarter) spend more?
SELECT
    strftime('%Y', c.signup_date) || '-Q' ||
        ((CAST(strftime('%m', c.signup_date) AS INTEGER) + 2) / 3) AS signup_quarter,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(i.quantity * i.unit_price), 2) AS revenue,
    ROUND(SUM(i.quantity * i.unit_price) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'delivered'
JOIN order_items i ON i.order_id = o.order_id
GROUP BY signup_quarter
ORDER BY signup_quarter;
