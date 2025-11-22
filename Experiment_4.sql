-- =======================================================================
-- MySQL Banking Database with ACID Transactions
-- Reference: Fundamentals of Database Systems by Ramez Elmasri & Shamkant Navathe
-- =======================================================================
-- Step 0: Create and use the database
CREATE DATABASE bank_db;
USE bank_db;

-- Step 1: Create Accounts and Transactions tables
-- Accounts table stores account details
CREATE TABLE Accounts (
    acc_no INT PRIMARY KEY,
    cust_name VARCHAR(50) NOT NULL,
    balance DECIMAL(10, 2) NOT NULL CHECK (balance >= 0)
) ENGINE=InnoDB;

-- Transactions table stores transaction history
CREATE TABLE Transactions (
    trans_id INT AUTO_INCREMENT PRIMARY KEY,
    acc_no INT,
    trans_type ENUM('deposit', 'withdrawal') NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    trans_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (acc_no) REFERENCES Accounts(acc_no)
) ENGINE=InnoDB;

-- Step 2: Insert sample records
INSERT INTO Accounts (acc_no, cust_name, balance) VALUES
(101, 'Alice', 2000.00),
(102, 'Bob', 1500.00),
(103, 'Charlie', 3000.00);

INSERT INTO Transactions (acc_no, trans_type, amount) VALUES
(101, 'deposit', 500.00),
(101, 'withdrawal', 200.00),
(102, 'deposit', 300.00),
(103, 'withdrawal', 100.00),
(101, 'deposit', 100.00);

-- Verification: Check initial state
SELECT * FROM Accounts;
SELECT * FROM Transactions;

-- Step 3: Simulate a transaction: withdraw ₹500 from account 101
-- This must be atomic and maintain consistency
START TRANSACTION;
UPDATE Accounts SET balance = balance - 500 WHERE acc_no = 101; 	-- 2000 - 500 = 1500
INSERT INTO Transactions (acc_no, trans_type, amount) VALUES (101, 'withdrawal', 500.00);
COMMIT;

-- Verification: Check balance after withdrawal
SELECT acc_no, cust_name, balance FROM Accounts WHERE acc_no = 101;
SELECT * FROM Transactions WHERE acc_no = 101 ORDER BY trans_date DESC;

-- Step 4: Show a schedule of two transactions accessing the same account
-- Example: Two concurrent withdrawals from account 101
-- Session 1 (T1)
START TRANSACTION;
UPDATE Accounts SET balance = balance - 200 WHERE acc_no = 101; -- 1500-200 = 1300
INSERT INTO Transactions (acc_no, trans_type, amount) VALUES (101, 'withdrawal', 200.00);
COMMIT;

-- Session 2 (T2)
START TRANSACTION;
UPDATE Accounts SET balance = balance - 300 WHERE acc_no = 101;  -- 1300 - 300 = 1000
INSERT INTO Transactions (acc_no, trans_type, amount) VALUES (101, 'withdrawal', 300.00);
COMMIT;

-- Verification: Check final balance after both transactions
SELECT acc_no, cust_name, balance FROM Accounts WHERE acc_no = 101;
SELECT * FROM Transactions WHERE acc_no = 101 ORDER BY trans_date DESC;

-- Step 5: Serial and Non-Serial Schedules
-- Serial Schedule: Transactions execute one after another (no overlap)
-- Example: T1 completes fully, then T2 starts.
-- Non-Serial Schedule: Transactions overlap (concurrent execution)
-- Example: T1 and T2 interleave operations.

-- Conflict Serializability: A non-serial schedule is conflict serializable if it can be transformed into a serial schedule by swapping non-conflicting operations.
-- Example: If T1 and T2 both update account 101, the order matters. If T1 writes before T2, the result is different than if T2 writes first.

-- Step 6: Cascading Rollback and Recoverable Schedules
-- Cascading rollback occurs when a transaction fails and forces other transactions that read its uncommitted data to roll back.
-- Example: T1 writes to account 101, T2 reads the uncommitted value, T1 fails and rolls back. T2 must also roll back to maintain consistency.
-- Recoverable schedules avoid cascading rollback by ensuring that a transaction only reads committed data.

-- Step 7: COMMIT and ROLLBACK examples
-- COMMIT makes changes permanent
START TRANSACTION;
UPDATE Accounts SET balance = balance - 100 WHERE acc_no = 101; -- 1000-100 = 900
INSERT INTO Transactions (acc_no, trans_type, amount) VALUES (101, 'withdrawal', 100.00);
COMMIT;

-- Verification: Check balance after COMMIT
SELECT acc_no, cust_name, balance FROM Accounts WHERE acc_no = 101;
SELECT * FROM Transactions WHERE acc_no = 101 ORDER BY trans_date DESC;

-- ROLLBACK undoes changes if an error occurs
START TRANSACTION;
UPDATE Accounts SET balance = balance - 100 WHERE acc_no = 101; -- 900 -100=800
INSERT INTO Transactions (acc_no, trans_type, amount) VALUES (101, 'withdrawal', 100.00);
-- Simulate an error
ROLLBACK;

-- Verification: Check balance after ROLLBACK (should be unchanged)
SELECT acc_no, cust_name, balance FROM Accounts WHERE acc_no = 101;
SELECT * FROM Transactions WHERE acc_no = 101 ORDER BY trans_date DESC;

-- Step 8: Dirty Read Example
-- If isolation is not enforced, a transaction can read uncommitted data from another transaction.
-- Example: T1 updates account 101, T2 reads the uncommitted value, T1 rolls back. T2 has read a "dirty" value.

-- Session 1: T1 (uncommitted update)
START TRANSACTION;
UPDATE Accounts SET balance = balance + 1000 WHERE acc_no = 101; 

-- Session 2: T2 (dirty read)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT balance FROM Accounts WHERE acc_no = 101;
COMMIT;

-- Session 1: T1 (rollback)
ROLLBACK;

-- Verification: Check balance after rollback (should be unchanged)
SELECT acc_no, cust_name, balance FROM Accounts WHERE acc_no = 101;

-- Step 9: SET TRANSACTION Isolation Levels
-- Set isolation level to READ UNCOMMITTED (allows dirty reads)
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT balance FROM Accounts WHERE acc_no = 101;
COMMIT;

-- Set isolation level to READ COMMITTED (prevents dirty reads)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT balance FROM Accounts WHERE acc_no = 101;
COMMIT;

-- Step 10: Prevent Concurrent Updates on the Same Account
-- Use SELECT ... FOR UPDATE to lock the row during the transaction
START TRANSACTION;
SELECT balance FROM Accounts WHERE acc_no = 101 FOR UPDATE;
UPDATE Accounts SET balance = balance - 500 WHERE acc_no = 101;
INSERT INTO Transactions (acc_no, trans_type, amount) VALUES (101, 'withdrawal', 500.00);
COMMIT;

-- Verification: Check balance after concurrent update prevention
SELECT acc_no, cust_name, balance FROM Accounts WHERE acc_no = 101;
SELECT * FROM Transactions WHERE acc_no = 101 ORDER BY trans_date DESC;
