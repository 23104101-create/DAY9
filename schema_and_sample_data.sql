-- Day 9 Set 3: Telecom Low-Balance Follow-up
-- MySQL 8.4
-- Run this file first.

CREATE DATABASE IF NOT EXISTS telecom_db;
USE telecom_db;

CREATE TABLE IF NOT EXISTS plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(50) NOT NULL,
    recharge_amount DECIMAL(10,2) NOT NULL,
    validity_days INT NOT NULL
);

CREATE TABLE IF NOT EXISTS subscribers (
    subscriber_id INT PRIMARY KEY,
    subscriber_name VARCHAR(100) NOT NULL,
    user_type VARCHAR(20) NOT NULL,
    phone_number VARCHAR(20),
    email VARCHAR(100),
    balance DECIMAL(10,2) NOT NULL DEFAULT 0,
    plan_id INT,
    validity_end DATE,
    CONSTRAINT fk_subscriber_plan
        FOREIGN KEY (plan_id) REFERENCES plans(plan_id),
    CONSTRAINT chk_user_type
        CHECK (user_type IN ('PREPAID', 'POSTPAID')),
    CONSTRAINT chk_balance CHECK (balance >= 0)
);

CREATE TABLE IF NOT EXISTS recharge_history (
    recharge_id INT AUTO_INCREMENT PRIMARY KEY,
    subscriber_id INT NOT NULL,
    plan_id INT NOT NULL,
    recharge_amount DECIMAL(10,2) NOT NULL,
    recharge_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    balance_after DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id),
    FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
);

CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    subscriber_id INT NOT NULL,
    message VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subscriber_id) REFERENCES subscribers(subscriber_id)
);

INSERT IGNORE INTO plans VALUES
(1, 'Basic 28 Days', 99.00, 28),
(2, 'Value 56 Days', 199.00, 56),
(3, 'Plus 84 Days', 299.00, 84);

INSERT IGNORE INTO subscribers
(subscriber_id, subscriber_name, user_type, phone_number, email, balance, plan_id, validity_end)
VALUES
(101, 'Arun',  'PREPAID',  '9000000001', 'arun@example.com',  25.00, 1, DATE_ADD(CURDATE(), INTERVAL 10 DAY)),
(102, 'Priya', 'PREPAID',  '9000000002', 'priya@example.com', 75.00, 2, DATE_ADD(CURDATE(), INTERVAL 20 DAY)),
(103, 'Ravi',  'PREPAID',  '9000000003', 'ravi@example.com',  10.00, 1, DATE_ADD(CURDATE(), INTERVAL  3 DAY)),
(104, 'Meena', 'POSTPAID', '9000000004', 'meena@example.com',  0.00, 3, DATE_ADD(CURDATE(), INTERVAL 30 DAY)),
(105, 'Kiran', 'PREPAID',  '9000000005', 'kiran@example.com', 45.00, 2, DATE_ADD(CURDATE(), INTERVAL -2 DAY)),
(106, 'Divya', 'PREPAID',  '9000000006', 'divya@example.com', 150.00, 3, DATE_ADD(CURDATE(), INTERVAL 40 DAY));
