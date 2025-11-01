-- Create Database
CREATE DATABASE CompanyDB_Exp1;

USE CompanyDB_Exp1;

-- ==================================================================
-- Create Tables as per Relational Schema (DDL - Data Definition Language)
-- ==================================================================

-- Department Table: Stores department information
CREATE TABLE Department (
    dnumber INT PRIMARY KEY,        -- PRIMARY KEY: Unique department identifier
    dname VARCHAR(30),              -- VARCHAR: Department name
    mgr_ssn CHAR(9)                 -- Manager's SSN (will be foreign key)
);

-- Dept_Loc Table: Stores multiple locations for each department
CREATE TABLE Dept_Loc (
    dnumber INT,                    -- FOREIGN KEY: Links to Department table
    dloc VARCHAR(30),               -- VARCHAR: Location name
    FOREIGN KEY (dnumber) REFERENCES Department(dnumber) -- FK: Ensures department exists
);

-- Employee Table: Stores employee details
CREATE TABLE Employee (
    ssn CHAR(9) PRIMARY KEY,        -- PK: Unique employee identifier
    name VARCHAR(50),               -- VARCHAR: Employee name
    salary DECIMAL(10,2),           -- DECIMAL: Precise number for salary
    sex CHAR(1),                    -- CHAR(1): Single character for gender
    super_ssn CHAR(9),              -- FK: Self-referencing to manager's SSN
    address VARCHAR(100),           -- VARCHAR: Employee address
    dno INT,                        -- FK: Department number employee belongs to
    FOREIGN KEY (dno) REFERENCES Department(dnumber),           -- FK: Valid department
    FOREIGN KEY (super_ssn) REFERENCES Employee(ssn)            -- Self-referencing FK
);

-- Project Table: Stores project information
CREATE TABLE Project (
    pnumber INT PRIMARY KEY,        -- PK: Unique project identifier
    pname VARCHAR(40),              -- VARCHAR: Project name
    plocation VARCHAR(50),          -- VARCHAR: Project location
    dnum INT,                       -- FK: Department controlling the project
    FOREIGN KEY (dnum) REFERENCES Department(dnumber)           -- FK: Valid department
);

-- Works_On Table: Linking table for Many-to-Many relationship between Employees and Projects
CREATE TABLE Works_On (
    essn CHAR(9),                   -- FK: Employee SSN
    pno INT,                        -- FK: Project number
    hours INT,                      -- INT: Hours worked on project
    FOREIGN KEY (essn) REFERENCES Employee(ssn),                -- FK: Valid employee
    FOREIGN KEY (pno) REFERENCES Project(pnumber)               -- FK: Valid project
);

-- Dependent Table: Stores dependent information for employees
CREATE TABLE Dependent (
    essn CHAR(9),                   -- FK: Employee SSN
    depen_name VARCHAR(30),         -- VARCHAR: Dependent's name
    address VARCHAR(100),           -- VARCHAR: Dependent's address
    relationship VARCHAR(20),       -- VARCHAR: Relationship to employee
    sex CHAR(1),                    -- CHAR(1): Dependent's gender
    FOREIGN KEY (essn) REFERENCES Employee(ssn)                 -- FK: Valid employee
);

-- ==================================================================
-- Phase 2: Insert Sample Records (DML - Data Manipulation Language)
-- ==================================================================

-- 1. INSERT INTO: This command adds new rows of data into tables

-- Insert into Department table
INSERT INTO Department VALUES
(1, 'HR', '123456789'),             -- HR department managed by Anil
(2, 'Finance', '223456789'),        -- Finance department managed by Sunita
(3, 'IT', '323456789'),             -- IT department managed by Manoj
(4, 'Marketing', '623456789'),      -- Marketing department managed by Ravi
(5, 'Operations', '723456789');     -- Operations department managed by Sneha

-- Insert into Dept_Loc table (multiple locations per department)
INSERT INTO Dept_Loc VALUES
(1, 'Delhi'), (1, 'Mumbai'),        -- HR has two locations
(2, 'Chennai'),                     -- Finance has one location
(3, 'Bangalore'), (3, 'Hyderabad'), -- IT has two locations
(4, 'Pune'),                        -- Marketing has one location
(5, 'Kolkata');                     -- Operations has one location

