-- Create the main database for the Student Performance Management System
CREATE DATABASE Student_Performance_DB;

-- Select this database to work inside it
USE Student_Performance_DB;

-- ==================================================================
-- Phase 1: Create the tables (DDL - Data Definition Language)
-- ==================================================================

-- 1. Create the tables (Course, Student, Marks)

-- Course Table: Must be created first as its ID is referenced elsewhere.
CREATE TABLE Course (
    course_id INT PRIMARY KEY,              -- PK: Unique identifier for the course
    course_name VARCHAR(100) NOT NULL,
    instructor VARCHAR(50)
);

-- Student Table
CREATE TABLE Student (
    sid INT PRIMARY KEY,                    -- PK: Unique identifier for the student
    sname VARCHAR(50) NOT NULL,
    age INT,
    gender CHAR(1),
    course VARCHAR(100)                     -- Retained as per schema, though Marks tracks enrollment
);

-- Marks Table: The linking table between students and courses
CREATE TABLE Marks (
    sid INT,                                -- FK: References Student(sid)
    course_id INT,                          -- FK: References Course(course_id)
    marks DECIMAL(5, 2),                    -- Stores the marks obtained
    PRIMARY KEY (sid, course_id),           -- Composite PK: A student can only have one score per course
    FOREIGN KEY (sid) REFERENCES Student(sid) ON DELETE CASCADE,      -- If student is deleted, their marks are too
    FOREIGN KEY (course_id) REFERENCES Course(course_id) ON DELETE CASCADE -- If course is deleted, related marks are too
);

-- ==================================================================
-- Phase 2: Insert Sample Records (DML - Data Manipulation Language)
-- ==================================================================

-- 2. Insert some sample records into each table

-- Inserting into Course
INSERT INTO Course (course_id, course_name, instructor) VALUES
(101, 'Database Management', 'Dr. Smith'),
(102, 'Data Structures', 'Prof. Lee'),
(103, 'Web Development', 'Ms. Kaur'),
(104, 'Python Programming', 'Dr. Smith');

-- Inserting into Student (sid 5 will be deleted later)
INSERT INTO Student (sid, sname, age, gender, course) VALUES
(1, 'Aarav Sharma', 20, 'M', 'B.Tech'),
(2, 'Bhavana Desai', 21, 'F', 'B.Tech'),
(3, 'Chetan Yadav', 19, 'M', 'B.Sc'),
(4, 'Diya Menon', 20, 'F', 'B.Tech'),
(5, 'Eshan Varma', 22, 'M', 'M.Tech');

-- Inserting into Marks (sid, course_id, marks)
INSERT INTO Marks VALUES
(1, 101, 85.00),    -- Aarav: Database
(1, 102, 78.50),    -- Aarav: Data Structures
(2, 101, 92.00),    -- Bhavana: Database
(2, 103, 88.00),    -- Bhavana: Web Dev
(3, 101, 65.50),    -- Chetan: Database
(3, 102, 70.00),    -- Chetan: Data Structures
(4, 103, 95.50),    -- Diya: Web Dev
(4, 104, 89.00),    -- Diya: Python
(5, 102, 60.00),    -- Eshan: Data Structures
(5, 104, 75.00);    -- Eshan: Python

-- ==================================================================
-- Phase 3: DML Operations (Updates and Deletions)
-- ==================================================================

-- 3. Update the age of the student with sid = 3.
UPDATE Student
SET age = 20 -- Changing age from 19 to 20
WHERE sid = 3;

-- 4. Rename the column sname to student_name in the Student table.
ALTER TABLE Student
CHANGE COLUMN sname student_name VARCHAR(50) NOT NULL;

-- 5. Delete the student whose sid = 5.
DELETE FROM Student
WHERE sid = 5;
-- Note: Due to ON DELETE CASCADE on the Marks table, Eshan Varma's (sid=5) marks are also deleted.

-- ==================================================================
-- Phase 4: Data Retrieval Queries (DQL - Data Query Language)
-- ==================================================================

-- 6. Count the number of students from the Student table.
SELECT COUNT(sid) AS total_students
FROM Student;

-- 7. Find the maximum marks obtained in any course.
SELECT MAX(marks) AS maximum_marks
FROM Marks;

-- 8. Find the minimum marks obtained in any course.
SELECT MIN(marks) AS minimum_marks
FROM Marks;

-- 9. Retrieve the average marks grouped by each course.
SELECT
    C.course_name,
    AVG(M.marks) AS average_marks
FROM
    Marks M
JOIN
    Course C ON M.course_id = C.course_id
GROUP BY
    C.course_name
ORDER BY
    average_marks DESC;

-- 10. Display the total number of students enrolled in each course.
SELECT
    C.course_name,
    COUNT(M.sid) AS total_enrollment
FROM
    Course C
LEFT JOIN -- Use LEFT JOIN to include courses with 0 enrolled students (if any)
    Marks M ON C.course_id = M.course_id
GROUP BY
    C.course_name
ORDER BY
    total_enrollment DESC;

-- 11. List the student names and marks in descending order of marks.
SELECT
    S.student_name,
    M.marks,
    C.course_name
FROM
    Marks M
JOIN
    Student S ON M.sid = S.sid
JOIN
    Course C ON M.course_id = C.course_id
ORDER BY
    M.marks DESC;

-- 12. Retrieve the sum of marks scored by students in each course.
SELECT
    C.course_name,
    SUM(M.marks) AS total_marks_scored
FROM
    Marks M
JOIN
    Course C ON M.course_id = C.course_id
GROUP BY
    C.course_name
ORDER BY
    total_marks_scored DESC;

-- 13. Display the minimum and maximum marks for each course.
SELECT
    C.course_name,
    MIN(M.marks) AS min_marks,
    MAX(M.marks) AS max_marks
FROM
    Marks M
JOIN
    Course C ON M.course_id = C.course_id
GROUP BY
    C.course_name;

-- 14. Find the average age of students.
SELECT
    AVG(age) AS average_student_age
FROM
    Student;

-- 15. List all courses in alphabetical order along with the number of enrolled students.
SELECT
    C.course_name,
    COUNT(M.sid) AS enrolled_students
FROM
    Course C
LEFT JOIN -- Use LEFT JOIN to count all courses, even if enrollment is 0
    Marks M ON C.course_id = M.course_id
GROUP BY
    C.course_name
ORDER BY
    C.course_name ASC; -- Final result is sorted alphabetically by course name