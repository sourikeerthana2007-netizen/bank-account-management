from database import get_connection


def view_customers():
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("""
        SELECT customer_id, first_name, last_name, phone, email, address
        FROM customer
        ORDER BY customer_id
    """)

    customers = cursor.fetchall()

    print("\n===== CUSTOMER LIST =====")

    for customer in customers:
        print(
            f"ID: {customer[0]} | "
            f"Name: {customer[1]} {customer[2]} | "
            f"Phone: {customer[3]} | "
            f"Email: {customer[4]} | "
            f"Address: {customer[5]}"
        )

    cursor.close()
    connection.close()


def add_customer():
    print("\n===== ADD CUSTOMER =====")

    first_name = input("First name: ").strip()
    last_name = input("Last name: ").strip()
    phone = input("Phone: ").strip()
    email = input("Email: ").strip()
    address = input("Address: ").strip()
    date_of_birth = input("Date of birth (YYYY-MM-DD): ").strip()

    # Basic validation
    if not first_name or not last_name:
        print("Error: First name and last name are required.")
        return

    if not phone.isdigit() or len(phone) != 10:
        print("Error: Phone number must contain exactly 10 digits.")
        return

    if email and "@" not in email:
        print("Error: Please enter a valid email address.")
        return

    connection = get_connection()
    cursor = connection.cursor()

    query = """
        INSERT INTO customer
        (first_name, last_name, phone, email, address, date_of_birth)
        VALUES (%s, %s, %s, %s, %s, %s)
    """

    values = (
        first_name,
        last_name,
        phone,
        email,
        address,
        date_of_birth
    )

    cursor.execute(query, values)
    connection.commit()

    print("\nCustomer added successfully!")

    cursor.close()
    connection.close()

def update_customer():
    print("\n===== UPDATE CUSTOMER =====")

    customer_id = input("Enter customer ID to update: ").strip()

    first_name = input("New first name: ").strip()
    last_name = input("New last name: ").strip()
    phone = input("New phone: ").strip()
    email = input("New email: ").strip()
    address = input("New address: ").strip()

    if not first_name or not last_name:
        print("Error: First name and last name are required.")
        return

    if not phone.isdigit() or len(phone) != 10:
        print("Error: Phone number must contain exactly 10 digits.")
        return

    if email and "@" not in email:
        print("Error: Please enter a valid email address.")
        return

    connection = get_connection()
    cursor = connection.cursor()

    query = """
        UPDATE customer
        SET first_name = %s,
            last_name = %s,
            phone = %s,
            email = %s,
            address = %s
        WHERE customer_id = %s
    """

    values = (
        first_name,
        last_name,
        phone,
        email,
        address,
        customer_id
    )

    cursor.execute(query, values)
    connection.commit()

    if cursor.rowcount == 0:
        print("Customer not found.")
    else:
        print("Customer updated successfully!")

    cursor.close()
    connection.close()

def view_accounts():
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("""
        SELECT
            a.account_id,
            a.account_number,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            at.type_name,
            b.branch_name,
            a.balance,
            a.status
        FROM account a
        JOIN account_holder ah
            ON a.account_id = ah.account_id
        JOIN customer c
            ON ah.customer_id = c.customer_id
        JOIN account_type at
            ON a.account_type_id = at.account_type_id
        JOIN branch b
            ON a.branch_id = b.branch_id
        WHERE ah.holder_type = 'PRIMARY'
        ORDER BY a.account_id
    """)

    accounts = cursor.fetchall()

    print("\n===== ACCOUNT LIST =====")

    for account in accounts:
        print(
            f"ID: {account[0]} | "
            f"Account: {account[1]} | "
            f"Customer: {account[2]} | "
            f"Type: {account[3]} | "
            f"Branch: {account[4]} | "
            f"Balance: ₹{account[5]:.2f} | "
            f"Status: {account[6]}"
        )

    cursor.close()
    connection.close()


