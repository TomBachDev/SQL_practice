--AdventureWorks sample database DML queries
USE AdventureWorks2019
-- Pokaż pracowników którzy mają ponad 50 lat.
-- (INNER JOIN, DATEDIFF(), WHERE, ORDER BY)
SELECT 
	PP.LastName + ' ' + PP.FirstName AS [NazwiskoImię],
	E.Gender AS [Płeć],
	E.BirthDate AS [Data urodzenia],
	E.HireDate AS [Data zatrudnienia],
	DATEDIFF(YEAR, E.BirthDate, '2022-01-01') AS [Wiek]
FROM Person.Person AS PP INNER JOIN HumanResources.Employee AS E
		ON (PP.BusinessEntityID = E.BusinessEntityID)
WHERE
	DATEDIFF(YEAR, E.BirthDate, '2022-01-01') > 50
ORDER BY
	Wiek DESC, NazwiskoImię DESC

-- Wyświetl sprzedawcę, który obsłużył zamówienia o największej wartości.
-- (LEFT JOIN, CAST(), ROUND(), SUM(), GROUP BY)
SELECT	TOP 1
	PP.BusinessEntityID AS [ID pracownika],
	PP.FirstName + ' ' + PP.LastName AS [Imię i nazwisko],
	CAST(ROUND(SUM(SOD.LineTotal), 2) AS DECIMAL(20,2)) AS [Łączna kwota zamówień]
FROM
	Sales.SalesOrderDetail AS SOD 
	INNER JOIN 
	Sales.SalesOrderHeader AS SOH 
	ON (SOD.SalesOrderID=SOH.SalesOrderID)
		LEFT JOIN
		Person.Person AS PP
		ON (SOH.SalesPersonID=PP.BusinessEntityID)
WHERE
	PP.BusinessEntityID IS NOT NULL
GROUP BY
	PP.BusinessEntityID,
	PP.FirstName,
	PP.LastName
ORDER BY
	[Łączna kwota zamówień] DESC

-- Oblicz sumę zamówienia o największej i najmniejszej wartości.
-- (nested SELECT)
SELECT
	(
	SELECT TOP 1
		SOH.SubTotal
	FROM
		Sales.SalesOrderHeader AS SOH
	ORDER BY
		1 DESC
	)
	+
	(
	SELECT TOP 1
		SOH.SubTotal
	FROM
		Sales.SalesOrderHeader AS SOH
	ORDER BY
		1 ASC
	)
AS [Suma min i max zamówień]

-- Oblicz sumę zamówienia o największej i najmniejszej wartości.
-- (subquery SELECT)
SELECT
	AVG(sub_query.Suma) AS [Średnia wart. zam. bez zniżki]
FROM
	(
	SELECT
		SUM(OD.OrderQty*OD.UnitPrice) AS Suma
	FROM
		Sales.SalesOrderDetail AS OD
	GROUP BY
		OD.SalesOrderID
	) AS sub_query

-- Oblicz (w osobnej kolumnie) czy wartość zamówienia jest mniejsza (0) czy większa/równa (1) średniej wartość zamówień.
-- (subquery, CASE)
SELECT
	SOD.SalesOrderID,
	SUM(SOD.LineTotal) AS [Wartość zamówienia],
	CASE 
		WHEN SUM(SOD.LineTotal) < 
			(
			SELECT
				AVG(calk_kwota_zam_squery.[Calkowita kwota zamówienia]) AS [Średnia wart. zam.]
			FROM	
				(
				SELECT
					SOD.SalesOrderID,
					SUM(SOD.LineTotal) AS [Calkowita kwota zamówienia]
				FROM
					Sales.SalesOrderDetail AS SOD
				GROUP BY
					SOD.SalesOrderID
				) AS calk_kwota_zam_squery
			) THEN 0
		ELSE 1
	END AS [0-mniejsze niż śr./1-większe niż śr.]
FROM
	Sales.SalesOrderDetail AS SOD
GROUP BY
	SOD.SalesOrderID

-- Oblicz (w osobnej kolumnie) czy wartość zamówienia jest mniejsza (0) czy większa/równa (1) średniej wartość zamówień.
-- (subquery, CASE, DECLARE)
DECLARE @srednia float;
SET @srednia = (
	SELECT
		AVG(calk_kwota_zam_squery.[Calkowita kwota zamówienia]) AS [Średnia wart. zam.]
	FROM	
		(
		SELECT
			SOD.SalesOrderID,
			SUM(SOD.LineTotal) AS [Calkowita kwota zamówienia]
		FROM
			Sales.SalesOrderDetail AS SOD
		GROUP BY
			SOD.SalesOrderID
		) AS calk_kwota_zam_squery
);
SELECT
	SOD.SalesOrderID,
	SUM(SOD.LineTotal) AS [Wartość zamówienia],
	CASE 
		WHEN SUM(SOD.LineTotal) < @srednia THEN 0
		ELSE 1
	END AS [0-mniejsze niż śr./1-większe niż śr.]
