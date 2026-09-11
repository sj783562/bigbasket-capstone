-- (a) INNER JOIN + HAVING: category revenue for Delivered orders, filtered above 10000
SELECT 
    p.category,
    COUNT(*) AS order_count,
    SUM(o.amount_inr) AS total_revenue,
    AVG(o.amount_inr) AS avg_revenue

FROM orders o

INNER JOIN products p 
ON o.product_id = p.product_id

WHERE o.status = 'Delivered'
GROUP BY p.category
HAVING total_revenue > 10000;

-- (b) LEFT JOIN: order count per product, including products with zero orders
-- Premium Face Cream 50g must appear here with order_count = 0
SELECT 
    p.product_name, 
    COUNT(o.order_id) AS order_count

FROM products p

LEFT JOIN orders o 
ON p.product_id = o.product_id

GROUP BY p.product_name
ORDER BY order_count ASC;