def transaction():
    print("\n===== DEPOSIT / WITHDRAWAL =====")

    account_number = input("Account number: ").strip()
    transaction_type = input("Enter D for Deposit or W for Withdrawal: ").strip().upper()

    if transaction_type not in ("D", "W"):
        print("Error: Invalid transaction type.")
        return

    try:
        amount = float(input("Amount: "))
    except ValueError:
        print("Error: Amount must be a number.")
        return

    if amount <= 0:
        print("Error: Amount must be greater than zero.")
        return

    connection = get_connection()
    cursor = connection.cursor()

    # Find account
    cursor.execute(
        "SELECT account_id, balance FROM account WHERE account_number = %s",
        (account_number,)
    )

    account = cursor.fetchone()

    if account is None:
        print("Error: Account not found.")
        cursor.close()
        connection.close()
        return

    account_id = account[0]
    current_balance = float(account[1])

    if transaction_type == "D":
        new_balance = current_balance + amount
        db_transaction_type = "DEPOSIT"

    else:
        if amount > current_balance:
            print("Error: Insufficient balance.")
            cursor.close()
            connection.close()
            return

        new_balance = current_balance - amount
        db_transaction_type = "WITHDRAWAL"

    # Update account balance
    cursor.execute(
        """
        UPDATE account
        SET balance = %s
        WHERE account_id = %s
        """,
        (new_balance, account_id)
    )

    # Record transaction
    cursor.execute(
        """
        INSERT INTO transaction_record
        (account_id, transaction_type, amount, description, balance_after)
        VALUES (%s, %s, %s, %s, %s)
        """,
        (
            account_id,
            db_transaction_type,
            amount,
            "Deposit/Withdrawal through application",
            new_balance
        )
    )

    connection.commit()

    print(f"\n{db_transaction_type} successful!")
    print(f"New balance: ₹{new_balance:.2f}")

    cursor.close()
    connection.close()


def transfer():
    print("\n===== ACCOUNT TRANSFER =====")

    from_account = input("From account number: ").strip()
    to_account = input("To account number: ").strip()

    if from_account == to_account:
        print("Error: Source and destination accounts must be different.")
        return

    try:
        amount = float(input("Transfer amount: "))
    except ValueError:
        print("Error: Amount must be a number.")
        return

    if amount <= 0:
        print("Error: Transfer amount must be greater than zero.")
        return

    connection = get_connection()
    cursor = connection.cursor()

    # Get source account
    cursor.execute(
        "SELECT account_id, balance FROM account WHERE account_number = %s",
        (from_account,)
    )
    source = cursor.fetchone()

    if source is None:
        print("Error: Source account not found.")
        cursor.close()
        connection.close()
        return

    # Get destination account
    cursor.execute(
        "SELECT account_id FROM account WHERE account_number = %s",
        (to_account,)
    )
    destination = cursor.fetchone()

    if destination is None:
        print("Error: Destination account not found.")
        cursor.close()
        connection.close()
        return

    source_id = source[0]
    source_balance = float(source[1])
    destination_id = destination[0]

    if amount > source_balance:
        print("Error: Insufficient balance.")
        cursor.close()
        connection.close()
        return

    new_source_balance = source_balance - amount

    # Get destination balance
    cursor.execute(
        "SELECT balance FROM account WHERE account_id = %s",
        (destination_id,)
    )
    destination_balance = float(cursor.fetchone()[0])

    new_destination_balance = destination_balance + amount

    # Update source account
    cursor.execute(
        """
        UPDATE account
        SET balance = %s
        WHERE account_id = %s
        """,
        (new_source_balance, source_id)
    )

    # Update destination account
    cursor.execute(
        """
        UPDATE account
        SET balance = %s
        WHERE account_id = %s
        """,
        (new_destination_balance, destination_id)
    )

    # Record transfer
    cursor.execute(
        """
        INSERT INTO transfer
        (from_account_id, to_account_id, amount, status, description)
        VALUES (%s, %s, %s, %s, %s)
        """,
        (
            source_id,
            destination_id,
            amount,
            "SUCCESS",
            "Transfer through application"
        )
    )

    connection.commit()

    print("\nTransfer successful!")
    print(f"Transferred: ₹{amount:.2f}")
    print(f"Source balance: ₹{new_source_balance:.2f}")
    print(f"Destination balance: ₹{new_destination_balance:.2f}")

    cursor.close()
    connection.close()


def view_loans():
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute("""
        SELECT
            l.loan_id,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            l.loan_type,
            l.principal_amount,
            l.interest_rate,
            l.status
        FROM loan l
        JOIN customer c
            ON l.customer_id = c.customer_id
        ORDER BY l.loan_id
    """)

    loans = cursor.fetchall()

    print("\n===== LOAN LIST =====")

    for loan in loans:
        print(
            f"Loan ID: {loan[0]} | "
            f"Customer: {loan[1]} | "
            f"Type: {loan[2]} | "
            f"Principal: ₹{loan[3]:.2f} | "
            f"Interest: {loan[4]}% | "
            f"Status: {loan[5]}"
        )

    cursor.close()
    connection.close()


