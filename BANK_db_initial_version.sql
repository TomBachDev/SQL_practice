CREATE DATABASE BANK
GO
USE BANK
GO
CREATE TABLE Dzialy
	(
		 ID_dzialu INT CONSTRAINT PK_dzial PRIMARY KEY
		,nazwa NVARCHAR(30)
		,adres NVARCHAR(50) 
	);

CREATE TABLE Stanowiska
    (
		 ID_stanowiska INT CONSTRAINT PK_stanowisko PRIMARY KEY
		,nazwa NVARCHAR(25)
		,placaOd NUMERIC (7,2)
		,placaDo NUMERIC (7,2)
	);

CREATE TABLE Pracownicy
    (
		 ID_pracownika INT CONSTRAINT PK_pracownik PRIMARY KEY
		,imie NVARCHAR(20)
		,nazwisko NVARCHAR(25)
		,ID_dzialu INT CONSTRAINT FK_ID_dzial REFERENCES Dzialy(ID_dzialu)
		,ID_stanowiska INT CONSTRAINT FK_stanowisko REFERENCES Stanowiska(ID_stanowiska)
		,ID_przelozonego INT CONSTRAINT FK_ID_przelozony REFERENCES Pracownicy(ID_pracownika)
		,dataZatrudnienia DATE
		,pensja NUMERIC (7,2)
		,dodatki NUMERIC (7,2)
	);
  
INSERT INTO Dzialy VALUES (10,'Zarządzanie','Zawodzie 12');
INSERT INTO Dzialy VALUES (20,'Księgowość','Kalwaryjska 25');
INSERT INTO Dzialy VALUES (30,'Finanse','Konopnickiej 30');
INSERT INTO Dzialy VALUES (40,'Obsługa klientów','Słoneczna 15');
INSERT INTO Dzialy VALUES (50,'Obsługa klientów biznesowych','Focha 20');
INSERT INTO Dzialy VALUES (60,'Logistyka','Nowa 33');
INSERT INTO Dzialy VALUES (70,'Informatyka','Legionów Polskich 14');

INSERT INTO Stanowiska VALUES (10,'prezes',10000.00,15000.00);
INSERT INTO Stanowiska VALUES (20,'wiceprezes',8000.00,10000.00);
INSERT INTO Stanowiska VALUES (30,'menedżer',7000.00,8000.00);
INSERT INTO Stanowiska VALUES (40,'lider',6000.00,7000.00);
INSERT INTO Stanowiska VALUES (50,'asystent',5000.00,6000.00);
INSERT INTO Stanowiska VALUES (60,'referent',4000.00,5000.00);
INSERT INTO Stanowiska VALUES (70,'praktykant',3000.00,4000.00);
 
INSERT INTO Pracownicy
VALUES 
(10,'Piotr','Aktoriusz',NULL ,10,NULL,'1970-01-21',11500.00,2150.50),
(20,'Jan','Fejsbuczak',NULL ,20,10,'1972-02-28',9500.00,1450.44),
(30,'Aldona','Cisowiak',NULL,20,10,'1973-06-14',8600.99,1399.99),
(40,'Ilona','Murowanka',10,30,20,'1974-04-01',7800.00,1200.00),
(50,'Jacek','Profiliusz',20,30,20,'1974-04-15',7950.50,1250.00),
(60,'Lucjusz','Malfojczak',30,30,20,'1972-05-15',7950.50,1250.00),
(70,'Lidia','Jazowiak',40,30,30,'1982-07-25',7750.50,1150.00),
(80,'Zuza','Oneciak',50,30,30,'1977-11-20',7890.30,1160.00),
(90,'Pola','Interiusz',60,30,30,'1980-08-17',7550.50,1150.50),
(100,'Cyprian','Kiepściuch',70,30,30,'1981-10-19',7550.50,1050.00),
(110,'Piotr','Komputerik',10,40,40,'1980-05-01',6100.00,1000.00),
(120,'Maria','Elmecka',20,40,50,'1979-06-03',6200.00,900.00),
(130,'Dariusz','Drzewołaz',30,40,60,'1981-07-05',6300.00,800.00),
(140,'Cecylia','Kobiecka',40,40,70,'1976-01-07',6400.00,700.00),
(150,'Leopold','Banko',50,40,80,'1974-02-09',6500.00,600.00),
(160,'Zofia','Otwarty',60,40,90,'1978-03-11',6600.00,500.00),
(170,'Adam','Euforik',70,40,100,'1983-04-01',6700.00,400.00),
(210,'Michał','Komórczak',10,50,110,'1976-11-02',5190.00,950.00),
(220,'Mirosława','Ekspresik',20,50,120,'1982-01-16',5240.00,650.00),
(230,'Dariusz','Googlarz',30,50,130,'1988-08-02',5390.00,660.00),
(240,'Milena','Zgłoska',40,50,140,'1984-03-03',5430.00,550.00),
(250,'Łukasz','Więcej',50,50,150,'1987-10-07',5720.00,550.00),
(260,'Karol','Widział',60,50,160,'1980-04-14',5480.00,450.00),
(270,'Arnold','Vipowiak',70,50,170,'1977-12-17',5990.00,450.00),
(310,'Milena','Akcja',10,60,110,'1980-04-14',4250.10,450.00),
(320,'Makary','Zerownik',10,60,110,'1972-11-26',4260.20,450.00),
(330,'Eugeniusz','Reniczak',10,60,110,'1987-12-22',4260.50,450.00),
(340,'Piotr','Masterarz',20,60,120,'1981-04-04',4250.10,470.00),
(350,'Aniela','Slejczuk',20,60,120,'1981-11-17',4300.00,470.00),
(360,'Eugenia','Portalik',20,60,120,'1979-11-04',4300.00,470.00),
(370,'Olek','Ofisiak',30,60,130,'1984-04-05',4250.00,410.00),
(380,'Bartek','Amazonik',30,60,130,'1985-01-10',4250.00,410.00),
(390,'Grzegorz','Wyboruk',30,60,130,'1980-02-03',4250.00,450.00),
(400,'Adam','Seoczuk',40,60,140,'1977-05-15',4500.00,500.00),
(410,'Leokadia','Takowiak',40,60,140,'1978-09-09',4300.00,470.00),
(420,'Sergiusz','Bezpłatny',40,60,140,'1976-09-08',4351.10,400.00),
(430,'Emilia','Najpierwsza',50,60,150,'1986-11-12',4200.00,450.00),
(440,'Waldemar','Niezawodny',50,60,150,'1973-06-14',4700.00,400.00),
(450,'Walenty','Ugięty',60,60,160,'1987-07-17',4200.00,450.00),
(460,'Barbara','Niezbędna',70,60,170,'1980-07-18',4480.00,460.00),
(500,'Lucjusz','Szukaj',20,70,120,'1990-02-11',3000.00,100.00),
(510,'Mira','Polaros',30,70,130,'1989-10-16',3100.00,150.00),
(520,'Kaja','Naturalna',40,70,140,'1988-09-02',3100.00,150.00),
(530,'Julian','Zdziwiony',50,70,150,'1987-03-19',3200.00,200.00);

