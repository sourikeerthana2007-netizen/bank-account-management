USE bank_management;

-- =========================================
-- 1. CUSTOMERS
-- =========================================

INSERT INTO customer
(customer_id, first_name, last_name, phone, email, address, date_of_birth)
VALUES
(1, 'Rahul', 'Sharma', '9876500001', 'rahul.sharma@email.com',
 'Hyderabad', '2003-04-15'),

(2, 'Ananya', 'Reddy', '9876500002', 'ananya.reddy@email.com',
 'Hyderabad', '2002-08-21'),

(3, 'Arjun', 'Kumar', '9876500003', 'arjun.kumar@email.com',
 'Secunderabad', '2003-01-10'),

(4, 'Sneha', 'Patel', '9876500004', 'sneha.patel@email.com',
 'Bengaluru', '2002-11-05'),

(5, 'Vikram', 'Singh', '9876500005', 'vikram.singh@email.com',
 'Mumbai', '2001-07-19'),

(6, 'Priya', 'Nair', '9876500006', 'priya.nair@email.com',
 'Kochi', '2003-02-28'),

(7, 'Karthik', 'Rao', '9876500007', 'karthik.rao@email.com',
 'Hyderabad', '2002-06-12'),

(8, 'Meera', 'Iyer', '9876500008', 'meera.iyer@email.com',
 'Chennai', '2003-09-30');


-- =========================================
-- 2. BRANCHES
-- =========================================

INSERT INTO branch
(branch_id, branch_name, branch_code, address, phone)
VALUES
(1, 'Hyderabad Main Branch', 'HYD001',
 'Banjara Hills, Hyderabad', '04040000001'),

(2, 'Secunderabad Branch', 'SEC002',
 'Secunderabad, Hyderabad', '04040000002'),

(3, 'Gachibowli Branch', 'GCH003',
 'Gachibowli, Hyderabad', '04040000003');


-- =========================================
-- 3. ACCOUNT TYPES
-- =========================================

INSERT INTO account_type
(account_type_id, type_name, description, minimum_balance)
VALUES
(1, 'Savings',
 'Savings account for personal banking', 1000.00),

(2, 'Current',
 'Current account for regular transactions', 5000.00),

(3, 'Salary',
 'Salary account with low minimum balance', 0.00);


-- =========================================
-- 4. ACCOUNTS
-- =========================================

INSERT INTO account
(account_id, account_number, account_type_id, branch_id,
 balance, status, opening_date)
VALUES
(1, '1000000001', 1, 1, 24500.00, 'ACTIVE', '2025-01-10'),

(2, '1000000002', 1, 1, 18200.00, 'ACTIVE', '2025-02-15'),

(3, '1000000003', 2, 2, 75000.00, 'ACTIVE', '2025-03-20'),

(4, '1000000004', 3, 3, 32000.00, 'ACTIVE', '2025-04-05'),

(5, '1000000005', 1, 2, 12500.00, 'ACTIVE', '2025-05-18'),

(6, '1000000006', 1, 3, 45000.00, 'ACTIVE', '2025-06-12'),

(7, '1000000007', 2, 1, 91000.00, 'ACTIVE', '2025-07-25'),

(8, '1000000008', 3, 3, 27500.00, 'ACTIVE', '2025-08-30');


-- =========================================
-- 5. ACCOUNT HOLDERS
-- =========================================

INSERT INTO account_holder
(account_id, customer_id, holder_type)
VALUES
(1, 1, 'PRIMARY'),
(2, 2, 'PRIMARY'),
(3, 3, 'PRIMARY'),
(4, 4, 'PRIMARY'),
(5, 5, 'PRIMARY'),
(6, 6, 'PRIMARY'),
(7, 7, 'PRIMARY'),
(8, 8, 'PRIMARY'),

-- Joint account example
(1, 2, 'JOINT');


-- =========================================
-- 6. TRANSACTIONS
-- =========================================

INSERT INTO transaction_record
(transaction_id, account_id, transaction_type, amount,
 transaction_date, description, balance_after)
VALUES

(1, 1, 'DEPOSIT', 10000.00,
 '2026-09-01 10:00:00', 'Initial deposit', 10000.00),

(2, 1, 'DEPOSIT', 20000.00,
 '2026-09-05 11:30:00', 'Cash deposit', 30000.00),

(3, 1, 'WITHDRAWAL', 5500.00,
 '2026-09-10 14:00:00', 'ATM withdrawal', 24500.00),

(4, 2, 'DEPOSIT', 25000.00,
 '2026-09-02 09:30:00', 'Salary credit', 25000.00),

(5, 2, 'WITHDRAWAL', 6800.00,
 '2026-09-08 16:00:00', 'ATM withdrawal', 18200.00),

