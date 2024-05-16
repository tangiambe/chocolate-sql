-- RESET --
-- Disable foreign key checks
SET foreign_key_checks = 0;

-- Drop all tables
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Chocolate;

-- Drop views
DROP VIEW IF EXISTS customerorders;

-- Drop procedures
DROP PROCEDURE IF EXISTS InsertChocolate;

-- Drop Views
DROP ROLE IF EXISTS admin;
DROP ROLE IF EXISTS employee;

-- Drop Users
DROP USER IF EXISTS 'user1';
DROP USER IF EXISTS 'user2';

-- Enable foreign key checks
SET foreign_key_checks = 1;
                                                            
                                                            
                                                            -- DATABASE DESIGN --
-- Create tables for Chocolate, Customers, and Orders
-- Define relationships between tables
-- Implement constraints for data integrity

CREATE TABLE Chocolate (
    chocolate_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    inventory_quantity INT NOT NULL CHECK (inventory_quantity >= 0)
);

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    chocolate_id INT,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (chocolate_id) REFERENCES Chocolate(chocolate_id)
);

															-- DATA POPULATION --
-- Populate database with sample data
-- Ensure data consistency and referential integrity

INSERT INTO Chocolate (chocolate_id, name, description, price, inventory_quantity)
VALUES
    (1, 'Dark Chocolate Bar', 'Rich and indulgent dark chocolate', 3.99, 100),
    (2, 'Milk Chocolate Bar', 'Creamy milk chocolate', 5.99, 50),
    (3, 'White Chocolate Bar', 'Sweet and smooth white chocolate', 4.49, 75)
;

INSERT INTO Customers (customer_id, name, email)
VALUES
    (1, 'John Doe', 'john@example.com'),
    (2, 'Jane Smith', 'jane@example.com')
;

INSERT INTO Orders (order_id, customer_id, chocolate_id, order_date, total_amount)
VALUES
	(1, 1, 2, '2024-05-10', 5.99),
    (2, 1, 1, '2024-05-10', 3.99),
    (3, 2, 3, '2024-05-11', 4.49),
    (4, 2, 1, '2024-05-11', 3.49),
    (5, 1, 1, '2024-05-13', 3.49)
;
    

															-- BASIC OPERATIONS --
-- CRUD operations for managing chocolate, customers, and orders
-- Add, update and delete records from the database

-- Create Chocolate
INSERT INTO Chocolate (chocolate_id, name, description, price, inventory_quantity)
VALUES (4, 'Cookies and Cream Bar', 'Crunchy Oreo bits in smooth white chocolate', 4.99, 80);

-- Read Chocolates
SELECT * FROM Chocolate;

-- Update Chocolate
UPDATE Chocolate
SET price = 6.99
WHERE chocolate_id = 1;

-- Delete Chocolate
DELETE FROM Chocolate
WHERE chocolate_id = 4;

-- Create Customer
INSERT INTO Customers (customer_id, name, email)
VALUES (3, 'Michael Jackson', 'mj@example.com');

-- Read Customers
SELECT * FROM Customers;

-- Update Customer
UPDATE Customers
SET email = 'mjack@thriller.com'
WHERE customer_id = 3;

-- Delete Customer
DELETE FROM Customers
WHERE customer_id = 3;

-- Create Order
INSERT INTO Orders (order_id, customer_id, chocolate_id, order_date, total_amount)
VALUES (6, 1, 2, '2024-05-12', 4.49);

-- Read Orders
SELECT * FROM Orders;

-- Update Order
UPDATE Orders
SET total_amount = 20.00
WHERE order_id = 6;

-- Delete Order
DELETE FROM Orders
WHERE order_id = 6;

															-- INTERMEDIATE QUERIES --
-- Create queries to retrieve information
-- Utilize JOIN operations to fetch data from multiple related tables

-- Top-selling chocolate
SELECT c.name AS chocolate_name, SUM(1) AS total_quantity_sold
FROM Chocolate c
JOIN Orders o ON c.chocolate_id = o.chocolate_id
GROUP BY c.chocolate_id, c.name
ORDER BY total_quantity_sold DESC
LIMIT 1;

-- Customers with the highest order amounts
SELECT c.name AS customer_name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 1;

-- Total revenue generated over a specific period
SELECT SUM(total_amount) AS total_revenue
FROM Orders
WHERE order_date BETWEEN '2024-05-01' AND '2024-05-31';

