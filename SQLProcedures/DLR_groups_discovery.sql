/****** Script for viewing hierarchy of groups  ******/

/*** Top Level ***/
SELECT *
  FROM [General_LR4].[dbo].[Groups] WHERE [ParentID] IS NULL

/*** Second Level ***/
SELECT *
  FROM [General_LR4].[dbo].[Groups] WHERE [ParentID] IN
  (SELECT GroupID FROM  [General_LR4].[dbo].[Groups] WHERE [ParentID] IS NULL)

/*** Third Level ***/
SELECT *
  FROM [General_LR4].[dbo].[Groups] WHERE [ParentID] IN
  (SELECT GroupID FROM  [General_LR4].[dbo].[Groups] WHERE [ParentID] IN
   (SELECT GroupID FROM  [General_LR4].[dbo].[Groups] WHERE [ParentID] IS NULL))
   ORDER BY ParentID, GroupName 

/*** Fourth Level ***/
SELECT *
  FROM [General_LR4].[dbo].[Groups] WHERE [ParentID] IN
  (SELECT GroupID FROM  [General_LR4].[dbo].[Groups] WHERE [ParentID] IN
   (SELECT GroupID FROM  [General_LR4].[dbo].[Groups] WHERE [ParentID] IN
    (SELECT GroupID FROM  [General_LR4].[dbo].[Groups] WHERE [ParentID] IS NULL)))
   ORDER BY ParentID, GroupName 

-- create variable to list all project years 
DECLARE @ProjectYears TABLE (GroupID int, GroupName varchar(50), Description varchar(100))
INSERT INTO @ProjectYears(GroupID, GroupName, Description)
	SELECT GroupID, GroupName, Description
		FROM [General_LR4].[dbo].[Groups] WHERE [ParentID] IN
		(SELECT GroupID FROM  [General_LR4].[dbo].[Groups] WHERE [ParentID] IN
		(SELECT GroupID FROM  [General_LR4].[dbo].[Groups] WHERE [ParentID] IS NULL))

-- create variable to summarise site count per year
DECLARE @SiteSummary TABLE (ParentID int, SiteCount int)
INSERT INTO @SiteSummary
	SELECT [General_LR4].[dbo].[Groups].ParentID, COUNT([General_LR4].[dbo].[Groups].ParentID) AS SiteCount 
	FROM [General_LR4].[dbo].[Groups]
	GROUP BY ParentID

/*** Summarise number of sites monitored over all years of programme for the South Africa DLR Project ***/
DECLARE @YearSummary TABLE (GroupID int, GroupName varchar(50), Description varchar(50), SiteCount int)
INSERT INTO @YearSummary
	SELECT GroupID, GroupName, Description, SiteCount FROM @ProjectYears p
	LEFT JOIN @SiteSummary
	ON p.GroupID=[@SiteSummary].ParentID
	WHERE GroupID != 90 AND GroupID != 91 AND GroupID != 92
	ORDER BY GroupName, GroupID
SELECT GroupName, SUM(SiteCount) FROM @YearSummary GROUP BY GroupName
SELECT SUM(SiteCount) FROM @YearSummary

/*** Summarise number of sites monitored over all years of programme for the Namibian DLR Project ***/
DECLARE @NamibiaSummary TABLE (GroupID int, GroupName varchar(50), Description varchar(50), SiteCount int)
INSERT INTO @NamibiaSummary
	SELECT GroupID, GroupName, Description, SiteCount FROM @ProjectYears p
	LEFT JOIN @SiteSummary
	ON p.GroupID=[@SiteSummary].ParentID
	WHERE GroupID = 90 OR GroupID = 91 OR GroupID = 92
	ORDER BY GroupName, GroupID
SELECT GroupName, SUM(SiteCount) AS SiteCount FROM @NamibiaSummary GROUP BY GroupName
SELECT SUM(SiteCount) FROM @NamibiaSummary