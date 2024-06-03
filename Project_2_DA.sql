USE AdventureWorks2022
go

--q 1 Done

SELECT p.ProductID, [Name], Color, ListPrice, Size
FROM Production.product p
WHERE p.productID NOT IN (SELECT sod.productID
						  FROM Sales.SalesOrderDetail sod)
ORDER BY ProductID

--q 2 "Done", according to the first version of the question, and shows why it is inconsistent
go
--this option shows that customerid 1-701 do not have any sales orders, as requested, but no names in person, 701 rows as requested
select c.customerid, soh.salesorderid, PersonID, ISNULL(Firstname, 'Unknown'), ISNULL(Lastname,'Unknown')
from sales.customer c
left Join sales.salesorderheader soh
ON c.customerid=soh.customerid
left join Person.Person p
on c.PersonID=p.BusinessEntityID
where soh.SalesOrderID IS NULL
order by CustomerID

--This option starts from person.person. So, you get the names as they are in the solution, but none of the names are actually customers. Also, 853 rows
SELECT p.BusinessEntityID,LastName,FirstName
FROM Person.Person p
LEFT OUTER JOIN sales.Customer c
ON p.BusinessEntityID=c.PersonID
WHERE PersonID IS NULL
ORDER BY p.BusinessEntityID

--q 3 Done

SELECT TOP 10 sod.CustomerID, FirstName, LastName
, COUNT(sod.CustomerID)AS CountOfOrders
FROM Sales.SalesOrderHeader sod
JOIN Sales.Customer c
ON sod.CustomerID=c.CustomerID
JOIN Person.Person p
ON c.PersonID=p.BusinessEntityID
GROUP BY sod.CustomerID, FirstName, LastName
ORDER BY CountOfOrders DESC

--q 4 Done
SELECT FirstName,LastName,JobTitle,HireDate
,(
SELECT COUNT(JobTitle) 
		FROM HumanResources.Employee emp
		WHERE emp.JobTitle=e.JobTitle
		) AS CountOfTitle
FROM HumanResources.Employee e
JOIN Person.Person p
ON e.BusinessEntityID=p.BusinessEntityID
GROUP BY JobTitle, e.BusinessEntityID, FirstName,LastName,JobTitle,HireDate
ORDER BY JobTitle

--q 5 Done
go

SELECT SalesOrderID
	,CustomerID
	,LastName
	,FirstName
	,LastOrder
	,PreviousOrder
FROM
(
	SELECT SalesOrderID
	, soh.CustomerID AS CustomerID
	,LastName
	,FirstName
	, OrderDate AS LastOrder
	,LAG(OrderDate,1)OVER(Partition by soh.customerid order by OrderDate) AS PreviousOrder
	, Row_number()OVER(partition by soh.customerid ORDER BY OrderDate desc) AS RN
	FROM Sales.SalesOrderHeader soh
	JOIN Sales.Customer c
	ON soh.CustomerID=c.CustomerID
	JOIN Person.Person p
	ON c.PersonID=p.BusinessEntityID
)s
WHERE s.RN =1
		
--q 6 Done

go

WITH tbl AS
(
    SELECT 
        Year(OrderDate) AS OrderYear
        ,sod.SalesOrderID AS SalesOrderID
		,LastName
		,FirstName
	    ,SUM(UnitPrice * (1 - UnitPriceDiscount) * OrderQty)OVER(partition by sod.salesorderid Order BY YEAR(OrderDate)) AS Total
    FROM
        Sales.SalesOrderDetail sod
		JOIN Sales.SalesOrderHeader soh
	ON sod.SalesOrderID=soh.SalesOrderID
	JOIN Sales.Customer c
	ON soh.CustomerID=c.CustomerID
	JOIN Person.Person p
	ON c.PersonID=p.BusinessEntityID
)
SELECT  OrderYear
    ,SalesOrderID
	,LastName
	,FirstName
	,FORMAT(Total,'#,#.0') AS Total
FROM
(
SELECT 
    OrderYear
    ,SalesOrderID
	,LastName
	,FirstName
	,Total
	,ROW_NUMBER() OVER (PARTITION BY OrderYear ORDER BY Total DESC) AS RN

FROM
    tbl)s
