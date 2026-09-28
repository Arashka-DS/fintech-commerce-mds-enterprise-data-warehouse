CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================================
-- 1. SCHEMAS INITIALIZATION
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS raw_fintech;
CREATE SCHEMA IF NOT EXISTS raw_qcommerce;
CREATE SCHEMA IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS snapshots;

-- ============================================================================
-- 2. RAW FINTECH DOMAIN
-- ============================================================================
DROP TABLE IF EXISTS raw_fintech.customers CASCADE;
CREATE TABLE raw_fintech.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(100),
    national_id VARCHAR(20),
    phone_number VARCHAR(20),
    credit_limit_irr NUMERIC(15, 2),
    kyc_status VARCHAR(20),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

DROP TABLE IF EXISTS raw_fintech.transactions CASCADE;
CREATE TABLE raw_fintech.transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    sender_id VARCHAR(50),
    receiver_id VARCHAR(50),
    amount_irr NUMERIC(15, 2),
    transaction_type VARCHAR(30),
    initiated_at TIMESTAMP,
    settled_at TIMESTAMP,
    status VARCHAR(20)
);

-- Seed FinTech Customers
INSERT INTO raw_fintech.customers VALUES
('CUST-101', 'Amir Hossein', '0012345678', '09121111111', 150000000.00, 'VERIFIED', '2026-01-10 08:30:00', '2026-01-10 08:30:00'),
('CUST-102', 'Sara Rad', '0087654321', '09122222222', 250000000.00, 'VERIFIED', '2026-02-15 09:15:00', '2026-02-15 09:15:00'),
('CUST-103', 'Ali Karimi', '0451239874', '09123333333', 50000000.00, 'PENDING', '2026-03-01 11:00:00', '2026-03-01 11:00:00');

-- Seed FinTech Transactions (including one corrupt negative transaction)
INSERT INTO raw_fintech.transactions VALUES
('TX-9001', 'CUST-101', 'CUST-102', 12500000.00, 'PAYA_P2P', '2026-09-27 10:15:00', '2026-09-27 10:45:00', 'SETTLED'),
('TX-9002', 'CUST-102', 'CUST-103', 45000000.00, 'SATNA_B2B', '2026-09-27 11:00:00', '2026-09-27 11:12:00', 'SETTLED'),
('TX-9003', 'CUST-103', 'CUST-101', -500000.00, 'POS_DEBIT', '2026-09-27 12:00:00', '2026-09-27 12:01:00', 'FAILED'); -- Corrupt record

-- ============================================================================
-- 3. RAW Q-COMMERCE DOMAIN
-- ============================================================================
DROP TABLE IF EXISTS raw_qcommerce.darkstores CASCADE;
CREATE TABLE raw_qcommerce.darkstores (
    store_id VARCHAR(50) PRIMARY KEY,
    store_name VARCHAR(100),
    district_tehran VARCHAR(50),
    active_pickers INT,
    active_riders INT,
    is_active BOOLEAN,
    opened_date DATE
);

DROP TABLE IF EXISTS raw_qcommerce.orders CASCADE;
CREATE TABLE raw_qcommerce.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    store_id VARCHAR(50) REFERENCES raw_qcommerce.darkstores(store_id),
    customer_id VARCHAR(50),
    total_amount_irr NUMERIC(12, 2),
    order_received_at TIMESTAMP,
    picker_assigned_at TIMESTAMP,
    picking_completed_at TIMESTAMP,
    rider_dispatched_at TIMESTAMP,
    delivered_to_customer_at TIMESTAMP,
    status VARCHAR(30)
);

-- Seed Darkstores (Tehran Metro Hubs)
INSERT INTO raw_qcommerce.darkstores VALUES
('STORE-TH-01', 'Darkstore Saadat Abad', 'District 2', 8, 14, TRUE, '2025-06-01'),
('STORE-TH-02', 'Darkstore Jordan / Vali Asr', 'District 3', 10, 18, TRUE, '2025-08-15'),
('STORE-TH-03', 'Darkstore Punak / West', 'District 5', 6, 12, TRUE, '2026-01-10'),
('STORE-TH-04', 'Darkstore Narmak / East', 'District 8', 7, 10, TRUE, '2026-03-20');

-- Seed Darkstore Orders (Clean orders, SLA breaches, and corrupt timestamp records)
INSERT INTO raw_qcommerce.orders VALUES
-- 1. Perfect 18-minute delivery (SLA compliant)
('ORD-501', 'STORE-TH-01', 'CUST-101', 4200000.00, 
 '2026-09-27 18:00:00', '2026-09-27 18:01:30', '2026-09-27 18:05:45', '2026-09-27 18:08:00', '2026-09-27 18:18:20', 'DELIVERED'),

-- 2. Heavy 38-minute delivery (SLA BREACH: Rider wait bottleneck)
('ORD-502', 'STORE-TH-02', 'CUST-102', 11500000.00, 
 '2026-09-27 19:10:00', '2026-09-27 19:11:00', '2026-09-27 19:16:30', '2026-09-27 19:35:00', '2026-09-27 19:48:15', 'DELIVERED'),

-- 3. Heavy 42-minute delivery (SLA BREACH: Picker picking bottleneck)
('ORD-503', 'STORE-TH-03', 'CUST-103', 7800000.00, 
 '2026-09-27 20:00:00', '2026-09-27 20:04:00', '2026-09-27 20:25:00', '2026-09-27 20:27:00', '2026-09-27 20:42:00', 'DELIVERED'),

-- 4. Clean 22-minute delivery
('ORD-504', 'STORE-TH-01', 'CUST-102', 3100000.00, 
 '2026-09-27 20:30:00', '2026-09-27 20:31:10', '2026-09-27 20:36:00', '2026-09-27 20:38:30', '2026-09-27 20:52:00', 'DELIVERED'),

-- 5. CORRUPT RECORD: Negative picking latency (picking_completed_at before picker_assigned_at)
('ORD-505-BAD', 'STORE-TH-04', 'CUST-101', 5600000.00, 
 '2026-09-27 21:00:00', '2026-09-27 21:10:00', '2026-09-27 21:05:00', '2026-09-27 21:12:00', '2026-09-27 21:25:00', 'DELIVERED'),

-- 6. CORRUPT RECORD: Negative order total
('ORD-506-BAD', 'STORE-TH-02', 'CUST-103', -150000.00, 
 '2026-09-27 21:15:00', '2026-09-27 21:16:00', '2026-09-27 21:20:00', '2026-09-27 21:23:00', '2026-09-27 21:35:00', 'DELIVERED');
