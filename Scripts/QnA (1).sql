-- ## BASIC QUERY ## --

-- 1. Fetch all orders placed by users who joined before March 2024.
SELECT OrderID, o.UserID, JoinDate, OrderDate, TotalAmount
FROM Orders o 
INNER JOIN Users u
ON o.UserID = u.UserID
WHERE u.JoinDate < '2024-03-01';

-- 2. List all products under the "Electronics" category with price greater than $100.
SELECT * 
FROM Products
WHERE Category = 'Electronics' AND Price > 100;

-- ## FUNCTIONS ## -- 

-- 1. Scalar function to calculate total revenue from all orders.

/*
CREATE FUNCTION GetTotalRevenue()
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @TotalRevenue DECIMAL(10, 2)
    SELECT @TotalRevenue = SUM(TotalAmount) from Orders;
    RETURN @TotalRevenue;
END;
*/

-- USAGE
SELECT dbo.GetTotalRevenue() AS TotalRevenue;

-- 2. Function to return total products purchased by a specific user.
/*
CREATE FUNCTION GetTotalProductsPurchased(@UserID INT) -- parameter
RETURNS INT
AS
BEGIN
    DECLARE @TotalProducts INT 
    SELECT @TotalProducts = SUM(Quantity)
    FROM Orders O 
    INNER JOIN OrderDetails OD 
    ON O.OrderID = OD.OrderID
    WHERE UserID = @UserID ;
    RETURN @TotalProducts;
END;
*/

-- USAGE
SELECT dbo.GetTotalProductsPurchased(6) AS TotalProductsPurchased;