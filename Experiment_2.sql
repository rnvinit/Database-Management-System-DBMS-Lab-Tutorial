-- 1. Create the main database
CREATE DATABASE E_COMMERCE_DB;
-- Select the database to work within it
USE E_COMMERCE_DB;
-- Create the Customer table
CREATE TABLE Customer (
    cid INT PRIMARY KEY,
    cname VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    phone CHAR(10) UNIQUE
);
-- Create the Agent table
CREATE TABLE Agent (
    aid INT PRIMARY KEY,
    aname VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    phone CHAR(10) UNIQUE
);
-- Create the Product table
CREATE TABLE Product (
    pid INT PRIMARY KEY,
    pname VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    stock INT
);
-- Create the Orders table
CREATE TABLE Orders (
    oid INT PRIMARY KEY,
    cid INT,
    aid INT,
    odate DATE,
    mode VARCHAR(20),
    status VARCHAR(20),
    FOREIGN KEY (cid) REFERENCES Customer(cid), -- Foreign Key to Customer
    FOREIGN KEY (aid) REFERENCES Agent(aid)     -- Foreign Key to Agent
);

-- Create the Order_Details table (Linking table for Orders and Products)
CREATE TABLE Order_Details (
    oid INT,
    pid INT,
    qty INT NOT NULL,
    PRIMARY KEY (oid, pid), -- Composite Primary Key
    FOREIGN KEY (oid) REFERENCES Orders(oid),   -- Foreign Key to Orders
    FOREIGN KEY (pid) REFERENCES Product(pid)   -- Foreign Key to Product
);

-- ========================================================================================

-- 1. Add a column email with domain VARCHAR(50) to the Customer table.
ALTER TABLE Customer
ADD COLUMN email VARCHAR(50);
-- Check the table structure after adding the column
DESCRIBE Customer;

-- ===========================================================================================
-- 2. Insert some sample records into each table.
-- Inserting into Customer
INSERT INTO Customer (cid, cname, city, phone, email) VALUES
(1, 'Amit Sharma', 'Bangalore', '9876543210', 'amit.s@mail.com'),
(2, 'Priya Singh', 'Mumbai', '9876543211', 'priya.s@mail.com'),
(3, 'Ravi Kumar', 'Delhi', '9876543212', 'ravi.k@mail.com'),
(4, 'Deepa Varma', 'Bangalore', '9876543213', 'deepa.v@mail.com'),
(5, 'Suresh Reddy', 'Hyderabad', '9876543214', 'suresh.r@mail.com'),
(6, 'Missing Customer', 'Chennai', '9876543215', 'missing.c@mail.com');

-- Inserting into Agent
INSERT INTO Agent (aid, aname, city, phone) VALUES
(101, 'Vikas Jain', 'Bangalore', '8765432100'),
(102, 'Sneha Patel', 'Mumbai', '8765432101'),
(103, 'Alok Sinha', 'Delhi', '8765432102'),
(104, 'No Orders Agent', 'Kolkata', '8765432103');

-- Inserting into Product
INSERT INTO Product (pid, pname, price, stock) VALUES
(1001, 'Basmati Rice 5kg', 650.00, 50),
(1002, 'Atta 10kg', 400.00, 0), -- Out of stock
(1003, 'Cooking Oil 1L', 150.50, 200),
(1004, 'Sugar 1kg', 45.00, 100),
(1005, 'Coffee Powder 200g', 320.00, 0); -- Out of stock
set foreign_key_checks = 0;
-- Inserting into Orders
INSERT INTO Orders (oid, cid, aid, odate, mode, status) VALUES
(1, 1, 101, '2025-08-01', 'Online', 'Delivered'),
(2, 4, 101, '2025-08-01', 'COD', 'Delivered'),
(3, 2, 102, '2025-08-02', 'Online', 'Delivered'),
(4, 3, 103, '2025-08-03', 'COD', 'Delivered'),
(5, 1, 101, '2025-08-03', 'Online', 'Delivered'),
(6, 4, 102, '2025-08-04', 'COD', 'Pending'); -- Pending Order
set foreign_key_checks = 1;
-- Inserting into Order_Details (cid=1 ordered 3 different products in oid=1)
INSERT INTO Order_Details (oid, pid, qty) VALUES
(1, 1001, 1),
(1, 1003, 2),
(1, 1004, 5),
(2, 1001, 2),
(3, 1003, 1),
(3, 1004, 2),
(4, 1001, 1),
(5, 1003, 3),
(5, 1004, 1),
(5, 1005, 1),
(6, 1001, 1);

