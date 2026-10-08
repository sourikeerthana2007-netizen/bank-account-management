CREATE DATABASE IF NOT EXISTS bank_management;

USE bank_management;

DROP TABLE IF EXISTS statement_record;
DROP TABLE IF EXISTS repayment;
DROP TABLE IF EXISTS loan_schedule;
DROP TABLE IF EXISTS loan;
DROP TABLE IF EXISTS charge;
DROP TABLE IF EXISTS beneficiary;
DROP TABLE IF EXISTS transfer;
DROP TABLE IF EXISTS transaction_record;
DROP TABLE IF EXISTS account_holder;
DROP TABLE IF EXISTS account;
DROP TABLE IF EXISTS account_type;
DROP TABLE IF EXISTS branch;
DROP TABLE IF EXISTS customer;

CREATE TABLE customer (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15) NOT NULL UNIQUE,
    email VARCHAR(100) UNIQUE,
    address VARCHAR(255),
    date_of_birth DATE
);


CREATE TABLE branch (
    branch_id INT AUTO_INCREMENT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    branch_code VARCHAR(20) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,
    phone VARCHAR(15)
);


CREATE TABLE account_type (
    account_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255),
    minimum_balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    
    CHECK (minimum_balance >= 0)
);


CREATE TABLE account (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type_id INT NOT NULL,
    branch_id INT NOT NULL,
    balance DECIMAL(12,2) NOT NULL DEFAULT 0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    opening_date DATE NOT NULL,

    CONSTRAINT fk_account_type
        FOREIGN KEY (account_type_id)
        REFERENCES account_type(account_type_id),

    CONSTRAINT fk_account_branch
        FOREIGN KEY (branch_id)
        REFERENCES branch(branch_id),

    CHECK (balance >= 0),
    CHECK (status IN ('ACTIVE', 'INACTIVE', 'CLOSED'))
);


CREATE TABLE account_holder (
    account_id INT NOT NULL,
    customer_id INT NOT NULL,
    holder_type VARCHAR(20) NOT NULL DEFAULT 'PRIMARY',

    PRIMARY KEY (account_id, customer_id),

    CONSTRAINT fk_holder_account
        FOREIGN KEY (account_id)
        REFERENCES account(account_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_holder_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
        ON DELETE CASCADE,

    CHECK (holder_type IN ('PRIMARY', 'JOINT'))
);


CREATE TABLE transaction_record (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),
    balance_after DECIMAL(12,2) NOT NULL,

    CONSTRAINT fk_transaction_account
        FOREIGN KEY (account_id)
        REFERENCES account(account_id),

    CHECK (amount > 0),
    CHECK (balance_after >= 0),
    CHECK (transaction_type IN ('DEPOSIT', 'WITHDRAWAL'))
);


CREATE TABLE transfer (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account_id INT NOT NULL,
    to_account_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    transfer_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'SUCCESS',
    description VARCHAR(255),

    CONSTRAINT fk_transfer_from
        FOREIGN KEY (from_account_id)
        REFERENCES account(account_id),

    CONSTRAINT fk_transfer_to
        FOREIGN KEY (to_account_id)
        REFERENCES account(account_id),

    CHECK (amount > 0),
    CHECK (from_account_id <> to_account_id),
    CHECK (status IN ('SUCCESS', 'FAILED', 'PENDING'))
);


CREATE TABLE beneficiary (
    beneficiary_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    beneficiary_name VARCHAR(100) NOT NULL,
    account_number VARCHAR(20) NOT NULL,
    bank_name VARCHAR(100) NOT NULL,
    ifsc_code VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT fk_beneficiary_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id)
        ON DELETE CASCADE,

    CHECK (status IN ('ACTIVE', 'INACTIVE'))
);


CREATE TABLE charge (
    charge_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    charge_type VARCHAR(50) NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    charge_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    description VARCHAR(255),

    CONSTRAINT fk_charge_account
        FOREIGN KEY (account_id)
        REFERENCES account(account_id),

    CHECK (amount > 0)
);


CREATE TABLE loan (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    loan_type VARCHAR(50) NOT NULL,
    principal_amount DECIMAL(12,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',

    CONSTRAINT fk_loan_customer
        FOREIGN KEY (customer_id)
        REFERENCES customer(customer_id),

    CHECK (principal_amount > 0),
    CHECK (interest_rate >= 0),
    CHECK (status IN ('ACTIVE', 'CLOSED', 'DEFAULTED'))
);


CREATE TABLE loan_schedule (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    due_date DATE NOT NULL,
    installment_amount DECIMAL(12,2) NOT NULL,
    principal_component DECIMAL(12,2) NOT NULL,
    interest_component DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

    CONSTRAINT fk_schedule_loan
        FOREIGN KEY (loan_id)
        REFERENCES loan(loan_id)
        ON DELETE CASCADE,

    CHECK (installment_amount > 0),
    CHECK (principal_component >= 0),
    CHECK (interest_component >= 0),
    CHECK (status IN ('PENDING', 'PAID', 'OVERDUE'))
);


CREATE TABLE repayment (
    repayment_id INT AUTO_INCREMENT PRIMARY KEY,
    loan_id INT NOT NULL,
    schedule_id INT NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30) NOT NULL,

    CONSTRAINT fk_repayment_loan
        FOREIGN KEY (loan_id)
        REFERENCES loan(loan_id),

    CONSTRAINT fk_repayment_schedule
        FOREIGN KEY (schedule_id)
        REFERENCES loan_schedule(schedule_id),

    CHECK (amount_paid > 0)
);


CREATE TABLE statement_record (
    statement_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    generated_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_statement_account
        FOREIGN KEY (account_id)
        REFERENCES account(account_id),

    CHECK (to_date >= from_date)
);

