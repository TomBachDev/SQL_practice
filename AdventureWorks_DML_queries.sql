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

