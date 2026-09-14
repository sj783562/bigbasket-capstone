-- (a) CASE WHEN: tier every product by Delivered revenue
SELECT 
    p.product_name,
    SUM(o.amount_inr) AS total_revenue,
    CASE
        WHEN SUM(o.amount_inr) >= 3000 THEN 'High'
        WHEN SUM(o.amount_inr) >= 1000 THEN 'Medium'
        ELSE 'Low'
    END AS revenue_tier

FROM orders o

JOIN products p 
ON o.product_id = p.product_id

WHERE o.status = 'Delivered'
GROUP BY p.product_name;

-- (b) Monthly category report (Delivered only) — this is the query exported as monthly_category_revenue.csv
SELECT 
    p.category,
    strftime('%Y-%m', o.order_date) AS month,
    COUNT(*) AS order_count,
    SUM(o.amount_inr) AS total_revenue,
    AVG(o.amount_inr) AS avg_revenue

FROM orders o

JOIN products p 
ON o.product_id = p.product_id

WHERE o.status = 'Delivered'
GROUP BY 
    p.category, 
    month

ORDER BY 
    p.category, 
    month;

-- (c) Variance vs target, with Above/Watch/Critical tiering
WITH category_revenue AS (
    SELECT
        p.category,
        SUM(o.amount_inr) AS total_revenue

    FROM orders o

    JOIN products p 
    ON o.product_id = p.product_id

    WHERE o.status = 'Delivered'
    GROUP BY p.category
)

SELECT
    r.category,
    r.total_revenue,
    t.target_revenue_inr,
    (r.total_revenue - t.target_revenue_inr) AS variance,
    CASE
        WHEN t.target_revenue_inr = 0 THEN NULL
        ELSE ((r.total_revenue - t.target_revenue_inr) * 100.0) / t.target_revenue_inr
    END AS pct_variance,
    CASE
        WHEN r.total_revenue >= t.target_revenue_inr THEN 'Above Target'
        WHEN r.total_revenue >= t.target_revenue_inr * 0.85 THEN 'Below Target - Watch'
        ELSE 'Below Target - Critical'
    END AS status

FROM category_revenue r

JOIN category_targets t 
ON r.category = t.category;
