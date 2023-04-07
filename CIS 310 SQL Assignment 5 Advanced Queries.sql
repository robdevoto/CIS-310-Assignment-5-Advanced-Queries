-- Rob DeVoto
--CIS 310
--Assignment 5 Advanced Queries- the Bike database was too large for professor to give us file
--Fall 2022

USE BIKE;

--1. List the customers from California who bought red mountain bikes in September 2003. Use the order date as the date bought.
SELECT C.CUSTOMERID, C.LASTNAME, C.FIRSTNAME, B.MODELTYPE, P.COLORLIST, B.OrderDate, B.SALESTATE
FROM CUSTOMER C INNER JOIN BICYCLE B ON C.CustomerID = B.CUSTOMERID INNER JOIN PAINT P ON P.PaintID = B.PaintID
WHERE B.SALESTATE= 'CA' AND P.COLORLIST= 'RED' 
	AND  B.ORDERDATE BETWEEN '2003-09-01' AND '2003-09-30'

--2. List the employees who sold race bikes shipped to Wisconsin without the help of a retail store in 2001
SELECT E.EMPLOYEEID, E.LASTNAME, B.SALESTATE,B.MODELTYPE, B.STOREID, B.ORDERDATE 
FROM EMPLOYEE E INNER JOIN BICYCLE B ON E.EmployeeID=B.EmployeeID
WHERE B.SALESTATE= 'WI' AND B.ModelType='RACE' AND YEAR (B.ORDERDATE)='2001' AND StoreID IN ('1', '2', null)

--3. List all of the (distinct) rear derailleurs installed on road bikes sold in Florida in 2002.
SELECT DISTINCT C.COMPONENTID, M.MANUFACTURERNAME, C.PRODUCTNUMBER
FROM COMPONENT C INNER JOIN MANUFACTURER M ON C.MANUFACTURERID= M.ManufacturerID 
INNER JOIN BIKEPARTS BP ON C.COMPONENTID = BP.ComponentID
INNER JOIN BICYCLE B ON BP.SERIALNUMBER= B.SERIALNUMBER
WHERE B.MODELTYPE= 'ROAD' AND YEAR (B.ORDERDATE) = '2002' AND B.SALESTATE= 'FL' AND C.CATEGORY= 'REAR DERAILLEUR'

--4. Who bought the largest (frame size) full suspension mountain bike sold in Georgia in 2004?
SELECT B.CUSTOMERID,C.LASTNAME,C.FIRSTNAME,B.MODELTYPE,B.SALESTATE,B.FRAMESIZE,B.ORDERDATE
FROM BICYCLE B INNER JOIN CUSTOMER C ON C.CUSTOMERID=B.CUSTOMERID
WHERE B.MODELTYPE= 'MOUNTAIN FULL' AND B.SALESTATE= 'GA' AND YEAR (B.ORDERDATE)=2004 AND FRAMESIZE = 
	(SELECT MAX(FRAMESIZE) 
	 FROM BICYCLE 
		WHERE MODELTYPE='MOUNTAIN FULL' AND SALESTATE='GA' AND YEAR(ORDERDATE) = '2004')

--5. Which manufacturer gave us the largest discount on an order in 2003?
SELECT M.MANUFACTURERNAME, P.MANUFACTURERID
FROM MANUFACTURER M INNER JOIN PURCHASEORDER P ON M.MANUFACTURERID = P.MANUFACTURERID
	WHERE YEAR (P.ORDERDATE)= '2003' AND DISCOUNT = 
		(SELECT MAX( DISCOUNT) FROM PURCHASEORDER WHERE YEAR (ORDERDATE) = 2003)


--6. What is the most expensive road bike component we stock that has a quantity on hand greater than 200 units?
SELECT TOP 1 COMPONENTID, MANUFACTURER.MANUFACTURERNAME,  PRODUCTNUMBER, ROAD, CATEGORY, LISTPRICE, QUANTITYONHAND
FROM COMPONENT
INNER JOIN MANUFACTURER ON COMPONENT.MANUFACTURERID= MANUFACTURER.MANUFACTURERID
WHERE QUANTITYONHAND > 200
ORDER BY LISTPRICE DESC;

