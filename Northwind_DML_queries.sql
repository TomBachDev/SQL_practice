--Northwind sample database DML basic queries
USE Northwind
-- Obliczenie rożnicy między zamówieniami o największej i najmniejszej wartości. 
-- (CAST, ROUND, SUM, GROUP BY, ORDER BY, SELECT TOP, sorting, alias, subqueries, math operations)
SELECT
	(SELECT TOP 1
		CAST(ROUND(SUM((O.UnitPrice*O.Quantity) - (O.UnitPrice*O.Quantity)*O.Discount),2) AS DECIMAL(10,2)) AS [Łącznie]
	FROM
		[Order Details] AS O
	GROUP BY
		O.OrderID
	ORDER BY
		1 DESC
	)
	-
	(SELECT TOP 1
		CAST(ROUND(SUM((O.UnitPrice*O.Quantity) - (O.UnitPrice*O.Quantity)*O.Discount),2) AS DECIMAL(10,2)) AS [Łącznie]
	FROM
		[Order Details] AS O
	GROUP BY
		O.OrderID
	ORDER BY
		1 ASC
	) AS [Różnica między zamówieniem najdroższym i najtańszym]

-- Oblicz Łączna ilość zamówień 2 klientów z największą ilością zamówień
-- (COUNT, SUM, obliczanie z podzapytania)
SELECT 
	SUM(zamowienia) AS [Łączna ilość zamówień 2 największych klientów]
FROM
	(SELECT TOP 2
		COUNT(CustomerID) AS zamowienia
	FROM
		Orders
	GROUP BY
		CustomerID
	ORDER BY
		1 DESC
	) AS [Zestawienie ilości zamowień]

-- Znajdź informacje nt. dostawców czekolady.
--(WHERE, INNER JOIN, merging columns)
SELECT
	S.SupplierID AS [ID dostawcy],
	S.CompanyName AS [Nazwa firmy],
	S.Address + ' / ' + S.City AS [Adres/Miasto],
	S.Phone AS [Numer kontaktowy]
FROM 
	Suppliers as S
	INNER JOIN Products AS P 
		ON S.SupplierID = P.SupplierID
WHERE
	P.ProductName = 'Chocolade'

-- Raport sprzedaży za 1996 rok.
-- (YEAR(), MONTH(), SUM(), INNER JOIN, WHERE, BETWEEN, GROUP BY, ORDER BY)
SELECT
	YEAR(O.OrderDate) AS [Rok],
	MONTH(O.OrderDate) AS [Miesiąc],
	SUM(OD.UnitPrice * OD.Quantity) AS [Sprzedaż]
FROM
	Orders AS O 
	INNER JOIN [Order Details] AS OD ON O.OrderID = OD.OrderID
WHERE
	YEAR(O.OrderDate) = 1996 AND MONTH(O.OrderDate) BETWEEN 1 AND 12
GROUP BY
	YEAR(O.OrderDate), MONTH(O.OrderDate)
ORDER BY 
	[Miesiąc]

-- Wyświetl zamówienia których wartość jest mniejsza niż 100 dol. 
-- Wyniki przedstaw w podziale na rok i miesiąc i posortuj malejąco wg roku i miesiąca.
--(GROUP BY <-- to co wyświetlamy w SELECT wrzucamy też do GROUP BY, HAVING <-- stosowany z funkcjami agregującymi)
SELECT
	O.OrderID AS [ID zamówienia],
	YEAR(O.OrderDate) AS [Rok],
	MONTH(O.OrderDate) AS [Miesiąc],
	CAST(ROUND(SUM((OD.UnitPrice*OD.Quantity) - (OD.UnitPrice*OD.Quantity)*OD.Discount),2) AS DECIMAL(10,2)) AS [Łącznie]
FROM
	[Order Details] AS OD
	INNER JOIN Orders AS O ON O.OrderID = OD.OrderID
GROUP BY
	O.OrderID, YEAR(O.OrderDate), MONTH(O.OrderDate)
HAVING
	CAST(ROUND(SUM((OD.UnitPrice*OD.Quantity) - (OD.UnitPrice*OD.Quantity)*OD.Discount),2) AS DECIMAL(10,2)) < 100
