-- Expected: 31 products
SELECT COUNT(*) FROM products;

-- Expected: 50 customers
SELECT COUNT(*) FROM customers;

-- Expected: 500 orders
SELECT COUNT(*) FROM orders;

-- Expected: 6 category targets
SELECT COUNT(*) FROM category_targets;

-- Expected: Delivered 434, Cancelled 42, Pending 24
SELECT status, COUNT(*) FROM orders GROUP BY status;