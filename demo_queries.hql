USE retail_dw;

-- ============================================================================
-- DEMO QUERIES FOR PRESENTATION
-- ============================================================================

-- Query 1: Total Sales by Store
SELECT 
    s.store_name,
    SUM(f.total_price) as total_revenue,
    SUM(f.quantity) as total_items_sold,
    COUNT(DISTINCT f.transaction_id) as total_transactions
FROM fact_sales f
JOIN dim_store s ON f.store_key = s.store_key
GROUP BY s.store_name
ORDER BY total_revenue DESC;

-- Query 2: Daily Sales Trend
SELECT 
    date_key,
    SUM(total_price) as daily_revenue,
    COUNT(DISTINCT transaction_id) as daily_transactions
FROM fact_sales
GROUP BY date_key
ORDER BY date_key
LIMIT 30;

-- Query 3: Product Category Performance
SELECT 
    p.category,
    SUM(f.total_price) as revenue,
    SUM(f.quantity) as units_sold,
    SUM(f.discount) as total_discount,
    COUNT(DISTINCT f.transaction_id) as transactions
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY revenue DESC;

-- Query 4: Top 10 Best Selling Products
SELECT 
    p.item_name,
    p.category,
    s.supplier_name,
    SUM(f.quantity) as total_sold,
    SUM(f.total_price) as total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_supplier s ON p.supplier_id = s.supplier_id
GROUP BY p.item_name, p.category, s.supplier_name
ORDER BY total_sold DESC
LIMIT 10;

-- Query 5: Payment Method Analysis
SELECT 
    pm.payment_method,
    COUNT(DISTINCT f.transaction_id) as transaction_count,
    SUM(f.total_price) as total_revenue,
    ROUND(AVG(f.total_price), 2) as avg_transaction_value
FROM fact_sales f
JOIN dim_payment pm ON f.payment_key = pm.payment_key
GROUP BY pm.payment_method
ORDER BY total_revenue DESC;

-- Query 6: Weekend vs Weekday Sales
SELECT 
    CASE WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END as day_type,
    SUM(f.total_price) as total_revenue,
    COUNT(DISTINCT f.transaction_id) as total_transactions,
    ROUND(AVG(f.total_price), 2) as avg_transaction_value
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.is_weekend
ORDER BY day_type;

-- Query 7: Promo Effectiveness (Factless Fact)
SELECT 
    pc.date_key,
    COUNT(DISTINCT pc.store_key) as stores_with_promo,
    pc.event_type
FROM fact_promo_coverage pc
GROUP BY pc.date_key, pc.event_type
ORDER BY pc.date_key
LIMIT 20;

-- Query 8: Store Performance Over Time (Accumulating Snapshot)
SELECT 
    d.`date`,
    s.store_name,
    sa.store_cumulative_revenue,
    sa.store_cumulative_transactions
FROM fact_store_accumulation sa
JOIN dim_store s ON sa.store_key = s.store_key
JOIN dim_date d ON sa.date_key = d.date_key
WHERE s.store_id = 'IM001'
ORDER BY d.`date`;

-- Query 9: Customer Lifetime Value Growth (Accumulating Snapshot)
SELECT 
    d.`date`,
    ca.customer_key,
    ca.customer_cumulative_spend,
    ca.customer_transaction_count
FROM fact_customer_accumulation ca
JOIN dim_date d ON ca.date_key = d.date_key
WHERE ca.customer_key IN (1, 2, 3, 4, 5)
ORDER BY ca.customer_key, d.`date`;

-- Query 10: Supplier Performance
SELECT 
    sup.supplier_name,
    COUNT(DISTINCT p.product_id) as product_count,
    SUM(f.quantity) as total_units_sold,
    SUM(f.total_price) as total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_supplier sup ON f.supplier_key = sup.supplier_key
GROUP BY sup.supplier_name
ORDER BY total_revenue DESC;