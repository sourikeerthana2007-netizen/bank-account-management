USE bank_management;

-- 1. Display all customers
SELECT * FROM customer;


-- 2. Display all accounts with customer names
SELECT
    a.account_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    at.type_name AS account_type,
    a.balance,
    a.status
FROM account a
JOIN account_holder ah
    ON a.account_id = ah.account_id
JOIN customer c
    ON ah.customer_id = c.customer_id
JOIN account_type at
    ON a.account_type_id = at.account_type_id
WHERE ah.holder_type = 'PRIMARY';


-- 3. Account statement / transaction history
SELECT
    a.account_number,
    t.transaction_type,
    t.amount,
    t.transaction_date,
    t.description,
    t.balance_after
FROM transaction_record t
JOIN account a
    ON t.account_id = a.account_id
WHERE a.account_number = '1000000001'
ORDER BY t.transaction_date;


-- 4. Transfer report
SELECT
    t.transfer_id,
    fa.account_number AS from_account,
    ta.account_number AS to_account,
    t.amount,
    t.transfer_date,
    t.status
FROM transfer t
JOIN account fa
    ON t.from_account_id = fa.account_id
JOIN account ta
    ON t.to_account_id = ta.account_id
ORDER BY t.transfer_date;


-- 5. Customer loan report
SELECT
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    l.loan_type,
    l.principal_amount,
    l.interest_rate,
    l.status
FROM loan l
JOIN customer c
    ON l.customer_id = c.customer_id;


-- 6. Pending loan installments
SELECT
    l.loan_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ls.due_date,
    ls.installment_amount,
    ls.status
FROM loan_schedule ls
JOIN loan l
    ON ls.loan_id = l.loan_id
JOIN customer c
    ON l.customer_id = c.customer_id
WHERE ls.status = 'PENDING'
ORDER BY ls.due_date;


-- 7. Branch-wise account summary
SELECT
    b.branch_name,
    COUNT(a.account_id) AS total_accounts,
    SUM(a.balance) AS total_balance
FROM branch b
LEFT JOIN account a
    ON b.branch_id = a.branch_id
GROUP BY b.branch_id, b.branch_name;


-- 8. Total deposits and withdrawals
SELECT
    transaction_type,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM transaction_record
GROUP BY transaction_type;