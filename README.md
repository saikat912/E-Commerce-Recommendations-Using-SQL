!(Schema Diagram)[https://github.com/saikat912/E-Commerce-Recommendations-Using-SQL/blob/a3a70199515998c3958499d00bff55f6dd590dd5/Schema.png]
# SQL Queries Project 🚀

This repository contains a collection of SQL queries for various analytical and transactional purposes. The queries are designed to work with a database containing tables such as `Users`, `Orders`, `OrderDetails`, `Products`, and `ProductRecommendations`.

## Table of Contents 📚

- [Basic Queries](#basic-queries)
- [Transactional Queries](#transactional-queries)
- [Stored Procedures](#stored-procedures)
- [Analytical Queries](#analytical-queries)
- [Functions](#functions)

## Basic Queries 🔍

This section contains basic SQL queries for fetching data from the database.

### 1. Fetch all orders placed by users who joined before March 2024 🗓️

```
SELECT
    OrderID,
    o.UserID,
    JoinDate,
    OrderDate,
    TotalAmount
FROM
    Orders o
INNER JOIN
    Users u ON o.UserID = u.UserID
WHERE
    u.JoinDate  100;
```

## Transactional Queries 🤝

This section contains SQL transactions that ensure data consistency when performing operations such as placing an order.

### 1. Transaction to place an order ensuring consistency ✅

The following transaction ensures that when a new order is placed, the order details are recorded, and the product stock is updated atomically.

```
BEGIN TRANSACTION;

BEGIN TRY
    -- Insert into Order
    INSERT INTO Orders
    VALUES (11, 3, '2024-12-01', 750);

    -- Insert into OrderDetails
    INSERT INTO OrderDetails
    VALUES (11, 11, 101, 1, 700);

    -- Update Products
    UPDATE Products
    SET Stock = Stock - 1
    WHERE ProductID = 101;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

## Stored Procedures ⚙️

This section includes stored procedures that perform specific tasks, such as adding a new user and recommending a random product.

### 1. Stored procedure to add a new user and recommend a random product 🧑‍💻

The `AddUserAndRecommendProduct` stored procedure adds a new user to the `Users` table and recommends a random product from the `Products` table.

```
GO
CREATE PROCEDURE AddUserAndRecommendProduct
    @UserID INT,
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @JoinDate DATE
AS
BEGIN
    -- Check if the userid is already available in the table
    IF EXISTS (SELECT 1 FROM Users WHERE UserID = @UserID)
    BEGIN
        PRINT 'Error: UserID already exists.';
        RETURN;
    END;

    DECLARE @ProductID INT;
    DECLARE @RecommendationID INT;

    -- Generate the next RecommendataionID
    SELECT @RecommendationID = ISNULL(MAX(RecommendationID), 0) + 1 FROM ProductRecommendations;

    -- Insert the new user
    INSERT INTO Users
    VALUES (@UserID, @Name, @Email, @JoinDate);

    -- Recommend a random Product
    SELECT TOP 1 @ProductID = ProductID FROM Products ORDER BY NEWID();

    -- Insert the recommendation with the genreated id
    INSERT INTO ProductRecommendations
    VALUES (@RecommendationID, @UserID, @ProductID, GETDATE());

    PRINT 'User and recommendation is added successfully.'
END;
```

**Usage:**

```
-- Adding user with ID 401
EXEC AddUserAndRecommendProduct
    @UserID = 401,
    @Name = 'David Clark',
    @Email = 'david.clark@example.com',
    @JoinDate = '2024-12-06';

-- Adding user with ID 402
EXEC AddUserAndRecommendProduct
    @UserID = 402,
    @Name = 'Emma Taylor',
    @Email = 'emma.taylor@example.com',
    @JoinDate = '2024-12-07';

-- Verifying the results
-- User Table
SELECT * FROM Users WHERE UserID IN (401, 402);

-- ProductRecommendation Table
SELECT * FROM ProductRecommendations WHERE UserID IN (401, 402);
```

## Analytical Queries 📊

This section provides queries that perform analytical tasks, such as calculating total revenue by product category and identifying top spending users.

### 1. Fetch the total revenue grouped by product categories with max to min 📈

This query calculates the total revenue for each product category, ordered from highest to lowest.

```
SELECT
    Category,
    SUM(Subtotal) AS TotalRevenue
FROM
    OrderDetails OD
INNER JOIN
    Products P ON OD.ProductID = P.ProductID
GROUP BY
    Category
ORDER BY
    2 DESC;
```

### 2. Identify the top 2 user Name, ID, total with the highest spending 👑

This query identifies the top 2 users who have spent the most money.

```
SELECT TOP 2
    U.UserID,
    U.Name,
    SUM(TotalAmount) AS 'TotalAmount'
FROM
    Users U
INNER JOIN
    Orders O ON U.UserID = O.UserID
GROUP BY
    U.UserID,
    U.Name
ORDER BY
    3 DESC;
```

### 3. Suggest products not yet purchased by a specific user 🤔

This query suggests products that a specific user has not yet purchased.

```
SELECT
    ProductID,
    ProductName,
    Category
FROM
    Products
WHERE
    ProductID NOT IN (
        SELECT
            ProductID
        FROM
            Orders O
        INNER JOIN
            OrderDetails OD ON O.OrderID = OD.OrderID
        WHERE
            O.UserID = 1
    );
```

## Functions ⚙️

This section includes SQL functions that perform specific calculations or retrieve data based on certain criteria.

### 1. Function to get products not ordered by a specific user 📦

This function returns a table of products that have not been ordered by a specific user.

```
GO
CREATE FUNCTION GetProductsNotOrdered(@UserID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT
        ProductID,
        ProductName,
        Category
    FROM
        Products
    WHERE
        ProductID NOT IN (
            SELECT
                ProductID
            FROM
                Orders O
            INNER JOIN
                OrderDetails OD ON O.OrderID = OD.OrderID
            WHERE
                O.UserID = @UserID
        )
);
GO

SELECT * FROM dbo.GetProductsNotOrdered(5);
```

### 2. Scalar function to calculate total revenue from all orders 💰

```
-- USAGE
SELECT dbo.GetTotalRevenue() AS TotalRevenue;
```

### 3. Function to return total products purchased by a specific user 🛍️

```
-- USAGE
SELECT dbo.GetTotalProductsPurchased(6) AS TotalProductsPurchased;