def view_reports():
    connection = get_connection()
    cursor = connection.cursor()

    print("\n===== REPORTS =====")
    print("1. Customer Account Report")
    print("2. Transaction Summary")
    print("3. Transfer Report")
    print("4. Loan Report")
    print("5. Branch Summary")

    choice = input("\nEnter report choice: ")

    if choice == "1":
        cursor.execute("""
            SELECT
                a.account_number,
                CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
                at.type_name,
                a.balance,
                a.status
            FROM account a
            JOIN account_holder ah
                ON a.account_id = ah.account_id
            JOIN customer c
                ON ah.customer_id = c.customer_id
            JOIN account_type at
                ON a.account_type_id = at.account_type_id
            WHERE ah.holder_type = 'PRIMARY'
            ORDER BY a.account_id
        """)

        rows = cursor.fetchall()

        print("\n===== CUSTOMER ACCOUNT REPORT =====")
        for row in rows:
            print(
                f"Account: {row[0]} | "
                f"Customer: {row[1]} | "
                f"Type: {row[2]} | "
                f"Balance: ₹{row[3]:.2f} | "
                f"Status: {row[4]}"
            )

    elif choice == "2":
        cursor.execute("""
            SELECT
                transaction_type,
                COUNT(*) AS transaction_count,
                SUM(amount) AS total_amount
            FROM transaction_record
            GROUP BY transaction_type
        """)

        rows = cursor.fetchall()

        print("\n===== TRANSACTION SUMMARY =====")
        for row in rows:
            print(
                f"Type: {row[0]} | "
                f"Count: {row[1]} | "
                f"Total: ₹{row[2]:.2f}"
            )

    elif choice == "3":
        cursor.execute("""
            SELECT
                t.transfer_id,
                fa.account_number,
                ta.account_number,
                t.amount,
                t.status
            FROM transfer t
            JOIN account fa
                ON t.from_account_id = fa.account_id
            JOIN account ta
                ON t.to_account_id = ta.account_id
            ORDER BY t.transfer_id
        """)

        rows = cursor.fetchall()

        print("\n===== TRANSFER REPORT =====")
        for row in rows:
            print(
                f"Transfer ID: {row[0]} | "
                f"From: {row[1]} | "
                f"To: {row[2]} | "
                f"Amount: ₹{row[3]:.2f} | "
                f"Status: {row[4]}"
            )

    elif choice == "4":
        cursor.execute("""
            SELECT
                l.loan_id,
                CONCAT(c.first_name, ' ', c.last_name),
                l.loan_type,
                l.principal_amount,
                l.interest_rate,
                l.status
            FROM loan l
            JOIN customer c
                ON l.customer_id = c.customer_id
            ORDER BY l.loan_id
        """)

        rows = cursor.fetchall()

        print("\n===== LOAN REPORT =====")
        for row in rows:
            print(
                f"Loan ID: {row[0]} | "
                f"Customer: {row[1]} | "
                f"Type: {row[2]} | "
                f"Principal: ₹{row[3]:.2f} | "
                f"Interest: {row[4]}% | "
                f"Status: {row[5]}"
            )

    elif choice == "5":
        cursor.execute("""
            SELECT
                b.branch_name,
                COUNT(a.account_id),
                COALESCE(SUM(a.balance), 0)
            FROM branch b
            LEFT JOIN account a
                ON b.branch_id = a.branch_id
            GROUP BY b.branch_id, b.branch_name
        """)

        rows = cursor.fetchall()

        print("\n===== BRANCH SUMMARY =====")
        for row in rows:
            print(
                f"Branch: {row[0]} | "
                f"Accounts: {row[1]} | "
                f"Total Balance: ₹{row[2]:.2f}"
            )

    else:
        print("Invalid report choice.")

    cursor.close()
    connection.close()


def main():
    while True:
        print("\n===== BANK MANAGEMENT SYSTEM =====")
        print("1. View Customers")
        print("2. Add Customer")
        print("3. Update Customer")
        print("4. View Accounts")
        print("5. Deposit / Withdrawal")
        print("6. Transfers")
        print("7. View Loans")
        print("8. Reports")
        print("9. Exit")

        choice = input("\nEnter your choice: ")

        if choice == "1":
            view_customers()

        elif choice == "2":
            add_customer()

        elif choice == "3":
            update_customer()

        elif choice == "4":
            view_accounts()

        elif choice == "5":
            transaction()

        elif choice == "6":
            transfer()

        elif choice == "7":
            view_loans()

        elif choice == "8":
            view_reports()

        elif choice == "9":
            print("\nThank you for using Bank Management System.")
            break

        else:
            print("\nInvalid choice. Please try again.")


if __name__ == "__main__":
    main()