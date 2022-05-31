USE AdventureWorks2019;

-- Rank product Subcategories according to the SalesValue for each Subcategory.
-- (CTE; window function: RANK())
WITH sales_by_category AS
(
    SELECT  
        C.Name AS 'Category',
        SC.Name AS 'Subcategory',
        CAST(SUM(SOD.LineTotal) AS numeric(15, 2)) AS 'SalesValue'
    FROM 
        Sales.SalesOrderDetail AS SOD
        INNER JOIN Production.Product AS P
            ON SOD.ProductID = P.ProductID
        INNER JOIN Production.ProductSubcategory AS SC
            ON P.ProductSubcategoryID = SC.ProductSubcategoryID
        INNER JOIN Production.ProductCategory AS C
            ON SC.ProductCategoryID = C.ProductCategoryID
    GROUP BY C.Name, SC.Name
)

SELECT 
    Category, 
    Subcategory,
    SalesValue, 
    RANK() OVER(PARTITION BY Category ORDER BY SalesValue DESC) AS 'Rank'
FROM 
    sales_by_category
ORDER BY Category

-- List of the first 10 customers(not companies) that were registered.
-- (variables, while loop, PRINT)
DECLARE @counter INT = 1;
DECLARE @customerID AS INT = (
        SELECT TOP 1
            C.CustomerID
        FROM
            Sales.Customer AS C 
        WHERE C.PersonID IS NOT NULL
        );
DECLARE @personID_for_customer AS INT = (
        SELECT
            C.PersonID
        FROM
            Sales.Customer AS C 
        WHERE C.CustomerID = @customerID
        );
DECLARE @fname AS NVARCHAR(20);
DECLARE @lname AS NVARCHAR(30);

WHILE @counter <=10
BEGIN
    SELECT 
        @fname = FirstName, 
        @lname = LastName 
    FROM Sales.Customer AS C 
        INNER JOIN Person.Person AS P 
        ON C.PersonID = P.BusinessEntityID
    WHERE P.BusinessEntityID = @personID_for_customer;
    
    PRINT @fname + N' ' + @lname;
    SET @customerID += 1;
    SET @personID_for_customer = (
        SELECT
            C.PersonID
        FROM
            Sales.Customer AS C 
        WHERE C.CustomerID = @customerID
        );
    SET @counter += 1;
END;

-- View top 10 expensive products for a given category ID.
-- (stored procedures with parameters, batches)
GO
CREATE PROCEDURE Sales.TopProducts @categoryID int AS
    SELECT TOP 10 
        Name, 
        ListPrice
    FROM Production.Product
    WHERE ProductSubcategoryID = @categoryID 
    GROUP BY Name, ListPrice
    ORDER BY ListPrice DESC; 

EXECUTE Sales.TopProducts @categoryID = 1;

EXECUTE Sales.TopProducts 20;
GO

--Get the product list price for a specific product on a certain day:
-- (scalar user-defined function)
CREATE FUNCTION dbo.ufn_GetProductListPrice (@ProductID int, @OrderDate datetime)
    RETURNS money 
    AS 
    BEGIN
        DECLARE @ListPrice money;
            
        SELECT 
            @ListPrice = PLPH.ListPrice
        FROM Production.Product AS P 
            INNER JOIN Production.ProductListPriceHistory AS PLPH 
            ON P.ProductID = PLPH.ProductID
                AND P.ProductID = @ProductID 
                    AND PLPH.StartDate = @OrderDate
        
        RETURN @ListPrice;
    END;
GO

SELECT dbo.ufn_GetProductListPrice (707, '2011-05-31')
GO

-- Run the table-valued function to return data for the year 2008.
-- (table-valued user-defined function)
CREATE FUNCTION Sales.GetFreightbyCustomer (@orderyear AS INT) 
    RETURNS TABLE
    AS
    RETURN
        SELECT
            SOH.CustomerID, 
            SUM(Freight) AS 'Total Freight'
        FROM 
            Sales.SalesOrderHeader AS SOH
        WHERE YEAR(OrderDate) = @orderyear
        GROUP BY SOH.CustomerID 
GO

SELECT * FROM Sales.GetFreightbyCustomer(2011);
GO

-- Create a stored procedure to display an error message
-- (stored procedure, error functions)
CREATE PROCEDURE dbo.GetErrorInfo AS
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS varchar(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Severity: ' + CAST(ERROR_SEVERITY() AS varchar(10));
    PRINT 'Error State: ' + CAST(ERROR_STATE() AS varchar(10));
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS varchar(10));
    PRINT 'Error Proc: ' + COALESCE(ERROR_PROCEDURE(), 'Not within procedure');
GO
-- Testing error info display procedure. Throwing error message so a client application can catch and process it.
-- (TRY/CATCH, THROW)
BEGIN TRY
    PRINT 5 / 0;
END TRY
BEGIN CATCH
    EXECUTE dbo.GetErrorInfo; 
    THROW;
END CATCH;
GO

-- Add error handling routine to the query. Prevent it from showing duplicates. View message if error occurs. 
-- (TRY/CATCH, @@ROWCOUNT, IF)
DECLARE @customerID AS INT = 30100;
DECLARE @fname AS NVARCHAR(20);
DECLARE @lname AS NVARCHAR(30);
DECLARE @counter AS INT = 1; 

WHILE @counter <= 20
BEGIN
    BEGIN TRY
        SELECT 
            @fname = P.FirstName, 
            @lname = P.LastName 
        FROM Sales.Customer AS C 
            INNER JOIN Person.Person AS P
            ON C.PersonID=P.BusinessEntityID
        WHERE CustomerID = @CustomerID;

        IF @@ROWCOUNT > 0 -- using "IF @@ROWCOUNT > 0" clause to check and only display a result if the customer ID exists
        BEGIN
            PRINT CAST(@customerID as NVARCHAR(20)) + N' ' + @fname + N' ' + @lname;
        END
    END TRY
    BEGIN CATCH
        PRINT 'Unable to run query'; -- informing user whether an error occured and query could not be run
    END CATCH

    SET @counter += 1;
    SET @CustomerID += 1;
END;
GO

-- Use a transaction to insert data into multiple tables.
-- The following code encloses the logic to insert a product category and subcategory in a transaction, rolling back the transaction if an error occurs.
-- (TRY/CATCH, transaction COMMIT/ROLLBACK, XACT_STATE())
BEGIN TRY
BEGIN TRANSACTION;

    INSERT INTO Production.ProductCategory (Name, ModifiedDate)
    VALUES ('Food', GETDATE());

    DECLARE @CategoryID INT;
    SELECT @CategoryID = MAX(ProductCategoryID) FROM Production.ProductCategory;

    INSERT INTO Production.ProductSubcategory (ProductCategoryID, Name, ModifiedDate)
    VALUES (@CategoryID, 'Protein bar', GETDATE());

COMMIT TRANSACTION;
    PRINT 'Transaction committed.';
END TRY
BEGIN CATCH
    PRINT 'An error occurred.';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS varchar(10));
    PRINT 'Error Message: ' + ERROR_MESSAGE();
  
    IF (XACT_STATE()) <> 0 -- this function can be used before the ROLLBACK command, to check whether the transaction is active.
    BEGIN
        PRINT 'Transaction in process.';
        ROLLBACK TRANSACTION;
        PRINT 'Transaction rolled back.'; 
    END;
END CATCH;

