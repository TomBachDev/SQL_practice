-- BANK DataBase (resources: anonco.pl)
-- DML SQL queries - data exploration project
USE
	BANK

-- Zestawienie zarobków pracowników 
--(SELECT, ORDER BY, CAST, ROUND(), alias)
SELECT 
	P.imie + ' ' + P.nazwisko AS [Imię i nazwisko],
	CAST(ROUND(P.pensja/23, 2) AS DECIMAL(6,2)) AS [Dniówka],
	CAST(ROUND((P.pensja/23)*5, 2) AS DECIMAL(6,2)) AS [Tygodniówka],
	P.pensja AS [Pensja miesięczna],
	P.pensja*12 AS [Pensja roczna]
FROM
	Pracownicy AS P
ORDER BY
	[Pensja miesięczna] DESC

-- Lista pracowników z nazwiskiem zaczynającym się na literę M 
--(WHERE LIKE, merging columns)
SELECT
	P.imie + ' ' + P.nazwisko AS [Imię i nazwisko pracownika]
FROM
	Pracownicy AS P
WHERE
	P.nazwisko LIKE 'M%'

-- Pracownicy z działu logistyki lub informatyki. 
-- (IN <-- skrócona wersja OR'a)
SELECT
	P.imie + ' ' + P.nazwisko AS [Imię i nazwisko pracownika]
FROM
	Pracownicy AS P
WHERE
	P.ID_dzialu IN (60,70)

-- Pracownicy, których przełożonym jest Leopold Banko 
-- (subquery)
SELECT
	P.imie + ' ' + P.nazwisko AS [Imię i nazwisko pracownika]
FROM
	Pracownicy AS P
WHERE
	ID_przelozonego=(SELECT
						ID_pracownika
					FROM Pracownicy
					WHERE
						imie='Leopold' AND nazwisko='Banko'
					)