-- Insert into Employee table
INSERT INTO Employee VALUES
('123456789', 'Anil', 80000.00, 'M', NULL, 'Delhi', 1),           -- HR Manager, no supervisor
('223456789', 'Sunita', 90000.00, 'F', '123456789', 'Chennai', 2), -- Finance Manager, reports to Anil
('323456789', 'Manoj', 100000.00, 'M', '223456789', 'Bangalore', 3), -- IT Manager, reports to Sunita
('423456789', 'Priya', 80000.00, 'F', '323456789', 'Hyderabad', 3), -- IT Employee, same salary as Anil
('523456789', 'RAM', 85000.00, 'M', '323456789', 'Hyderabad', 3),   -- IT Employee
('623456789', 'Ravi', 70000.00, 'M', NULL, 'Pune', 4),             -- Marketing Manager, no supervisor
('723456789', 'Sneha', 75000.00, 'F', '623456789', 'Kolkata', 5),  -- Operations Manager, reports to Ravi
('823456789', 'Amit', 80000.00, 'M', '723456789', 'Kolkata', 5);   -- Operations Employee, same salary as Anil, no projects

-- Insert into Project table
INSERT INTO Project VALUES
(1, 'Website Redesign', 'Delhi', 1),        -- Project 1: HR department
(2, 'Mobile App', 'Chennai', 2),            -- Project 2: Finance department  
(3, 'Database Upgrade', 'Bangalore', 3),    -- Project 3: IT department
(10, 'TelecomApp', 'Delhi', 1),             -- Project 10: HR department
(20, 'Finsoft', 'Chennai', 2),              -- Project 20: Finance department
(30, 'Cloud Infra', 'Bangalore', 3),        -- Project 30: IT department
(31, 'Cyber Security', 'Bangalore', 3),     -- Project 31: IT department
(32, 'ERP', 'Hyderabad', 3);                -- Project 32: IT department

-- Insert into Works_On table (Employee-Project assignments with hours)
INSERT INTO Works_On VALUES
-- Assignments for projects 1,2,3 (for Query 6)
('123456789', 1, 10), ('223456789', 2, 15), ('323456789', 3, 20),
('423456789', 1, 5), ('523456789', 2, 10), 
-- Original project assignments
('123456789', 10, 20), ('223456789', 20, 25), ('323456789', 30, 30),
('323456789', 31, 15), ('323456789', 32, 40), ('423456789', 30, 10),
('423456789', 31, 20), ('523456789', 30, 30), ('523456789', 31, 20),
('523456789', 32, 10), ('623456789', 1, 25), ('723456789', 2, 30);
-- Note: Amit (823456789) intentionally has no projects for Query 8

-- Insert into Dependent table
INSERT INTO Dependent VALUES
('123456789', 'Asha', 'Delhi', 'Spouse', 'F'),                    -- Anil's spouse
('223456789', 'Amit', 'Chennai', 'Son', 'M'),                     -- Sunita's son
('323456789', 'Seema', 'Bangalore', 'Spouse', 'F'),               -- Manoj's spouse
('423456789', 'Nikhil', 'Hyderabad', 'Brother', 'M'),             -- Priya's brother
('523456789', 'Rita', 'Hyderabad', 'Spouse', 'F'),                -- RAM's spouse
('523456789', 'Raj', 'Hyderabad', 'Son', 'M'),                    -- RAM's son (2 dependents for Query 7)
('623456789', 'Mohan', 'Pune', 'Father', 'M'),                    -- Ravi's father (same address for Query 9)
('723456789', 'Priya', 'Kolkata', 'Daughter', 'F');               -- Sneha's daughter (same address for Query 9)
-- Note: Amit (823456789) intentionally has no dependents for Query 4

-- ============================================================================================
-- Phase 3: Run Queries (DQL - Data Query Language)
-- ============================================================================================

-- 2. Retrieve names of employees who work on all projects controlled by department number 3
SELECT E.name
FROM Employee E
WHERE NOT EXISTS ( -- Operator 'NOT EXISTS': True if no projects are found that employee doesn't work on
    SELECT P.pnumber
    FROM Project P
    WHERE P.dnum = 3 -- Filter: Only projects from department 3
    AND P.pnumber NOT IN ( -- Operator 'NOT IN': Projects that employee doesn't work on
        SELECT W.pno
        FROM Works_On W
        WHERE W.essn = E.ssn -- Correlated subquery: Links to outer employee
    )
);

-- ======================================================================================================
-- 3. Retrieve names of employees who get the second highest salary
SELECT name
FROM Employee
WHERE salary = ( -- Operator '=': Finds employees with salary equal to second highest
    -- Subquery 1: Finds the maximum salary that is less than absolute maximum
    SELECT MAX(salary) -- MAX(): Aggregate function to find maximum value
    FROM Employee
    WHERE salary < ( -- Operator '<': Filters salaries less than maximum
        -- Subquery 2: Finds the absolute maximum salary
        SELECT MAX(salary) FROM Employee
    )
);