--7. Which inventory item represents the most money sitting on the shelf—based on estimated cost?
SELECT TOP 1 C.COMPONENTID, M.MANUFACTURERNAME, C.PRODUCTNUMBER, C.CATEGORY, C.YEAR, (C.ESTIMATEDCOST) AS VALUE
FROM COMPONENT C
INNER JOIN MANUFACTURER M ON C.MANUFACTURERID=M.MANUFACTURERID
ORDER BY VALUE DESC;

 
--8. What is the greatest number of components ever installed in one day by one employee?
SELECT COUNT (BP.COMPONENTID) AS COUNTOFCOMPONENTID, e.EmployeeID
FROM EMPLOYEE e INNER JOIN BIKEPARTS BP ON e.EMPLOYEEID = BP.EMPLOYEEID
Group By e.EmployeeID
ORDER BY COUNTOFCOMPONENTID DESC
;
--, e.LastName, BP.DATEINSTALLED, 


--9. What was the most popular letter style on race bikes in 2003?
SELECT TOP 1 LETTERSTYLEID, COUNT(LETTERSTYLEID) AS COUNTOFSERIALNUMBER
FROM  BICYCLE
WHERE ORDERDATE LIKE '%2003%' AND MODELTYPE= 'RACE'
GROUP BY LETTERSTYLEID
ORDER BY COUNTOFSERIALNUMBER DESC;

 
--10. Which customer spent the most money with us and how many bicycles did that person buy in 2002?
SELECT TOP 1 CUSTOMER.CUSTOMERID, LASTNAME, FIRSTNAME, COUNT(BICYCLE.SERIALNUMBER) AS NUMBEROFBIKES, SUM(CUSTOMERTRANSACTION.AMOUNT) AS AMOUNTSPENT
FROM CUSTOMER
INNER JOIN BICYCLE ON CUSTOMER.CUSTOMERID=BICYCLE.CUSTOMERID
INNER JOIN CUSTOMERTRANSACTION ON CUSTOMER.CUSTOMERID=CUSTOMERTRANSACTION.CUSTOMERID
WHERE CUSTOMERTRANSACTION.TRANSACTIONDATE LIKE '%2002%'
GROUP BY CUSTOMER.CUSTOMERID, LASTNAME, FIRSTNAME
ORDER BY AMOUNTSPENT DESC;


--11. Have the sales of mountain bikes (full suspension or hard tail) increased or decreased from 2000 to 2004 (by count not by value)?
 --You will list the number sold by year in descending order. 
SELECT YEAR(ORDERDATE) AS [SALEYEAR], COUNT(SERIALNUMBER)
 AS COUNTOFSERIALNUMBER FROM BICYCLE 
WHERE YEAR(ORDERDATE) >= 2000 
AND YEAR(ORDERDATE) <= 2004 
AND (MODELTYPE = 'MOUNTAIN FULL' OR MODELTYPE = 'MOUNTAIN') 
GROUP BY YEAR(ORDERDATE) 
ORDER BY SALEYEAR DESC

--12.Which component did the company spend the most money on in 2003? 
SELECT C.COMPONENTID, M.MANUFACTURERNAME, C.PRODUCTNUMBER, C.CATEGORY, P.PRICEPAID 
AS [VALUE] 
FROM PURCHASEORDER PO INNER JOIN PURCHASEITEM P ON PO.PURCHASEID = P.PURCHASEID INNER JOIN COMPONENT C 
ON P.COMPONENTID = C.COMPONENTID INNER JOIN MANUFACTURER M 
ON C.MANUFACTURERID = M.MANUFACTURERID 
	WHERE YEAR(PO.ORDERDATE) = '2003' 
AND P.PRICEPAID = (SELECT MAX(P.PRICEPAID)
					FROM PURCHASEITEM P INNER JOIN PURCHASEORDER PO 
					ON P.PURCHASEID = PO.PURCHASEID 
					WHERE YEAR(PO.ORDERDATE) = '2003');


--13. Which employee painted the most red race bikes in May 2003? 

