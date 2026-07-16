-- ============================================================================
-- RETAIL SALES ANALYTICS — DATABASE SCHEMA
-- Enterprise-Grade PostgreSQL Schema Design
-- ============================================================================
-- Author:  Senior Data Engineer
-- Created: 2025-01-01
-- Description: Normalized relational schema for retail sales analytics
--              with proper constraints, indexes, and data integrity rules.
-- ============================================================================

-- Create schema
CREATE SCHEMA IF NOT EXISTS retail_analytics;
SET search_path TO retail_analytics;

-- ============================================================================
-- TABLE 1: CUSTOMERS
-- Master customer data with demographics and loyalty information
-- ============================================================================
CREATE TABLE customers (
    customer_id     SERIAL PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    email           VARCHAR(120)    NOT NULL UNIQUE,
    phone           VARCHAR(20),
    date_of_birth   DATE,
    gender          VARCHAR(10)     CHECK (gender IN ('Male', 'Female', 'Other', 'Prefer Not to Say')),
    city            VARCHAR(100)    NOT NULL,
    state           VARCHAR(50)     NOT NULL,
    country         VARCHAR(50)     NOT NULL DEFAULT 'United States',
    zip_code        VARCHAR(10),
    loyalty_tier    VARCHAR(20)     NOT NULL DEFAULT 'Bronze'
                                    CHECK (loyalty_tier IN ('Bronze', 'Silver', 'Gold', 'Platinum')),
    join_date       DATE            NOT NULL DEFAULT CURRENT_DATE,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- TABLE 2: PRODUCTS
-- Product catalog with pricing, cost, and categorization
-- ============================================================================
CREATE TABLE products (
    product_id      SERIAL PRIMARY KEY,
    product_name    VARCHAR(150)    NOT NULL,
    sku             VARCHAR(30)     NOT NULL UNIQUE,
    category        VARCHAR(50)     NOT NULL,
    sub_category    VARCHAR(50),
    brand           VARCHAR(80)     NOT NULL,
    unit_price      NUMERIC(10,2)   NOT NULL CHECK (unit_price > 0),
    unit_cost       NUMERIC(10,2)   NOT NULL CHECK (unit_cost > 0),
    margin_pct      NUMERIC(5,2)    GENERATED ALWAYS AS (
                        ROUND(((unit_price - unit_cost) / unit_price) * 100, 2)
                    ) STORED,
    weight_kg       NUMERIC(8,3),
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    launch_date     DATE            NOT NULL DEFAULT CURRENT_DATE,
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- TABLE 3: STORES
-- Physical store locations with regional grouping
-- ============================================================================
CREATE TABLE stores (
    store_id        SERIAL PRIMARY KEY,
    store_name      VARCHAR(100)    NOT NULL,
    store_code      VARCHAR(10)     NOT NULL UNIQUE,
    store_type      VARCHAR(20)     NOT NULL
                                    CHECK (store_type IN ('Flagship', 'Standard', 'Outlet', 'Express')),
    address         VARCHAR(200),
    city            VARCHAR(100)    NOT NULL,
    state           VARCHAR(50)     NOT NULL,
    region          VARCHAR(30)     NOT NULL
                                    CHECK (region IN ('Northeast', 'Southeast', 'Midwest', 'Southwest', 'West')),
    country         VARCHAR(50)     NOT NULL DEFAULT 'United States',
    zip_code        VARCHAR(10),
    phone           VARCHAR(20),
    manager_name    VARCHAR(100),
    square_footage  INTEGER         CHECK (square_footage > 0),
    opened_date     DATE            NOT NULL,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- TABLE 4: TRANSACTIONS
-- Order header records with payment and discount information
-- ============================================================================
CREATE TABLE transactions (
    transaction_id  SERIAL PRIMARY KEY,
    transaction_date TIMESTAMP      NOT NULL,
    customer_id     INTEGER         NOT NULL REFERENCES customers(customer_id)
                                    ON DELETE RESTRICT ON UPDATE CASCADE,
    store_id        INTEGER         NOT NULL REFERENCES stores(store_id)
                                    ON DELETE RESTRICT ON UPDATE CASCADE,
    payment_method  VARCHAR(30)     NOT NULL
                                    CHECK (payment_method IN (
                                        'Credit Card', 'Debit Card', 'Cash',
                                        'Mobile Payment', 'Gift Card', 'Store Credit'
                                    )),
    subtotal        NUMERIC(12,2)   NOT NULL CHECK (subtotal >= 0),
    discount_amount NUMERIC(12,2)   NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    tax_amount      NUMERIC(12,2)   NOT NULL DEFAULT 0 CHECK (tax_amount >= 0),
    total_amount    NUMERIC(12,2)   NOT NULL CHECK (total_amount >= 0),
    discount_code   VARCHAR(30),
    order_status    VARCHAR(20)     NOT NULL DEFAULT 'Completed'
                                    CHECK (order_status IN (
                                        'Completed', 'Pending', 'Cancelled', 'Refunded', 'Returned'
                                    )),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- TABLE 5: TRANSACTION_ITEMS
-- Individual line items within each transaction
-- ============================================================================
CREATE TABLE transaction_items (
    item_id         SERIAL PRIMARY KEY,
    transaction_id  INTEGER         NOT NULL REFERENCES transactions(transaction_id)
                                    ON DELETE CASCADE ON UPDATE CASCADE,
    product_id      INTEGER         NOT NULL REFERENCES products(product_id)
                                    ON DELETE RESTRICT ON UPDATE CASCADE,
    quantity        INTEGER         NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2)   NOT NULL CHECK (unit_price > 0),
    discount_pct    NUMERIC(5,2)    NOT NULL DEFAULT 0 CHECK (discount_pct >= 0 AND discount_pct <= 100),
    line_total      NUMERIC(12,2)   NOT NULL CHECK (line_total >= 0),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- INDEXES — Optimized for analytical query patterns
-- ============================================================================

-- Customers: Lookup by location, loyalty, activity
CREATE INDEX idx_customers_city_state      ON customers(city, state);
CREATE INDEX idx_customers_loyalty_tier    ON customers(loyalty_tier);
CREATE INDEX idx_customers_join_date       ON customers(join_date);
CREATE INDEX idx_customers_active          ON customers(is_active) WHERE is_active = TRUE;

-- Products: Category-based analytics, SKU lookups
CREATE INDEX idx_products_category         ON products(category);
CREATE INDEX idx_products_cat_subcat       ON products(category, sub_category);
CREATE INDEX idx_products_brand            ON products(brand);
CREATE INDEX idx_products_price_range      ON products(unit_price);
CREATE INDEX idx_products_active           ON products(is_active) WHERE is_active = TRUE;

-- Stores: Regional analysis
CREATE INDEX idx_stores_region             ON stores(region);
CREATE INDEX idx_stores_type               ON stores(store_type);
CREATE INDEX idx_stores_active             ON stores(is_active) WHERE is_active = TRUE;

-- Transactions: Date-based queries (most critical for analytics)
CREATE INDEX idx_txn_date                  ON transactions(transaction_date);
CREATE INDEX idx_txn_date_desc             ON transactions(transaction_date DESC);
CREATE INDEX idx_txn_customer              ON transactions(customer_id);
CREATE INDEX idx_txn_store                 ON transactions(store_id);
CREATE INDEX idx_txn_customer_date         ON transactions(customer_id, transaction_date);
CREATE INDEX idx_txn_store_date            ON transactions(store_id, transaction_date);
CREATE INDEX idx_txn_status                ON transactions(order_status);
CREATE INDEX idx_txn_payment               ON transactions(payment_method);
CREATE INDEX idx_txn_completed             ON transactions(transaction_date)
                                           WHERE order_status = 'Completed';

-- Transaction Items: Product analytics, join optimization
CREATE INDEX idx_items_transaction         ON transaction_items(transaction_id);
CREATE INDEX idx_items_product             ON transaction_items(product_id);
CREATE INDEX idx_items_txn_product         ON transaction_items(transaction_id, product_id);

-- ============================================================================
-- TRIGGERS — Auto-update timestamps
-- ============================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_customers_updated_at
    BEFORE UPDATE ON customers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_stores_updated_at
    BEFORE UPDATE ON stores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTS — Documentation for schema objects
-- ============================================================================
COMMENT ON SCHEMA retail_analytics IS 'Enterprise retail sales analytics data warehouse';
COMMENT ON TABLE customers IS 'Master customer records with demographics and loyalty data';
COMMENT ON TABLE products IS 'Product catalog with pricing, cost, and margin calculations';
COMMENT ON TABLE stores IS 'Physical retail store locations with regional grouping';
COMMENT ON TABLE transactions IS 'Order header records capturing payment and discount details';
COMMENT ON TABLE transaction_items IS 'Individual line items within each transaction';
COMMENT ON COLUMN products.margin_pct IS 'Auto-calculated gross margin percentage';
COMMENT ON COLUMN transactions.total_amount IS 'Final amount: subtotal - discount + tax';