-- =========================================================================================================
-- 4. List names of employees who have no dependents, in alphabetical order
SELECT name
FROM Employee e
WHERE NOT EXISTS ( -- Operator 'NOT EXISTS': True if employee has no dependents
    -- Subquery: Looks for any dependent records for this employee
    SELECT 1 FROM Dependent d WHERE d.essn = e.ssn
)
ORDER BY name ASC; -- ORDER BY: Sorts results alphabetically (A-Z)

-- =========================================================================================================
-- 5. Retrieve number of employees and average salary working in each department
SELECT d.dname, 
       COUNT(e.ssn) AS num_employees, -- COUNT(): Counts number of employees
       AVG(e.salary) AS avg_salary    -- AVG(): Calculates average salary
FROM Department d
LEFT JOIN Employee e ON d.dnumber = e.dno -- LEFT JOIN: Includes departments with no employees
GROUP BY d.dname; -- GROUP BY: Groups results by department name

-- =========================================================================================================
-- 6. Retrieve SSN of all employees who work on at least one of project numbers 1, 2, or 3
SELECT DISTINCT essn -- DISTINCT: Removes duplicate SSNs
FROM Works_On
WHERE pno IN (1, 2, 3); -- Operator 'IN': Shortcut for pno=1 OR pno=2 OR pno=3

-- =========================================================================================================
-- 7. Retrieve number of dependents for employee named RAM
SELECT COUNT(*) AS num_dependents -- COUNT(*): Counts all dependent records
FROM Dependent d
JOIN Employee e ON d.essn = e.ssn -- JOIN: Combines Dependent and Employee tables
WHERE e.name = 'RAM'; -- WHERE: Filters for employee named RAM

-- =========================================================================================================
-- 8. List employees who do not work on any project
SELECT name
FROM Employee e
WHERE NOT EXISTS ( -- Operator 'NOT EXISTS': True if employee has no project assignments
    SELECT 1 FROM Works_On w WHERE w.essn = e.ssn
);

-- =========================================================================================================
-- 9. Retrieve names of employees who live in same address as their dependents
SELECT DISTINCT e.name -- DISTINCT: Removes duplicates if employee has multiple dependents at same address
FROM Employee e
JOIN Dependent d ON e.ssn = d.essn AND e.address = d.address; -- JOIN with two conditions

-- =========================================================================================================
-- 10. List department names that have more than one location
SELECT d.dname
FROM Department d
JOIN Dept_Loc l ON d.dnumber = l.dnumber -- JOIN: Links departments to their locations
GROUP BY d.dname -- GROUP BY: Groups locations by department
HAVING COUNT(l.dloc) > 1; -- HAVING: Filters groups with more than one location

-- =========================================================================================================
-- 11. Retrieve names and addresses of employees who work on more than two projects
SELECT e.name, e.address
FROM Employee e
JOIN Works_On w ON e.ssn = w.essn -- JOIN: Links employees to project assignments
GROUP BY e.ssn, e.name, e.address -- GROUP BY: Groups by employee details
HAVING COUNT(DISTINCT w.pno) > 2; -- HAVING: Filters employees with more than 2 distinct projects

-- =========================================================================================================
-- 12. Find names of employees who earn more than their managers
SELECT e.name
FROM Employee e
JOIN Employee mgr ON e.super_ssn = mgr.ssn -- Self-Join: Employee table joined to itself for manager info
WHERE e.salary > mgr.salary; -- WHERE: Compares employee salary with manager salary

-- =========================================================================================================
-- 13. Retrieve highest salary paid in each department in descending order
SELECT d.dname, MAX(e.salary) AS max_salary -- MAX(): Finds highest salary
FROM Department d
JOIN Employee e ON d.dnumber = e.dno -- JOIN: Links departments to employees
GROUP BY d.dname -- GROUP BY: Groups by department
ORDER BY max_salary DESC; -- ORDER BY DESC: Sorts from highest to lowest salary

-- =========================================================================================================
-- 14. Retrieve names of employees paid same salary as Anil
SELECT name
FROM Employee
WHERE salary = ( -- Operator '=': Compares salary with Anil's salary
    -- Subquery: Finds Anil's salary
    SELECT salary FROM Employee WHERE name = 'Anil'
);
-- AND name <> 'Anil'; -- Operator '<>': Excludes Anil from results

-- =========================================================================================================
-- 15. Retrieve total hours worked by each employee on all projects
SELECT e.name, SUM(w.hours) AS total_hours -- SUM(): Adds all hours worked
FROM Employee e
JOIN Works_On w ON e.ssn = w.essn -- JOIN: Links employees to their worked hours
GROUP BY e.ssn, e.name; -- GROUP BY: Groups hours by employee

-- =========================================================================================================
-- 16. Find average salary of male and female employees separately
SELECT sex, AVG(salary) AS avg_salary -- AVG(): Calculates average salary
FROM Employee
GROUP BY sex; -- GROUP BY: Creates separate groups for male and female employees