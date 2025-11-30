-- Create Retail Data Warehouse Database
CREATE DATABASE IF NOT EXISTS retail_dw;
USE retail_dw;

-- ============================================================================
-- DIMENSION TABLES
-- ============================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS dim_date (
    date_key BIGINT,
    `date` DATE,
    `day` BIGINT,
    `month` BIGINT,
    `year` BIGINT,
    weekday BIGINT,
    is_weekend BIGINT
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/dimensions/dim_date';

CREATE EXTERNAL TABLE IF NOT EXISTS dim_store (
    store_key BIGINT,
    store_id STRING,
    store_name STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/dimensions/dim_store';

CREATE EXTERNAL TABLE IF NOT EXISTS dim_product (
    product_key BIGINT,
    product_id STRING,
    item_name STRING,
    category STRING,
    supplier_id STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/dimensions/dim_product';

CREATE EXTERNAL TABLE IF NOT EXISTS dim_supplier (
    supplier_key BIGINT,
    supplier_id STRING,
    supplier_name STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/dimensions/dim_supplier';

CREATE EXTERNAL TABLE IF NOT EXISTS dim_customer (
    customer_key BIGINT,
    customer_id STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/dimensions/dim_customer';

CREATE EXTERNAL TABLE IF NOT EXISTS dim_cashier (
    cashier_key BIGINT,
    cashier_id STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/dimensions/dim_cashier';

CREATE EXTERNAL TABLE IF NOT EXISTS dim_payment (
    payment_key BIGINT,
    payment_method_id STRING,
    payment_method STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/dimensions/dim_payment';

-- ============================================================================
-- FACT TABLES
-- ============================================================================

-- Base Fact Table
CREATE EXTERNAL TABLE IF NOT EXISTS fact_sales (
    line_item_id STRING,
    transaction_id STRING,
    date_key BIGINT,
    store_key BIGINT,
    product_key BIGINT,
    customer_key BIGINT,
    cashier_key BIGINT,
    payment_key BIGINT,
    quantity BIGINT,
    price DOUBLE,
    discount DOUBLE,
    total_price DOUBLE,
    promo_flag BIGINT
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_sales';

-- Derived Fact 1: Daily Sales
CREATE EXTERNAL TABLE IF NOT EXISTS fact_daily_sales (
    date_key BIGINT,
    transaction_count BIGINT,
    total_quantity BIGINT,
    total_revenue DOUBLE,
    total_discount DOUBLE,
    avg_transaction_value DOUBLE,
    avg_discount_per_transaction DOUBLE
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_daily_sales';

-- Derived Fact 2: Store Performance
CREATE EXTERNAL TABLE IF NOT EXISTS fact_store_performance (
    store_key BIGINT,
    transaction_count BIGINT,
    customer_count BIGINT,
    total_revenue DOUBLE,
    total_quantity BIGINT,
    avg_transaction_value DOUBLE,
    avg_items_per_transaction DOUBLE
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_store_performance';

-- Derived Fact 3: Product Performance
CREATE EXTERNAL TABLE IF NOT EXISTS fact_product_performance (
    product_key BIGINT,
    transaction_count BIGINT,
    total_quantity_sold BIGINT,
    total_revenue DOUBLE,
    total_discount DOUBLE,
    avg_quantity_per_transaction DOUBLE,
    discount_rate DOUBLE
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_product_performance';

-- Semi-Additive Fact 1: Store Daily Balance
CREATE EXTERNAL TABLE IF NOT EXISTS fact_store_daily_balance (
    date_key BIGINT,
    store_key BIGINT,
    daily_revenue DOUBLE
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_store_daily_balance';

-- Semi-Additive Fact 2: Product Daily Movement
CREATE EXTERNAL TABLE IF NOT EXISTS fact_product_daily_movement (
    date_key BIGINT,
    product_key BIGINT,
    daily_quantity_sold BIGINT,
    daily_revenue DOUBLE
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_product_daily_movement';

-- Semi-Additive Fact 3: Customer Daily Activity
CREATE EXTERNAL TABLE IF NOT EXISTS fact_customer_daily_activity (
    date_key BIGINT,
    customer_key BIGINT,
    daily_spend DOUBLE,
    daily_quantity BIGINT,
    daily_transactions BIGINT
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_customer_daily_activity';

-- Factless Fact 1: Promo Coverage
CREATE EXTERNAL TABLE IF NOT EXISTS fact_promo_coverage (
    date_key BIGINT,
    store_key BIGINT,
    event_type STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_promo_coverage';

-- Factless Fact 2: Product Availability
CREATE EXTERNAL TABLE IF NOT EXISTS fact_product_availability (
    date_key BIGINT,
    product_key BIGINT,
    availability_flag BIGINT
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_product_availability';

-- Snapshot Fact 1: Daily Snapshot
CREATE EXTERNAL TABLE IF NOT EXISTS fact_daily_snapshot (
    date_key BIGINT,
    transaction_count BIGINT,
    customer_count BIGINT,
    total_quantity BIGINT,
    total_revenue DOUBLE,
    total_discount DOUBLE,
    snapshot_type STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_daily_snapshot';

-- Snapshot Fact 2: Store Snapshot
CREATE EXTERNAL TABLE IF NOT EXISTS fact_store_snapshot (
    date_key BIGINT,
    store_key BIGINT,
    transaction_count BIGINT,
    customer_count BIGINT,
    total_revenue DOUBLE,
    total_quantity BIGINT,
    snapshot_type STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_store_snapshot';

-- Accumulating Snapshot Fact 1: Customer Accumulation
CREATE EXTERNAL TABLE IF NOT EXISTS fact_customer_accumulation (
    date_key BIGINT,
    customer_key BIGINT,
    customer_cumulative_spend DOUBLE,
    customer_transaction_count BIGINT
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_customer_accumulation';

-- Accumulating Snapshot Fact 2: Store Accumulation
CREATE EXTERNAL TABLE IF NOT EXISTS fact_store_accumulation (
    date_key BIGINT,
    store_key BIGINT,
    store_cumulative_revenue DOUBLE,
    store_cumulative_transactions BIGINT
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/user/datalake/retail/facts/fact_store_accumulation';

-- ============================================================================
-- VERIFY TABLES
-- ============================================================================

SHOW TABLES;