-- ==============================================================================================

-- 3. Update the phone number of the customer with cid = 3.
UPDATE Customer
SET phone = '9900112233'
WHERE cid = 3;

-- Verification
SELECT * FROM Customer WHERE cid = 3;

-- =================================================================================================

-- 4. Rename the column phone to mobile in the Agent table.

ALTER TABLE Agent
CHANGE COLUMN phone mobile CHAR(10);

-- Check the table structure after renaming
DESCRIBE Agent;

-- ===================================================================================================

-- 5. Delete the customer whose cid is 5.

-- Note: cid=5 has no associated orders, so a direct delete is possible.
DELETE FROM Customer
WHERE cid = 5;

-- Verification
SELECT * FROM Customer WHERE cid = 5;

-- ==========================================================================================================

-- 6. Retrieve the names of customers who ordered more than
-- 3 different products.

SELECT C.cname
FROM Customer C
JOIN Orders O ON C.cid = O.cid
JOIN Order_Details OD ON O.oid = OD.oid
GROUP BY C.cid, C.cname -- Group by customer to count their products
HAVING COUNT(DISTINCT OD.pid) > 3; -- Filter groups where the count of distinct products is > 3

-- =========================================================================================================

-- 7. List the names of agents who have delivered orders to customers 
-- in “Bangalore”.

SELECT DISTINCT A.aname
FROM Agent A
JOIN Orders O ON A.aid = O.aid
JOIN Customer C ON O.cid = C.cid
WHERE C.city = 'Bangalore' AND O.status = 'Delivered';
-- The DISTINCT keyword is crucial to avoid repeating agent names.

-- ============================================================================================================

-- 8. Display the total amount spent by each customer.
SELECT
    C.cname,
    SUM(P.price * OD.qty) AS total_spent
FROM Customer C
JOIN Orders O ON C.cid = O.cid
JOIN Order_Details OD ON O.oid = OD.oid
JOIN Product P ON OD.pid = P.pid
GROUP BY C.cid, C.cname
ORDER BY total_spent DESC;

-- ================================================================================================================

-- 9. Retrieve the names of products that are out of stock.
SELECT pname
FROM Product
WHERE stock = 0;

-- ================================================================================================================
-- 10. List the agents who haven’t delivered any orders.

SELECT aname
FROM Agent A
WHERE NOT EXISTS ( -- Select agents for whom NO delivered orders can be found
    SELECT 1
    FROM Orders O
    WHERE O.aid = A.aid AND O.status = 'Delivered'
);
-- This correctly identifies Agent 104 ('No Orders Agent') as they have no orders at all.

-- =====================================================================================================================

-- 11. Retrieve order IDs and product names for orders placed on '2025-08-01'.

SELECT
    O.oid,
    P.pname
FROM Orders O
JOIN Order_Details OD ON O.oid = OD.oid
JOIN Product P ON OD.pid = P.pid
WHERE O.odate = '2025-08-01';

-- ========================================================================================================================

-- 12. Display the number of orders delivered by each agent.

SELECT
    A.aname,
    COUNT(O.oid) AS total_delivered_orders
FROM Agent A
LEFT JOIN Orders O ON A.aid = O.aid AND O.status = 'Delivered'
GROUP BY A.aid, A.aname
ORDER BY total_delivered_orders DESC;
-- LEFT JOIN ensures agents with zero delivered orders are still listed with a count of 0.


-- =========================================================================================================

-- 13. Retrieve the highest priced product in each order.

SELECT
    OD.oid,
    P.pname,
    P.price
FROM Order_Details OD
JOIN Product P ON OD.pid = P.pid
WHERE P.price = ( -- Subquery finds the MAX price for products within the current order (OD.oid)
    SELECT MAX(price)
    FROM Order_Details OD2
    JOIN Product P2 ON OD2.pid = P2.pid
    WHERE OD2.oid = OD.oid
);

-- =====================================================================================================================
-- 14. Find customers who haven’t placed any orders.

SELECT cname
FROM Customer C
WHERE NOT EXISTS ( -- Select customers for whom NO orders can be found
    SELECT 1
    FROM Orders O
    WHERE O.cid = C.cid
);
-- This correctly identifies 'Missing Customer' (cid=6)

-- =================================================================================================================

-- 15. List the most frequently ordered product.

SELECT P.pname
FROM Product P
JOIN Order_Details OD ON P.pid = OD.pid
GROUP BY P.pid, P.pname
ORDER BY SUM(OD.qty) DESC -- Sum the total quantity ordered
LIMIT 1; -- Select only the top result (the most frequent)