SELECT E.EMPLOYEEID, E.LASTNAME, COUNT(SERIALNUMBER) 
AS NUMBERPAINTED 
FROM PAINT P INNER JOIN BICYCLE B 
ON P.PAINTID = B.PAINTID INNER JOIN EMPLOYEE E 
ON B.EMPLOYEEID = E.EMPLOYEEID 
WHERE YEAR(ORDERDATE) = '2003' AND MODELTYPE = 'RACE' 
AND MONTH(ORDERDATE) = '5' AND P.COLORLIST = 'RED' 
GROUP BY E.EMPLOYEEID, E.LASTNAME 
ORDER BY COUNT(SERIALNUMBER);


--14. Which California bike shop helped sell the most bikes (by value) in 2003? 
SELECT TOP 1 STOREID 
FROM BICYCLE B INNER JOIN CUSTOMERTRANSACTION CT 
ON B.EMPLOYEEID = CT.EMPLOYEEID 
WHERE YEAR(ORDERDATE) = 2003 AND SALESTATE = 'CA' 
AND B.SALEPRICE > '0' 
GROUP BY STOREID 
ORDER BY SUM(B.SALEPRICE); 

--15. What is the total weight of the components on bicycle 11356?

SELECT SUM(C.WEIGHT) AS TOTALWEIGHT
FROM BIKEPARTS B INNER JOIN COMPONENT C ON B.COMPONENTID = C.COMPONENTID 
WHERE B.SERIALNUMBER = '11356';


--16.    What is the total list price of all items in the 2002 Campy Record groupo?
--   	 GroupName    SumOfListPrice
SELECT GROUPNAME, SUM(LISTPRICE) AS SumOfListPrice
FROM GROUPO G INNER JOIN GROUPCOMPONENTS GC
    ON G.COMPONENTGROUPID = GC.GROUPID
    INNER JOIN COMPONENT C
    ON GC.COMPONENTID = C.COMPONENTID
WHERE G.YEAR = 2002 AND (GROUPNAME LIKE '%Campy Record%')
GROUP BY GROUPNAME, G.YEAR;


--17.    In 2003, were more race bikes built from carbon or titanium (based on the down tube)?
--   	 Note: As output you may show the number of bikes for both materials. Use OrderDate.
--   	 Material    CountOfSerialNumber
SELECT MATERIAL, COUNT(B.SERIALNUMBER) AS CountOfSerialNumber
FROM BICYCLE B INNER JOIN BICYCLETUBEUSAGE BTU
    ON B.SERIALNUMBER = BTU.SERIALNUMBER
    INNER JOIN TUBEMATERIAL TM
    ON BTU.TUBEID = TM.TUBEID
WHERE ORDERDATE BETWEEN '2003-01-01' AND '2003-12-31'
    AND MODELTYPE = 'RACE'
    AND (MATERIAL LIKE 'Carbon%' OR MATERIAL = 'Titanium')
GROUP BY MODELTYPE, MATERIAL;


--18.    What is the average price paid for the 2001 Shimano XTR rear derailleurs?
--   	 AvgOfPricePaid
SELECT AVG(PRICEPAID) AS AvgOfPricePaid
FROM MANUFACTURER M INNER JOIN COMPONENT C
    ON M.MANUFACTURERID = C.MANUFACTURERID
    INNER JOIN PURCHASEITEM P
    ON P.COMPONENTID = C.COMPONENTID
WHERE DESCRIPTION LIKE '%XTR%'
    AND M.MANUFACTURERNAME LIKE '%Shimano%'
    AND YEAR = 2001
    AND CATEGORY = 'Rear derailleur'
GROUP BY M.MANUFACTURERNAME, YEAR, CATEGORY, DESCRIPTION;


--19.    What is the average top tube length for a 54 cm (frame size) road bike built in 1999?
--   	 AvgOfTopTube
SELECT AVG(MS.TOPTUBE) AS AvgOfTopTube
FROM BICYCLE B INNER JOIN MODELTYPE MT
    ON B.MODELTYPE = MT.MODELTYPE
    INNER JOIN MODELSIZE MS
    ON MT.MODELTYPE = MS.MODELTYPE
WHERE B.MODELTYPE = 'Road'
    AND StartDate BETWEEN '1999-01-01' AND '1999-12-31'
    AND FRAMESIZE = 54
GROUP BY B.MODELTYPE, FRAMESIZE;


--20.    On average, which costs (list price) more: road tires or mountain bike tires?
--   	 Road    AvgOfListPrice
SELECT ROAD, AVG(LISTPRICE) AS AvgOfListPrice
FROM COMPONENT
WHERE CATEGORY = 'TIRE'
GROUP BY ROAD;




