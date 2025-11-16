-- ==================================================================
-- DBMS EXPERIMENT: AUDITING WITH TRIGGERS
-- three separate triggers to track INSERT, UPDATE, and DELETE events.
-- ==================================================================
-- Create the main database
CREATE DATABASE Customer_Audit_DB;

-- Select the database to work inside it
USE Customer_Audit_DB;

-- ==================================================================
-- Phase 1: Create Tables (DDL)
-- ==================================================================

-- 1. Create the CUSTOMERS table (The main data table)
CREATE TABLE CUSTOMERS (
    ID INT PRIMARY KEY,              -- Primary key
    NAME VARCHAR(100) NOT NULL,
    AGE INT,
    ADDRESS VARCHAR(255),
    SALARY DECIMAL(10, 2)            -- Sensitive field we are monitoring
);

-- NEW: Create the dedicated Audit Log table (The Logbook)
-- Triggers will write entries directly into this table instead of displaying output.
CREATE TABLE CUSTOMER_AUDIT_LOG (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    change_type VARCHAR(10),            -- 'INSERT', 'UPDATE', or 'DELETE'
    old_salary DECIMAL(10, 2),
    new_salary DECIMAL(10, 2),
    log_message VARCHAR(255),
    change_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- 

-- ==================================================================
-- Phase 2: Create Separate Audit Triggers (DDL)
-- ==================================================================

-- Change the delimiter to $$ to allow semicolons inside the trigger body
DELIMITER $$

-- 2b. Trigger for INSERT: Logs new customer details. (Only NEW record exists)
CREATE TRIGGER customer_insert_audit
AFTER INSERT ON CUSTOMERS
FOR EACH ROW
BEGIN
    -- Log the new customer details and salary into the audit table
    INSERT INTO CUSTOMER_AUDIT_LOG (customer_id, change_type, new_salary, log_message)
    VALUES (
        NEW.ID,
        'INSERT',
        NEW.SALARY,
        CONCAT('NEW CUSTOMER INSERTED: ', NEW.NAME)
    );
END $$

-- 2a. Trigger for UPDATE: Logs salary changes. (Both OLD and NEW records exist)
CREATE TRIGGER customer_update_audit
AFTER UPDATE ON CUSTOMERS
FOR EACH ROW
BEGIN
    -- Check specifically if the SALARY column has changed
    IF OLD.SALARY <> NEW.SALARY THEN
        -- Log the old and new salaries, and the difference message
        INSERT INTO CUSTOMER_AUDIT_LOG (customer_id, change_type, old_salary, new_salary, log_message)
        VALUES (
            NEW.ID,
            'UPDATE',
            OLD.SALARY,
            NEW.SALARY,
            CONCAT(
                'SALARY UPDATED. Difference: ', (NEW.SALARY - OLD.SALARY)
            )
        );
    END IF;
END $$

-- 2c. Trigger for DELETE: Logs the deleted customer's details. (Only OLD record exists)
CREATE TRIGGER customer_delete_audit
AFTER DELETE ON CUSTOMERS
FOR EACH ROW
BEGIN
    -- Log the details of the customer before removal
    INSERT INTO CUSTOMER_AUDIT_LOG (customer_id, change_type, old_salary, log_message)
    VALUES (
        OLD.ID,
        'DELETE',
        OLD.SALARY,
        CONCAT('CUSTOMER DELETED: ', OLD.NAME)
    );
END $$

-- Change the delimiter back to the default semicolon
DELIMITER ;

-- ==================================================================
-- Phase 3: DML Operations (Testing the Triggers)
-- ==================================================================

-- 3. Insert five sample records (Tests the INSERT trigger)
INSERT INTO CUSTOMERS (ID, NAME, AGE, ADDRESS, SALARY) VALUES
(1, 'Aarav Sharma', 32, 'Delhi', 50000.00),
(2, 'Priya Singh', 25, 'Mumbai', 75000.00),
(3, 'Vikram Rao', 45, 'Bangalore', 90000.00),
(4, 'Sneha Varma', 28, 'Chennai', 65000.00),
(5, 'Rahul Menon', 38, 'Hyderabad', 80000.00);

-- 4. Update the SALARY of the customer whose ID = 2 (Tests the UPDATE trigger)
UPDATE CUSTOMERS
SET SALARY = 85000.00
WHERE ID = 2;

-- 5. Delete the record of the customer whose ID = 4 (Tests the DELETE trigger)
DELETE FROM CUSTOMERS
WHERE ID = 4;

-- Verification Query: Show the audit trail to confirm triggers worked
SELECT log_id, change_type, customer_id, old_salary, new_salary, log_message, change_timestamp
FROM CUSTOMER_AUDIT_LOG
ORDER BY log_id;

-- Final state of the CUSTOMERS table
SELECT * FROM CUSTOMERS;