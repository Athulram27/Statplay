USE [BUDT703_Project_0507_03]

GO
DROP VIEW IF EXISTS ScoreResultView
GO
GO
CREATE VIEW ScoreResultView AS	
	SELECT *,
	(CASE WHEN s.scoreMd>s.scoreOpp THEN  1 ELSE 0 END ) AS Result,
	(CASE WHEN s.scoreMd>s.scoreOpp THEN  'Win'
		  WHEN s.scoreMd<s.scoreOpp THEN  'Loss'
		  WHEN s.scoreMd=s.scoreOpp THEN  'Draw' END
	) AS ResultType,
	s.scoreMd-s.scoreOpp AS 'Score Margin'
	FROM Score s

GO

GO
DROP VIEW IF EXISTS CalendarSeasonView
GO
GO
CREATE VIEW CalendarSeasonView AS
	SELECT *, 
	(CASE WHEN c.calMonth IN (1,2,12) THEN 'Winter'
		  WHEN c.calMonth IN (3,4,5) THEN 'Spring'
		  WHEN c.calMonth IN (6,7,8) THEN 'Summer'
		  ELSE 'Fall' END
	) AS Seasons
	FROM Calendar c
GO



--1.  Which stadiums does Maryland team have the best winrate against, at away games in Spring season? 

SELECT st.stdCity AS 'Stadium Name',
	CONCAT(CAST((SUM(s.Result)*1.0/COUNT(s.Result)*1.0)*100 AS DECIMAL(10,1)),'%') AS 'Stadium Winrate', 
	COUNT(s.Result) AS 'Total Matches'
	FROM ScoreResultView s
	JOIN Locate l ON s.scoreId = l.scoreId
	JOIN Stadium st ON st.stdId = l.stdId
	JOIN Match m ON m.scoreId = l.scoreId
	JOIN CalendarSeasonView c ON c.calYear+c.calMonth = m.calYear+m.calMonth
	WHERE c.Seasons = 'Spring' 	AND  l.stdId != 'S02'
	GROUP BY st.stdCity, st.stdState
	HAVING COUNT(s.Result) >=10 
	AND CAST(SUM(s.Result)*1.0/COUNT(s.Result)*1.0 AS DECIMAL(10,2)) >= 0.50
	ORDER BY 'Total Matches' DESC,'Stadium Winrate' DESC
	

--2. Which teams does Maryland team have the best winrate against, at home games?

SELECT o.oppName AS 'Opponent Name', 
	CONCAT(CAST((SUM(s.Result)*1.0/COUNT(s.Result)*1.0)*100 AS DECIMAL(10,1)),'%') AS 'Winrate against Opponent', 
	COUNT(s.Result) AS 'Total Matches'
	FROM ScoreResultView s
	JOIN Locate l ON s.scoreId = l.scoreId
	JOIN Match m ON m.scoreId = l.scoreId
	JOIN Opponent o ON o.oppId = l.oppId
	WHERE  l.stdId = 'S02' -- S02 is Maryland stadium ID
	GROUP BY o.oppName
	HAVING COUNT(s.Result)>=10
	ORDER BY 'Total Matches' DESC,'Winrate against Opponent' DESC

--3. What is the overall win/loss/draw rate

SELECT s.ResultType AS 'Result Type', 
		COUNT(s.ResultType) AS 'Number of games',
		(SELECT COUNT(s.ResultType) FROM ScoreResultView s WHERE s.ResultType IN ('Win', 'Loss', 'Draw')) AS 'Total Games Played',
		CONCAT(CAST((COUNT(s.ResultType)*1.0/
			(	SELECT COUNT(s.ResultType)*1.00 
				FROM ScoreResultView s 
				WHERE s.ResultType IN ('Win', 'Loss', 'Draw')
			))*100 AS DECIMAL(10,1)),'%') AS 'Win Loss Draw %'
		FROM ScoreResultView s
		GROUP BY s.ResultType
		HAVING s.ResultType IS NOT NULL


--4. What is the winrate in Spring and Winter
SELECT c.Seasons , 
	CONCAT(CAST(sum(s.Result)*1.0/count(s.Result)*1.0 *100 AS DECIMAL(10,1)),'%') AS 'Winrate against Opponent'
	FROM CalendarSeasonView c
	JOIN Match m ON m.calYear+m.calMonth = c.calYear+c.calMonth
	JOIN ScoreResultView s ON s.scoreId = m.scoreId
	GROUP BY c.Seasons


--5. Top 10 Opponents and their average score margin

SELECT TOP 10 o.oppName AS 'Opponent Name', 
	CAST(AVG(CAST (scoreMd - scoreOpp AS DECIMAL(10,2))) AS DECIMAL(10,1) )AS 'Score Margin'
	FROM ScoreResultView s
	JOIN Locate l ON s.scoreId = l.scoreId
	JOIN Match m ON m.scoreId = l.scoreId
	JOIN Opponent o ON o.oppId = l.oppId
	GROUP BY o.oppName
	ORDER BY AVG(scoreMd - scoreOpp) DESC


--6. What is the yearly trend for the Winrate? 
SELECT calYear, CONCAT(CAST(sum(s.Result)*1.0/count(s.Result)*1.0 *100 AS DECIMAL(10,1)),'%') AS 'Winrate'
		FROM ScoreResultView s 
		JOIN Match m ON s.scoreId = m.scoreId
		GROUP BY m.calYear
		ORDER BY calYear DESC

--7.  How did Maryland team performance against each opponent? 
SELECT TOP 30 o.oppName, CONCAT(CAST(sum(s.Result)*1.0/count(s.Result)*1.0 *100 AS DECIMAL(10,1)),'%') AS 'Opponent Winrate'
	FROM Opponent o
	JOIN match m ON m.oppId = o.oppId
	JOIN ScoreResultView s ON s.scoreId = m.scoreId
	GROUP BY o.oppName
	HAVING count(s.Result) >=10
	ORDER BY sum(s.Result)*1.0/count(s.Result)*1.0 DESC

--8. How is the Performance of all coaches based on the overall winrate across the years?
SELECT ca.calYear AS 'Calendar Year', co.coachLastName AS 'Coach Last Name', co.coachFirstName AS 'Coach First Name'
, CONCAT(CAST(sum(s.Result)*1.0/count(s.Result)*1.0 *100 AS DECIMAL(10,1)),'%')  AS 'Win Rate under Coach'
FROM Match m
JOIN Calendar ca ON ca.calYear+ca.calMonth = m.calYear+m.calMonth
JOIN ScoreResultView s ON m.scoreId = s.scoreId
JOIN Coach co ON co.coachId = Ca.coachId
GROUP BY ca.calYear, co.coachLastName, co.coachFirstName
ORDER BY ca.calYear



--9.  State with maximum number of stadiums

SELECT st.stdState AS 'Stadium State',
	COUNT(DISTINCT st.stdId) AS 'Total Stadiums'
	FROM ScoreResultView s
	JOIN Locate l ON s.scoreId = l.scoreId
	JOIN Stadium st ON st.stdId = l.stdId
	JOIN Match m ON m.scoreId = l.scoreId
	JOIN CalendarSeasonView c ON c.calYear+c.calMonth = m.calYear+m.calMonth
	GROUP BY st.stdState
	ORDER BY COUNT(DISTINCT st.stdId) DESC



