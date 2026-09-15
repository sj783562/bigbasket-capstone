-- Expected: 31 products
SELECT COUNT(*) AS total_products
FROM products;

-- Expected: 50 customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Expected: 500 orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Expected: 6 category targets
SELECT COUNT(*) AS total_category
FROM category_targets;

-- Expected: Delivered 434, Cancelled 42, Pending 24
SELECT 
  status, 
  COUNT(*) AS total_no_of_each_delivery
  
FROM orders 
GROUP BY status;