--21. 
SELECT B.EmployeeID, E.LastName
FROM EMPLOYEE E inner join BICYCLE B on E.EmployeeID = B.EmployeeID
	WHERE YEAR(OrderDate) = '2003'
		AND MONTH (OrderDate) = '5'
		AND PAINTER = B.EmployeeID 
		AND ModelType = 'Road'

--22.
	SELECT P.PaintID, P.ColorName, COUNT(B.SerialNumber) as NumberBikesPainted
	From Paint P inner join Bicycle B on P.PaintID = B.PaintID
	inner join LetterStyle LS on B.LetterStyleID = LS.LetterStyle
		Where B.LetterStyleID Like 'English' And YEAR(OrderDate) = '2002'
	Group By P.PaintID, P.ColorName

--23. Which race bikes in 2003 sold for more than the average price of race bikes in 2002? 
--SerialNumber  ModelType  OrderDate  SalePrice
Select SerialNumber, ModelType, OrderDate, SalePrice
	From Bicycle B 
	Where B.ModelType = 'Race'
	And YEAR(B.OrderDate) = '2003'
	And B.SalePrice > (
		Select AVG(SALEPRICE)
		From Bicycle
		Where ModelType = 'Race'
		And YEAR(B.OrderDate) = '2003')
 
--24. Which component that had no sales (installations) in 2004 has the highest inventory value (cost basis)?
--ManufacturerName ProductNumber Category Value ComponentID
SELECT TOP 1 M.MANUFACTURERNAME, C.PRODUCTNUMBER, C.CATEGORY, SUM(C.LISTPRICE * C.QUANTITYONHAND) AS AMT, BP.DATEINSTALLED 
FROM MANUFACTURER M INNER JOIN COMPONENT C  ON C.MANUFACTURERID = M.MANUFACTURERID 
INNER JOIN BIKEPARTS BP ON C.COMPONENTID = BP.COMPONENTID
	WHERE YEAR(BP.DATEINSTALLED) NOT LIKE 2004
GROUP BY C.PRODUCTNUMBER, C.CATEGORY, M.MANUFACTURERNAME, BP.DATEINSTALLED 
ORDER BY SUM(C.LISTPRICE * C.QUANTITYONHAND)

 

--25.Create a vendor contacts list of all manufacturers and retail stores in California.
--Include only the columns for VendorName and Phone. 
--The retail stores should only include stores that participated in the sale of at least one bicycle in 2004
--Store Name Or Manufacturer Name Phone
SELECT	S.STORENAME, S.PHONE 
FROM RetailStoRE S INNER JOIN BICYCLE B ON B.STOREID = S.STOREID 
INNER JOIN CITY C ON C.CITYID = S.CityID
	WHERE	YEAR(B.ORDERDATE) = 2004 AND (C.STATE = 'CA' OR B.SALESTATE = 'CA')
GROUP BY S.StoreName, S.PHONE

	

--26. List all of the employees who report to Venetiaan.
--LastName, EmployeeID, LastName, FirstName, Title

Select (
	 Select LastName
	 From EMPLOYEE
	 Where EmployeeID = (
				 	Select EmployeeID
					From EMPLOYEE
					Where LastName = 'Venetiaan')) 
As LastName, EmployeeID, LastName, FirstName, Title
From EMPLOYEE
Where CurrentManager = (
				Select EmployeeID
				From EMPLOYEE
				Where LastName = 'Venetiaan')

--27. List the components where the company purchased at least 25 percent more units than it used through June 30, 2000. 
--An item is used if it has an install date.
--CREATE VIEW AS COMPONENT



--28 In which years did the average build time for the year exceed the overall average build time for all years?
-- The build time is the difference between order date and ship date.

Select Year(OrderDate) As 'Year', Avg (DateDiff(Day, OrderDate, ShipDate)) As 'Build Time'
From BICYCLE
Group By Year(OrderDate)
Having Avg(DateDiff(Day, OrderDate, ShipDate)) > 
(Select Avg(DateDiff(Day, OrderDate, ShipDate)) As 'Average'
	 From	 BICYCLE)
Order By Year(OrderDate)