FROM
	Sales.SalesOrderDetail AS SOD
GROUP BY
	SOD.SalesOrderID

-- Która kategoria ma najwięcej produktów.
-- (LEFT JOIN, subquery)
SELECT
	PC.Name,
	product_squery.[Liczba produktów w kategorii]
FROM
	(
	SELECT
		PSC.ProductCategoryID AS [Product Category ID],
		COUNT(*) AS [Liczba produktów w kategorii]
	FROM
		Production.Product AS P 
		LEFT JOIN 
		Production.ProductSubcategory AS PSC 
		ON P.ProductSubcategoryID=PSC.ProductSubcategoryID
	GROUP BY
		PSC.ProductCategoryID
	) AS product_squery
	LEFT JOIN
	Production.ProductCategory AS PC
	ON product_squery.[Product Category ID]=PC.ProductCategoryID

-- Znajdź pierwsze i ostatnie zamówienie.
-- (squery, UNION ALL)
SELECT
	squery1.SalesOrderID,
	squery1.OrderDate AS DataZamowienia,
	squery1.CustomerID AS ID_Klienta,
	squery1.SalesPersonID AS ID_Sprzedawcy
FROM
	(
	SELECT TOP 1
		*
	FROM
		Sales.SalesOrderHeader AS SOH
	ORDER BY
		SOH.OrderDate ASC, SOH.SalesOrderID ASC
	) AS squery1
UNION ALL
SELECT
	squery2.SalesOrderID,
	squery2.OrderDate AS DataZamowienia,
	squery2.CustomerID AS ID_Klienta,
	squery2.SalesPersonID AS ID_Sprzedawcy
FROM
	(
	SELECT TOP 1
		*
	FROM
		Sales.SalesOrderHeader AS SOH
	ORDER BY
		SOH.OrderDate DESC, SOH.SalesOrderID DESC
	) AS squery2

-- Wyświetl klienta/ów który złożył największą liczbę zamówień. 
-- Wyniki posortuj id_klienta (rosnąco). 
-- Policz tylko te zamówienia które są związane z jakimś sklepem.
-- (subquery, DECLARE, INNER JOIN, HAVING)
DECLARE @ilosc_zam int = (
SELECT TOP 1
	COUNT(*) AS LiczbaZamowien
FROM
	Sales.SalesOrderHeader AS SOH
	INNER JOIN
	(
	SELECT
		C.CustomerID
	FROM
		Sales.Customer AS C
		INNER JOIN 
		Sales.Store AS S
		ON (C.StoreID=S.BusinessEntityID)
	) AS squery1
	ON (SOH.CustomerID=squery1.CustomerID)
GROUP BY
	SOH.CustomerID
ORDER BY
	LiczbaZamowien DESC
);
SELECT
	SOH.CustomerID,
	S.Name,
	COUNT(*) AS LiczbaZamowien
FROM
	Sales.SalesOrderHeader AS SOH
	INNER JOIN
	Sales.Customer AS C
	ON (SOH.CustomerID=C.CustomerID)
		INNER JOIN 
		Sales.Store AS S
		ON (C.StoreID=S.BusinessEntityID)
GROUP BY
	SOH.CustomerID, S.Name
HAVING 
	COUNT(*)=@ilosc_zam
ORDER BY
	SOH.CustomerID ASC

-- Liczba pracowników zatrudnionych przed 2009, miedzy 2009 a 2012.
-- (CASE, subquery, YEAR())
SELECT
	 squery1.opis AS Grupa
	,COUNT(*) AS LiczbaPracowników
FROM
	(	
	SELECT
		YEAR(E.HireDate) AS Rok,
		(CASE
			WHEN YEAR(E.HireDate) < 2009 
				THEN '1. Zatrudnieni przed 2009 r.'
			WHEN (YEAR(E.HireDate) >= 2009 AND YEAR(E.HireDate) <= 2012) 
				THEN '2. Zatrudnieni pomiędzy 2009-2012 r.'
			WHEN YEAR(E.HireDate) > 2012 
				THEN '3. Zatrudnieni po 2012 r.'
		END) AS opis				
	FROM
		HumanResources.Employee AS E			
	) AS squery1
GROUP BY
	squery1.opis	
ORDER BY
	1