WHERE RN=1
ORDER BY OrderYear


--q 7 Done
SELECT Month, [2011],[2012],[2013],[2014]
FROM
	(SELECT YEAR(OrderDate) AS Year ,MONTH(OrderDate) AS Month, SalesOrderID
	FROM Sales.SalesOrderHeader)s
PIVOT
(COUNT (SalesOrderID) FOR YEAR IN ([2011],[2012],[2013],[2014])) as pvt
ORDER BY MONTH


--q 8 Done

go
With A AS
(
    SELECT YEAR(OrderDate) AS Year
	, CAST(MONTH(OrderDate) AS varchar) AS Month
	, CAST(SUM(UnitPrice*OrderQty) AS Decimal(25,2)) AS SumPrice
	,CAST(SUM(SUM(unitprice*OrderQty))OVER(partition by year(orderdate) Order by month(orderDate)) AS decimal(10,2)) AS CumSum
	,0 AS SortOrder
	FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
	GROUP BY YEAR(OrderDate), MONTH(OrderDate)),
B AS
(
	SELECT DISTINCT Year(OrderDate) AS year
	,'GrandTotal' AS Month
	,NULL as SumPrice
	,CAST(SUM(unitprice*OrderQty) AS decimal(10,2)) AS CumSum
	,1 AS SortOrder
	FROM Sales.SalesOrderHeader soh1
    JOIN Sales.SalesOrderDetail sod1 ON soh1.SalesOrderID = sod1.SalesOrderID
	group by YEAR(OrderDate)
	)
SELECT Year, Month, SumPrice, CumSum
FROM (
    SELECT * FROM A
    UNION ALL
    SELECT * FROM B
) AS Combined
	ORDER BY Combined.Year
	,Combined.SortOrder
    

go

--q 9 Done
go

WITH Seniority
AS
(
SELECT d.Name AS DepartmentName
,e.BusinessEntityID AS EmployeeID
,FirstName
,LastName
,CONCAT_WS(' ',FirstName,LastName) AS EmpFullName
,HireDate
,DATEDIFF(MM,HireDate,GETDATE()) AS Seniority
,LAG(HireDate,1)OVER(partition by d.name order by hiredate) AS PrevEmpHDate
FROM HumanResources.Employee e
JOIN HumanResources.EmployeeDepartmentHistory edh
ON e.BusinessEntityID=edh.BusinessEntityID
JOIN HumanResources.Department d
ON edh.DepartmentID=d.DepartmentID
JOIN Person.person p
ON e.BusinessEntityID=p.BusinessEntityID
)
SELECT DepartmentName
,EmployeeID
,EmpFullName
,HireDate
,Seniority
,(
select TOP 1 CONCAT_WS(' ',s1.FirstName,s1.LastName) FROM Seniority s1
WHERE s1.HireDate = s.PrevEmpHDate ORDER BY s1.EmployeeID DESC
) AS PreviousEmpName 
,PrevEmpHDate
,DATEDIFF(Day,PrevEmpHDate, HireDate) AS DiffDays
FROM Seniority s
ORDER BY departmentname, Seniority asc, Hiredate desc


--10 Done
go

SELECT DISTINCT e.HireDate
, edh.DepartmentID
,STUFF((SELECT DISTINCT CONCAT_WS(' ',',',CAST(e1.BusinessEntityID AS varchar),LastName,FirstName)
		FROM HumanResources.Employee e1
		JOIN HumanResources.EmployeeDepartmentHistory edh1
		ON e1.BusinessEntityID=edh1.BusinessEntityID
		JOIN Person.Person p1
		On edh1.BusinessEntityID=p1.BusinessEntityID
		WHERE edh1.DepartmentID=edh.departmentID AND e1.hiredate=e.hiredate AND
		EndDate IS NULL
		FOR XML Path('')),1,1,'') AS TeamEmployees

FROM HumanResources.Employee e
JOIN HumanResources.EmployeeDepartmentHistory edh
ON e.BusinessEntityID=edh.BusinessEntityID
JOIN Person.Person p
On edh.BusinessEntityID=p.BusinessEntityID
WHERE edh.EndDate is null
Order by HireDate desc
