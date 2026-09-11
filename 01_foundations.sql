-- WHERE: orders placed by customers in Mumbai
SELECT 
    o.order_id, 
    o.amount_inr, 
    c.city

FROM orders o

JOIN customers c 
ON o.customer_id = c.customer_id

WHERE c.city = 'Mumbai';

-- DISTINCT: list every distinct category
SELECT DISTINCT category 
FROM products;

-- ORDER BY + LIMIT: top 5 highest-value orders
SELECT * 
FROM orders 
ORDER BY amount_inr DESC 
LIMIT 5;

-- Alias: count Delivered orders under a readable column name
SELECT COUNT(*) AS total_orders 
FROM orders 
WHERE status = 'Delivered';

-- IN: orders paid via UPI or Cash on Delivery
SELECT * 
FROM orders 
WHERE payment_mode IN ('UPI', 'Cash on Delivery');

-- BETWEEN: orders priced between 100 and 500
SELECT * 
FROM orders 
WHERE amount_inr BETWEEN 100 AND 500;

-- NOT BETWEEN: orders priced outside 100–500
SELECT * 
FROM orders 
WHERE amount_inr NOT BETWEEN 100 AND 500;

-- IS NULL: orders with no rating recorded (Cancelled/Pending only)
SELECT * 
FROM orders 
WHERE rating IS NULL;