(6, 3, 'DEPOSIT', 100000.00,
 '2026-09-03 10:15:00', 'Business deposit', 100000.00),

(7, 3, 'WITHDRAWAL', 25000.00,
 '2026-09-12 13:20:00', 'Business expense', 75000.00),

(8, 4, 'DEPOSIT', 32000.00,
 '2026-09-04 09:00:00', 'Salary credit', 32000.00),

(9, 5, 'DEPOSIT', 15000.00,
 '2026-09-06 12:00:00', 'Cash deposit', 15000.00),

(10, 5, 'WITHDRAWAL', 2500.00,
 '2026-09-15 15:30:00', 'ATM withdrawal', 12500.00);


-- =========================================
-- 7. TRANSFERS
-- =========================================

INSERT INTO transfer
(transfer_id, from_account_id, to_account_id, amount,
 transfer_date, status, description)
VALUES

(1, 1, 2, 2000.00,
 '2026-09-18 10:30:00', 'SUCCESS', 'Personal transfer'),

(2, 3, 5, 5000.00,
 '2026-09-20 12:15:00', 'SUCCESS', 'Payment transfer'),

(3, 4, 6, 3000.00,
 '2026-09-22 09:45:00', 'SUCCESS', 'Fund transfer');


-- =========================================
-- 8. BENEFICIARIES
-- =========================================

INSERT INTO beneficiary
(beneficiary_id, customer_id, beneficiary_name,
 account_number, bank_name, ifsc_code, status)
VALUES

(1, 1, 'Ananya Reddy',
 '1000000002', 'ABC Bank', 'ABC0001001', 'ACTIVE'),

(2, 2, 'Arjun Kumar',
 '1000000003', 'ABC Bank', 'ABC0001002', 'ACTIVE'),

(3, 3, 'Sneha Patel',
 '1000000004', 'ABC Bank', 'ABC0001003', 'ACTIVE'),

(4, 4, 'Priya Nair',
 '1000000006', 'ABC Bank', 'ABC0001004', 'ACTIVE');


-- =========================================
-- 9. SERVICE CHARGES
-- =========================================

INSERT INTO charge
(charge_id, account_id, charge_type, amount,
 charge_date, description)
VALUES

(1, 1, 'ATM Charge', 50.00,
 '2026-09-10 14:05:00', 'ATM service charge'),

(2, 3, 'Transfer Charge', 25.00,
 '2026-09-20 12:20:00', 'Transfer processing charge'),

(3, 5, 'Service Charge', 100.00,
 '2026-09-25 10:00:00', 'Monthly service charge');


-- =========================================
-- 10. LOANS
-- =========================================

INSERT INTO loan
(loan_id, customer_id, loan_type, principal_amount,
 interest_rate, start_date, end_date, status)
VALUES

(1, 1, 'Personal Loan', 200000.00,
 8.50, '2026-01-01', '2028-01-01', 'ACTIVE'),

(2, 3, 'Education Loan', 500000.00,
 7.50, '2026-02-01', '2030-02-01', 'ACTIVE'),

(3, 5, 'Vehicle Loan', 750000.00,
 9.00, '2026-03-01', '2031-03-01', 'ACTIVE');


-- =========================================
-- 11. LOAN SCHEDULE
-- =========================================

INSERT INTO loan_schedule
(schedule_id, loan_id, due_date, installment_amount,
 principal_component, interest_component, status)
VALUES

(1, 1, '2026-10-01', 10000.00,
 8500.00, 1500.00, 'PAID'),

(2, 1, '2026-11-01', 10000.00,
 8600.00, 1400.00, 'PENDING'),

(3, 2, '2026-10-05', 15000.00,
 12000.00, 3000.00, 'PAID'),

(4, 2, '2026-11-05', 15000.00,
 12200.00, 2800.00, 'PENDING'),

(5, 3, '2026-10-10', 18000.00,
 15000.00, 3000.00, 'PENDING');


-- =========================================
-- 12. REPAYMENTS
-- =========================================

INSERT INTO repayment
(repayment_id, loan_id, schedule_id, amount_paid,
 payment_date, payment_method)
VALUES

(1, 1, 1, 10000.00,
 '2026-09-28 11:00:00', 'BANK_TRANSFER'),

(2, 2, 3, 15000.00,
 '2026-09-29 12:30:00', 'BANK_TRANSFER');


-- =========================================
-- 13. STATEMENT REQUESTS
-- =========================================

INSERT INTO statement_record
(statement_id, account_id, from_date, to_date)
VALUES

(1, 1, '2026-09-01', '2026-09-30'),

(2, 2, '2026-09-01', '2026-09-30'),

(3, 3, '2026-09-01', '2026-09-30');