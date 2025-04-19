-- ## TRANSACTION ## --
-- 1. Transaction to place an order ensuring consistency.
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

-- ## STORED PROCEDURE ## --
-- 1. Stored procedure to add a new user and recommend a random product.

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

-- ## Analytical Questions ## --

-- 1. Fetch the total revenue grouped by product categories with max to min
SELECT Category, SUM(Subtotal) AS TotalRevenue
FROM OrderDetails OD 
INNER JOIN Products P 
ON OD.ProductID = P.ProductID
GROUP BY Category
ORDER BY 2 DESC ;

-- 2. Identify the top 2 user Name, ID, total with the highest spending.
SELECT TOP 2 U.UserID, U.Name, SUM(TotalAmount) AS 'TotalAmount'
FROM Users U 
INNER JOIN Orders O 
ON U.UserID = O.UserID 
GROUP BY U.UserID, U.Name
ORDER BY 3 DESC;

-- 3. Suggest products not yet purchased by a specific user.
SELECT ProductID, ProductName, Category
FROM Products 
WHERE ProductID NOT IN (
    SELECT ProductID
    FROM Orders O 
    INNER JOIN OrderDetails OD 
    ON O.OrderID = OD.OrderID 
    WHERE O.UserID = 1);

-- ## FUNCTION ## --
GO
CREATE FUNCTION GetProductsNotOrdered(@UserID INT)
RETURNS TABLE
AS 
RETURN
(
    SELECT ProductID, ProductName, Category
        FROM Products 
        WHERE ProductID NOT IN (
            SELECT ProductID
            FROM Orders O 
            INNER JOIN OrderDetails OD 
            ON O.OrderID = OD.OrderID 
            WHERE O.UserID = @UserID)
);
GO

SELECT * FROM dbo.GetProductsNotOrdered(5);