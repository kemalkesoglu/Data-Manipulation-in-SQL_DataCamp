--Filtering using scalar subqueries
SELECT 
    date,
	home_goal,
	away_goal
FROM  matches_2013_2014
WHERE (home_goal + away_goal) > 
       (SELECT 3 * AVG(home_goal + away_goal)
        FROM matches_2013_2014); 

--Filtering using a subquery with a list
SELECT 
	team_long_name,
	team_short_name
FROM team 
WHERE team_api_id NOT IN
     (SELECT DISTINCT hometeam_id  FROM match);

--Filtering with more complex subquery conditions
SELECT
	team_long_name,
	team_short_name
FROM team
WHERE team_api_id IN
	  (SELECT hometeam_id 
       FROM match
       WHERE home_goal >= 8);

--Joining Subqueries in FROM
SELECT
    c.name AS country_name,
    COUNT(sub.id) AS matches
FROM country AS c
INNER JOIN (SELECT country_id, id 
           FROM match
           WHERE (home_goal + away_goal) >= 10) AS sub
ON c.id = sub.country_id
GROUP BY country_name;

--Building on Subqueries in FROM
SELECT
    country,
    date,
    home_goal,
    away_goal
FROM 
	 (SELECT c.name AS country,
            m.date, 
     		m.home_goal, 
     		m.away_goal,
           (m.home_goal + m.away_goal) AS total_goals
    FROM match AS m
    LEFT JOIN country AS c
    ON m.country_id = c.id) AS subq
WHERE total_goals >=10;

--Add a subquery to the SELECT clause
SELECT 
	l.name AS league,
    ROUND(AVG(m.home_goal + m.away_goal), 2) AS avg_goals,
    (SELECT ROUND(AVG(home_goal + away_goal), 2) 
     FROM match
     WHERE season = '2013/2014') AS overall_avg
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
WHERE m.season = '2013/2014'
GROUP BY league;

--Subqueries in Select for Calculations
SELECT
	name AS league,
	ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
	ROUND(AVG(m.home_goal + m.away_goal) -
		(SELECT AVG(home_goal + away_goal)
		 FROM match 
         WHERE season = '2013/2014'),2) AS diff
FROM league AS l
LEFT JOIN match AS m
ON l.country_id = m.country_id
WHERE season = '2013/2014'
GROUP BY l.name;

--ALL the subqueries EVERYWHERE
SELECT 
	m.stage,
    ROUND(AVG(m.home_goal + m.away_goal),2) AS avg_goals,
    ROUND((SELECT AVG(home_goal + away_goal) 
           FROM match 
           WHERE season = '2012/2013'),2) AS overall
FROM match AS m
WHERE season = '2012/2013'
GROUP BY m.stage;

--Add a subquery in FROM
SELECT 
	stage,
	ROUND(avg_goals,2) AS avg_goals
FROM 
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE 
	s.avg_goals > (SELECT AVG(home_goal + away_goal) 
                    FROM match WHERE season = '2012/2013');

--Add a subquery in SELECT
SELECT 
	stage,
    ROUND(avg_goals,2) AS avg_goal,
    (SELECT AVG(home_goal + away_goal) FROM match WHERE season = '2012/2013') AS overall_avg
FROM 
	(SELECT
		 stage,
         AVG(home_goal + away_goal) AS avg_goals
	 FROM match
	 WHERE season = '2012/2013'
	 GROUP BY stage) AS s
WHERE 
	s.avg_goals > (SELECT AVG(home_goal + away_goal) 
                    FROM match WHERE season = '2012/2013');