ORDER BY
	2 DESC, 3 DESC

-- Oblicz jaki procent wszystkich zamówień stanowią zamówienia przedświąteczne(1-23 grudnia)?
-- (WHERE, DAY(), MONTH(), COUNT, operations on subqueries)
SELECT
	(SELECT 
		COUNT(*) 
	FROM 
		Orders
	) AS [Wszystkie zamówienia],

	(SELECT 
		COUNT(*) 
	FROM Orders 
	WHERE	
		(DAY(OrderDate) BETWEEN 1 AND 23) AND MONTH(OrderDate) = 12
	) AS [Zamówienia w okresie przedświątecznym],

	(	(SELECT 
			COUNT(*)
		FROM 
			Orders 
		WHERE
			(DAY(OrderDate) BETWEEN 1 AND 23) AND MONTH(OrderDate) = 12)
		*100/
		(SELECT 
			COUNT(*) 
		FROM
			Orders)
	) AS [Procent]

-- Który spedytor obsłużył zamówienia na największą wartość.
-- (INNER JOIN, GROUP BY, ORDER BY, SUM(), ROUND())
SELECT TOP 1
	S.CompanyName AS [Nazwa firmy],
	ROUND(SUM((OD.UnitPrice*OD.Quantity) - (OD.UnitPrice*OD.Quantity)*OD.Discount),2) AS [Wartość zamówień]
FROM
	Shippers AS S 
	INNER JOIN Orders AS O 
		ON S.ShipperID = O.ShipVia
			INNER JOIN [Order Details] AS OD 
				ON O.OrderID = OD.OrderID
GROUP BY
	S.CompanyName
ORDER BY
	2 DESC

-- Oblicz ilość klientów z min.1 zamówieniem i bez zamówienia.
-- (COUNT, LEFT JOIN)

SELECT
	((SELECT
		COUNT(*)
	FROM
		Customers)
	-
	(SELECT 
		COUNT(*) AS [Ilość klientów, którzy nie złożyli żadnego zamówienia]
	FROM
		Customers AS C LEFT JOIN Orders AS O 
			ON C.CustomerID = O.CustomerID 
				WHERE O.CustomerID IS NULL)) AS [Klienci z min. jednym zamówieniem],

	(SELECT 
		COUNT(*) AS [Ilość klientów, którzy nie złożyli żadnego zamówienia]
	FROM
		Customers AS C LEFT JOIN Orders AS O 
			ON C.CustomerID = O.CustomerID 
				WHERE O.CustomerID IS NULL) AS [Klienci bez zamówienia]

-- Wyświetl informacje o pierwszym i ostatnim zamówieniu.
-- (UNION ALL with subqueries)
SELECT * FROM
(
	(
	SELECT TOP 1
		'Pierwsze zamówienie' AS [Info],
		OD.OrderID,
		SUM(OD.Quantity) AS [Liczba pozycji w zamówieniu],
		ROUND(SUM(OD.Quantity*OD.UnitPrice - (OD.Quantity*OD.UnitPrice)*OD.Discount), 2) AS [Wartość zamówienia],
		CAST(O.OrderDate AS date) AS [Data zamówienia]
	FROM
		Orders AS O INNER JOIN [Order Details] AS OD
			ON O.OrderID = OD.OrderID
	GROUP BY
		OD.OrderID, O.OrderDate
	ORDER BY
		O.OrderDate ASC
	)
	UNION ALL
	(
	SELECT TOP 1
		'Ostatnie zamówienie' AS [Info],
		OD.OrderID,
		SUM(OD.Quantity) AS [Liczba pozycji w zamówieniu],
		ROUND(SUM(OD.Quantity*OD.UnitPrice - (OD.Quantity*OD.UnitPrice)*OD.Discount), 2) AS [Wartość zamówienia],
		CAST(O.OrderDate AS date) AS [Data zamówienia]
	FROM
		Orders AS O INNER JOIN [Order Details] AS OD
			ON O.OrderID = OD.OrderID
	GROUP BY
		OD.OrderID, O.OrderDate
	ORDER BY
		O.OrderDate DESC
	)
) AS [Zestawione dane];