-- Chocolate with low inventory levels
SELECT *
FROM Chocolate
WHERE inventory_quantity < 100;


-- Implementing Constraints and Indexes --

-- Adding a constraint to ensure price is non-negative
ALTER TABLE Chocolate
ADD CONSTRAINT chk_price_non_negative CHECK (price >= 0);

-- Adding an index on the customer_id column in the Orders table for faster lookups
CREATE INDEX idx_customer_id ON Orders(customer_id);


-- Aggregating Data using GROUP BY and Aggregate Functions --

-- Calculate total revenue generated by each customer
SELECT Customers.name, SUM(Orders.total_amount) AS total_revenue
FROM Customers
JOIN Orders ON Customers.customer_id = Orders.customer_id
GROUP BY Customers.name;


-- Views --

-- Creating a view to display customer orders
CREATE VIEW CustomerOrders AS
SELECT Customers.name AS customer_name, Orders.order_date, Orders.total_amount
FROM Customers
JOIN Orders ON Customers.customer_id = Orders.customer_id;

-- Retrieve customer orders using the view
SELECT * FROM CustomerOrders;


-- Stored Procedures --

-- Creating a stored procedure to insert a new chocolate
DELIMITER //

CREATE PROCEDURE InsertChocolate(IN chocolate_id INT, IN name VARCHAR(100), IN description TEXT, IN price DECIMAL(10, 2), IN inventory_quantity INT)
BEGIN
    INSERT INTO Chocolate (chocolate_id, name, description, price, inventory_quantity)
    VALUES (chocolate_id, name, description, price, inventory_quantity);
END //

DELIMITER ;

-- Use stored procedure to insert new chocolate bar
CALL InsertChocolate(4, 'Caramel Chocolate Bar', 'Smooth milk chocolate filled with gooey caramel', 5.49, 60);


															-- ADVANCED QUERIES --
-- Implement transactions to ensure atomicity and consistency during order processing
START TRANSACTION;

-- Order processing query
INSERT INTO Orders (order_id, customer_id, chocolate_id, order_date, total_amount)
VALUES (6, 2, 4, '2024-05-13', 5.49);

UPDATE Chocolate
SET inventory_quantity = inventory_quantity - 1
WHERE chocolate_id = 4;

COMMIT;

-- ROLLBACK;


-- Develop complex queries to answer specific business questions(e.g., identifying patterns in customer behavior)
-- Average order amount per customer
SELECT c.name AS customer_name, AVG(o.total_amount) AS avg_order_amount
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.name;


-- Optimize query performance by analyzing query execution plans and indexing strategies
-- Creating an index on frequently queried column, Customer Name
CREATE INDEX idx_customer_name ON Customers(name);

-- Query without index
SELECT * FROM Customers WHERE name = 'John Doe';

-- Query with index
SELECT * FROM Customers USE INDEX (idx_customer_name) WHERE name = 'John Doe';



-- Implement role-based access control to restrict access to sensitive data and operations

-- Creating roles and granting permissions
CREATE ROLE admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Chocolate TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Customers TO admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON Orders TO admin;

CREATE ROLE employee;
GRANT SELECT, INSERT, UPDATE ON Chocolate TO employee;
GRANT SELECT, INSERT, UPDATE ON Customers TO employee;
GRANT SELECT, INSERT, UPDATE ON Orders TO employee;

-- Create Users
CREATE USER 'user1' IDENTIFIED BY '123';
CREATE USER 'user2' IDENTIFIED BY '456';

-- Assign roles to users
GRANT admin TO user1;
GRANT employee TO user2;

-- Admin Role Operations --

-- Insert a new chocolate
INSERT INTO Chocolate (chocolate_id, name, description, price, inventory_quantity)
VALUES (5, 'Raspberry Chocolate Bar', 'Delicious raspberry-filled chocolate bar', 4.99, 50);

-- Update customer information
UPDATE Customers
SET email = 'john.doe@example.com'
WHERE customer_id = 1;

-- Delete an order
DELETE FROM Orders
WHERE order_id = 3;


-- Employee Role Operations--

-- View all chocolates
SELECT * FROM Chocolate;

-- Add a new customer
INSERT INTO Customers (customer_id, name, email)
VALUES (3, 'Iron Man', 'iron.man@avengers.com');

-- Update order information
UPDATE Orders
SET total_amount = 30.00
WHERE order_id = 2;

-- Employee can't do DELETE operations
DELETE FROM Orders
WHERE order_id = 2;










