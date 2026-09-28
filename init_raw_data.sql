CREATE SCHEMA IF NOT EXISTS raw;

CREATE TABLE raw.customers (
    customer_id INT PRIMARY KEY,
    national_id VARCHAR(10) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    vip_tier VARCHAR(20) NOT NULL,      -- 'STANDARD', 'SILVER', 'GOLD', 'VIP_PLATINUM'
    credit_limit NUMERIC(15, 2) NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE raw.transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    customer_id INT REFERENCES raw.customers(customer_id),
    amount NUMERIC(15, 2) NOT NULL,
    currency VARCHAR(5) NOT NULL,
    gateway_type VARCHAR(20) NOT NULL,  -- 'IPG', 'POS', 'CARD_TO_CARD'
    status VARCHAR(20) NOT NULL,        -- 'SETTLED', 'PENDING', 'FAILED'
    created_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP
);

-- Seed Initial State
INSERT INTO raw.customers (customer_id, national_id, full_name, vip_tier, credit_limit, updated_at) VALUES
(101, '0012345678', 'Ali Rezaei', 'STANDARD', 50000000.00, '2026-01-01 10:00:00'),
(102, '0087654321', 'Sara Tehrani', 'GOLD', 250000000.00, '2026-01-01 10:00:00'),
(103, '0045612378', 'Mohammad Moradi', 'SILVER', 100000000.00, '2026-01-01 10:00:00');

INSERT INTO raw.transactions (transaction_id, customer_id, amount, currency, gateway_type, status, created_at, completed_at) VALUES
('TX-9901', 101, 15000000.00, 'IRR', 'IPG', 'SETTLED', '2026-01-02 11:30:00', '2026-01-02 11:30:15'),
('TX-9902', 102, 85000000.00, 'IRR', 'CARD_TO_CARD', 'SETTLED', '2026-01-02 12:15:00', '2026-01-02 12:15:45'),
('TX-9903', 103, 30000000.00, 'IRR', 'POS', 'SETTLED', '2026-01-03 14:00:00', '2026-01-03 14:01:10');
