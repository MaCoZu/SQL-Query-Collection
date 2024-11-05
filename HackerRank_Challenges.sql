-- https://github.com/Thomas-George-T/HackerRank-SQL-Challenges-Solutions/blob/master/Basic%20Join/Challenges.sql
-- https://github.com/kumod007/All-HackerRank-SQL-Challenges-Solutions/tree/main/Aggregation

-- HACKER RANK 

-- Contest Leaderboard
SELECT a.hacker_id, b.name, SUM(a.score) AS total_score
FROM (SELECT hacker_id, challenge_id, MAX(score) AS score
    FROM Submissions
    GROUP BY hacker_id, challenge_id) a
    JOIN Hackers b ON a.hacker_id = b.hacker_id
GROUP BY a.hacker_id, b.name
HAVING total_score > 0
ORDER BY total_score DESC, hacker_id ASC

SELECT h.hacker_id, h.name, 
    SUM(s.score) AS total_score
FROM Hackers h JOIN max_scores s 
    ON h.hacker_id = s.hacker_id
GROUP BY h.hacker_id 

-- Weather Observation Station 17
SELECT ROUND(LONG_W, 4)
FROM Station
WHERE LAT_N = (SELECT MIN(LAT_N) FROM Station WHERE LAT_N > 38.7780);

-- Weather Observation Station 16
SELECT ROUND(MIN(LAT_N), 4)
FROM Station
WHERE LAT_N > 38.7780;

-- Weather Observation Station 15
SELECT ROUND(LONG_W, 4)
FROM Station
WHERE LAT_N = (SELECT MAX(LAT_N) FROM Station WHERE LAT_N < 137.2345);

-- Weather Observation Station 14
SELECT TRUNCATE(MAX(LAT_N), 4)
FROM Station
WHERE LAT_N < 137.2345;

-- Weather Observation Station 13
SELECT TRUNCATE(SUM(LAT_N), 4)
FROM Station
WHERE LAT_N > 38.7880 AND LAT_N < 137.2345;


-- Weather Observation Station 2
SELECT ROUND(SUM(LAT_N), 2), ROUND(SUM(LONG_W), 2)
FROM Station



-- Top Earners
SELECT months * salary as total_earnings, COUNT(*)
FROM Employee
GROUP BY total_earnings
ORDER BY total_earnings DESC
LIMIT 1;

-- The Blunder
SELECT CEIL(AVG(Salary) - AVG(REPLACE(Salary, '0', '')))
FROM Employees;

-- Revising Aggregations - Averages
SELECT AVG(Population)
FROM City
Where District= 'California';

-- The Sum function
SELECT SUM(Population)
FROM City
Where District= 'California';


-- The Count Function
SELECT COUNT(ID)
FROM CITY
WHERE Population > 100000;


-- Population Density Difference
SELECT MAX(Population) - MIN(Population) difference
FROM City;

-- Japan population
SELECT SUM(Population)
FROM City
WHERE Countrycode = 'JPN';

-- Average Population
SELECT ROUND(AVG(population),0)
FROM CITY;

-- Occupations
SELECT 
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM (
    SELECT 
        Name,
        Occupation,
        ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS rn
    FROM OCCUPATIONS
) AS sub
GROUP BY rn;


-- THE PADS
SELECT concat(name,'(',LEFT(Occupation,1),')') as Name 
FROM occupations 
ORDER BY Name;

SELECT CONCAT('There are a total of ', count(occupation), ' ',lower(occupation), 's.') as total
FROM occupations
GROUP BY occupation
ORDER BY count(occupation);


-- TYPE OF TRINAGLE
-- Equilateral: It's a triangle with 3 sides of equal length.
-- Isosceles: It's a triangle with 2 sides of equal length.
-- Scalene: It's a triangle with 3 sides of differing lengths.
-- Not A Triangle: The given values of A, B, and C don't form a triangle. A+B != C
SELECT 
CASE
    WHEN A + B <= C OR A + C <= B OR C + B <= A THEN 'Not A Triangle'
    WHEN A = B AND B = C THEN 'Equilateral'
    WHEN A = B OR B = C OR A = C THEN 'Isosceles'
    ELSE 'Scalene'
    END 
FROM TRIANGLES;

-- Write a query to print the hacker_id, name, and the total number of challenges created by each student. 
-- Sort by the total number of challenges in descending order. 
-- If more than one student created the same number of challenges, then sort the result by hacker_id. 
-- If more than one student created the same number of challenges and the count is less than the maximum number of challenges created, then exclude those students from the result.
-- The following tables contain challenge data:
-- Hackers: The hacker_id is the id of the hacker, and name is the name of the hacker. 
-- Challenges: The challenge_id is the id of the challenge, and hacker_id is the id of the student who 
SELECT h.hacker_id, h.name, COUNT(c.challenge_id) total_challenges
FROM Hackers h
    JOIN Challenges c ON h.hacker_id = c.hacker_id
GROUP BY h.hacker_id, h.name
HAVING total_challenges = (
        SELECT COUNT(c1.challenge_id) max_count
        FROM Challenges c1
        GROUP BY c1.hacker_id
        ORDER BY max_count DESC
        LIMIT 1 )
    OR total_challenges IN (
        SELECT inner_count
        FROM (
            SELECT h2.hacker_id, h2.name, COUNT(c2.challenge_id) inner_count
            FROM Hackers h2 JOIN Challenges c2 ON h2.hacker_id = c2.hacker_id
            GROUP BY h2.hacker_id, h2.name) temp
        GROUP BY inner_count
        HAVING COUNT(inner_count) = 1 )
ORDER BY total_challenges DESC, h.hacker_id ASC;






-- Find the wands with minimum number of gold galleons needed to buy each non-evil wand of high power and age
-- Write a query to print the id, age, coins_needed, and power of the wands that Ron's interested in, 
-- sorted in order of descending power. If more than one wand has same power, sort the result in order of descending age.
-- The following tables contain data on the wands in Ollivander's inventory:
-- Wands: The id is the id of the wand, code is the code of the wand, coins_needed is the total number of gold galleons needed to buy the wand, and power denotes the quality of the wand (the higher the power, the better the wand is).
-- Wands_Property: The code is the code of the wand, age is the age of the wand, and is_evil denotes whether the wand is good for the dark arts. 
-- If the value of is_evil is 0, it means that the wand is not evil. The mapping between code and age is one-one, meaning that if there are two pairs, 
-- (code1, age1) and (code2, age2), then code1 != code2 and age1 != age2.
SELECT w.id, p.age, w.coins_needed, w.power
FROM Wands w JOIN Wands_Property p ON w.code = p.code
WHERE p.is_evil = 0 
    -- coins needed should equal min of all wands with same age and power 
    AND w.coins_needed = (SELECT MIN(coins_needed) 
    FROM Wands w1 JOIN Wands_Property p1 ON w1.code = p1.code
    -- only consider wands that belong to the same age group as the one in the outer query,  
    -- effectively gets the cheapest from that group of same age and power
    WHERE p.age = p1.age AND w.power = w1.power)
ORDER BY w.power DESC, p.age DESC;


-- Write a query to print the respective hacker_id and name of hackers who achieved full scores for more than one challenge. Order your output in descending order by the total number of challenges in which the hacker earned a full score. If more than one hacker received full scores in same number of challenges, then sort them by ascending hacker_id.
-- The following tables contain contest data:
-- Hackers: hacker_id, name
-- Difficulty: difficult_level of the challenge, and score is the score of the challenge for the difficulty level.
-- Challenges: The challenge_id is the id of the challenge, the hacker_id is the id of the hacker who created the challenge, and difficulty_level is the level of difficulty of the challenge.
-- Submissions: The submission_id is the id of the submission, hacker_id is the id of the hacker who made the submission, challenge_id is the id of the challenge that the submission belongs to, and score is the score of the submission.
SELECT H.hacker_id, H.name
FROM submissions S
    JOIN challenges C ON S.challenge_id = C.challenge_id
    JOIN difficulty D ON C.difficulty_level = D.difficulty_level
    JOIN hackers H ON S.hacker_id = H.hacker_id
    AND S.score = D.score
GROUP BY H.hacker_id, H.name
HAVING Count(S.hacker_id) > 1
ORDER BY Count(S.hacker_id) DESC, S.hacker_id ASC;



-- You are given two tables: Students and Grades. Students contains three columns ID, Name and Marks.
-- Generate a report containing three columns: Name, Grade and Mark. 
-- No NAMES of those students who received a grade < 8. 
-- The report must be in descending order by grade -- i.e. higher grades are entered first. 
-- If there are more with the same grade (8-10), order those particular students by their name alphabetically. 
-- Finally, if the grade is lower than 8, use "NULL" as their name and list them by their grades in descending order. 
-- If there is more than one student with the same grade (1-7) assigned to them, order those particular students by their marks in ascending order.
SELECT 
    CASE 
        WHEN g.Grade >= 8 THEN s.Name 
        ELSE 'NULL' 
    END AS Name, 
    g.Grade, 
    s.Marks
FROM Students s 
JOIN Grades g 
ON s.Marks BETWEEN g.Min_Mark AND g.Max_Mark -- JOIN ON a condition even without matching columns
ORDER BY 
    g.Grade DESC,              
    CASE 
        WHEN g.Grade >= 8 THEN s.Name   -- For grades 8 and above, order by Name alphabetically
        ELSE s.Marks              -- For grades below 8, order by Marks in ascending order
    END ASC;



-- Given the CITY and COUNTRY tables, query the names of all the continents (COUNTRY.Continent) and their respective average city populations (CITY.Population) rounded down to the nearest integer.
-- Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
SELECT b.CONTINENT, FLOOR(AVG(a.POPULATION))
FROM CITY a JOIN COUNTRY b ON a.CountryCode = b.Code
GROUP BY b.CONTINENT;


-- Given the CITY and COUNTRY tables, query the names of all cities where the CONTINENT is 'Africa'.
-- Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
SELECT a.NAME
FROM CITY a JOIN COUNTRY b ON a.CountryCode = b.Code
WHERE b.CONTINENT = 'Africa';


-- Given the CITY and COUNTRY tables, query the sum of the populations of all cities where the CONTINENT is 'Asia'.
-- Note: CITY.CountryCode and COUNTRY.Code are matching key columns.
SELECT SUM(a.Population)
FROM CITY a JOIN COUNTRY b ON a.CountryCode = b.Code
WHERE b.CONTINENT = 'Asia';

-- A median is defined as a number separating the higher half of a data set from the lower half. 
-- Query the median of the Northern Latitudes (LAT_N) from STATION and round your answer to decimal places. 
-- MySQL
SET @rowindex := -1; -- @: In MySQL, it denotes a user-defined variable
SELECT
   ROUND(AVG(t.LAT_N), 4) AS median 
FROM
   (SELECT @rowindex:=@rowindex + 1 AS rowindex, STATION.LAT_N AS LAT_N
    FROM STATION
    ORDER BY STATION.LAT_N) AS t
WHERE
   t.rowindex IN (FLOOR(@rowindex / 2), CEIL(@rowindex / 2));

--SQL Server
SELECT ROUND(LAT_N, 4) AS median
FROM (
    SELECT LAT_N, 
        -- window function that assigns a unique number to each row
        -- (ORDER BY LAT_N) specifies how to order the rows for numbering
        ROW_NUMBER() OVER (ORDER BY LAT_N) AS row_num, 
        COUNT(*) OVER () AS total_rows -- counts all rows COUNT(*), over the entire result set OVER ()
    FROM STATION
) AS subquery
WHERE row_num IN ((total_rows + 1)/2, (total_rows + 2)/2);

-- Postgres
-- WITHIN GROUP (ORDER BY LAT_N) specifies how to order the data for percentile calculation.
-- ::NUMERIC: This is PostgreSQL's syntax for type casting.
SELECT ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY LAT_N)::NUMERIC, 4) AS median
FROM STATION;

--Oracle
SELECT ROUND(MEDIAN(LAT_N), 4) AS median
FROM STATION;

--------------------------------------

-- Consider P_1(a, b) and P_2(c,d) to be two points on a 2D plane where (a,b) are the respective minimum and maximum values of Northern Latitude (LAT_N) and (c,d)
-- are the respective minimum and maximum values of Western Longitude (LONG_W) in STATION.
-- Query the Euclidean Distance between points P1 and P2 and format your answer to display decimal digits.
Select ROUND(SQRT(POWER((MAX(LAT_N)-MIN(LAT_N)), 2) + POWER((MAX(LONG_W)-MIN(LONG_W)), 2)), 4)
FROM Station;

-- Consider P_1(a, b) and P_2(c,d) to be two points on a 2D plane.
-- a happens to equal the minimum value in Northern Latitude (LAT_N in STATION).
-- b happens to equal the minimum value in Western Longitude (LONG_W in STATION).
-- c happens to equal the maximum value in Northern Latitude (LAT_N in STATION).
-- d happens to equal the maximum value in Western Longitude (LONG_W in STATION).
-- Query the Manhattan Distance between points P_1 and P_2 and round it to a scale of decimal places.
Select ROUND(ABS(MAX(LAT_N)-MIN(LAT_N)) + ABS(MAX(LONG_W)-MIN(LONG_W)), 4)
FROM Station;

-- Founder -> Lead Manger -> Senior Manger -> Manager -> Employee
-- Write a query to print the company_code, founder name, total number of lead managers, total number of senior managers, total number of managers, and total number of employees. 
-- Order by company_code ASC.

-- Note:
-- The tables may contain duplicate records.
-- company_code is string but sorting should not be numeric. 
-- If company_codes are C_1, C_2, and C_10, then the ascending company_codes will be C_1, C_10, and C_2.

-- TABLES 
-- Company: company_code, founder
-- Lead_Manager: lead_manager_code, company_code 
-- Senior_Manager: senior_manager_code, lead_manager_code, company_code 
-- Manager: manager_code, senior_manager_code, lead_manager_code , company_code 
-- Employee: employee_code, manager_code, senior_manager_code, lead_manager_code, company_code 

SELECT COMPANY_CODE, FOUNDER,
(SELECT COUNT(DISTINCT LEAD_MANAGER_CODE) FROM LEAD_MANAGER WHERE COMPANY_CODE = C.COMPANY_CODE),
(SELECT COUNT(DISTINCT SENIOR_MANAGER_CODE) FROM SENIOR_MANAGER WHERE COMPANY_CODE = C.COMPANY_CODE),
(SELECT COUNT(DISTINCT MANAGER_CODE) FROM MANAGER WHERE COMPANY_CODE = C.COMPANY_CODE),
(SELECT COUNT(DISTINCT EMPLOYEE_CODE) FROM EMPLOYEE WHERE COMPANY_CODE = C.COMPANY_CODE)
FROM COMPANY C
ORDER BY COMPANY_CODE;
---------------------------------------------
SELECT
    c.company_code,
    c.founder,
    COUNT(DISTINCT l.lead_manager_code),
    COUNT(DISTINCT s.senior_manager_code),
    COUNT(DISTINCT m.manager_code),
    COUNT(DISTINCT e.employee_code)
FROM
    company c
    JOIN lead_manager l ON c.company_code = l.company_code
    JOIN senior_manager s ON l.company_code = s.company_code
    JOIN manager m ON s.company_code = m.company_code
    JOIN employee e ON m.company_code = e.company_code
GROUP BY
    c.company_code,
    c.founder
ORDER BY
    c.company_code;







-- You are given a table, BST, containing two columns: N and P, where N represents the value of a node in Binary Tree, and P is the parent of N. Write a query to find the node type of Binary Tree ordered by the value of the node. Output one of the following for each node:
-- Root: If node is root node.
-- Leaf: If node is leaf node.
-- Inner: If node is neither root nor leaf node.
SELECT N, CASE 
    WHEN P IS NULL THEN 'Root'                         
    WHEN N IN (SELECT P FROM BST) AND P IS NOT NULL THEN 'Inner'         
    ELSE 'Leaf'                                        
END AS node_type
FROM BST
ORDER BY N;


-- Write a query that prints a list of employee names (i.e.: the name attribute) for employees in Employee having a salary greater than 2000$ per month who have been employees for less than 10 months. Sort your result by ascending employee_id.
SELECT name
FROM Employee 
WHERE salary>2000 and months<10;


-- Write a query that prints a list of employee names (i.e.: the name attribute) from the Employee table in alphabetical order.
SELECT name
FROM Employee 
ORDER BY name

-- Query the Name of any student in STUDENTS who scored higher than 75 Marks. Order your output by the last three characters of each name. If two or more students both have names ending in the same last three characters (i.e.: Bobby, Robby, etc.), secondary sort them by ascending ID.
SELECT name 
FROM students 
WHERE Marks > 75
ORDER BY RIGHT(name, 3), ID


-- Query the list of CITY names from STATION that do not start with vowels and do not end with vowels. Your result cannot contain duplicates.
SELECT
    DISTINCT(city)
FROM
    station
WHERE
    LOWER(LEFT(city, 1)) NOT IN ('a', 'e', 'i', 'o', 'u')
    AND LOWER(RIGHT(city, 1)) NOT IN ('a', 'e', 'i', 'o', 'u');


-- Query the list of CITY names from STATION that either do not start with vowels or do not end with vowels. 
-- Your result cannot contain duplicates.
SELECT
    DISTINCT(city)
FROM
    station
WHERE
    lower(LEFT(city, 1)) NOT IN ('a', 'e', 'i', 'o', 'u')
    OR lower(RIGHT(city, 1)) NOT IN ('a', 'e', 'i', 'o', 'u');

-- find shortest city name
-- set user-defined variable with @
SET @MinCityLen = (
        SELECT MIN(CHAR_LENGTH(city))
        FROM STATION
    );

-- find longest city name
SET @MaxCityLen = (
        SELECT MAX(CHAR_LENGTH(city))
        FROM STATION
    );

SELECT city, CHAR_LENGTH(city)
FROM STATION
WHERE
    -- find shortest city name sorted alphabetically
    city = (
        SELECT city
        FROM STATION
        WHERE CHAR_LENGTH(city) = @MinCityLen
        ORDER BY city ASC
        LIMIT 1
    ) -- find longest city name sorted alphabetically
    OR city = (
        SELECT MIN(city)
        FROM STATION
        WHERE CHAR_LENGTH(city) = @MaxCityLen
        ORDER BY city ASC
        LIMIT 1
    );

-- MIN and MAX LENGTH with UNION
-- shortest and longest _CITY_ names, as well as their respective lengths (i.e.: number of characters in the name). If there is more than one smallest or largest city, choose the one that comes first when ordered alphabetically.
(SELECT city, length(city)
from station
where length(city) = (SELECT max(length(city)) from station)
order by city 
LIMIT 1)

UNION

(SELECT city, length(city)
from station
where length(city) = (SELECT min(length(city)) from station)
order by city 
LIMIT 1);

-- HAVING Calculations
-- Show the provinces that has more patients identified as 'M' than 'F'. Must only show full province_name
SELECT pr.province_name
FROM patients pa JOIN province_names pr 
     ON pa.province_id = pr.province_id
GROUP BY pr.province_name
HAVING
  COUNT(CASE WHEN gender = 'M' THEN 1 END) > COUNT(CASE WHEN gender = 'F' THEN 1 END);


-- BMI 
SELECT  patient_id, weight, height, 
        -- 100.0 casts into float
        ROUND(weight/POWER(height/100.0, 2), 2) AS BMI,
        (CASE 
        WHEN weight/POWER(height/100.0, 2) >= 30 THEN 1 
        ELSE 0 END) AS isObese
FROM patients


-- Binned Groups
-- weight groups & and their size 
-- if weight 100-109 they are placed in 110-119 = 110 group
SELECT floor(weight/10)*10, COUNT(*) AS no_of_patients
FROM patients
GROUP BY floor(weight/10)*10
order by weight DESC

--------------------------------------------

SELECT
  COUNT(*) AS patients_in_group,
  FLOOR(weight / 10) * 10 AS weight_group
FROM patients
GROUP BY weight_group
ORDER BY weight_group DESC;

-- Get all names from different tables - UNION ALL
SELECT first_name, last_name, 'Patient' AS role 
FROM patients

UNION ALL

SELECT first_name, last_name, 'Doctor' AS role 
FROM doctors;

-- More than Once - Multi Grouping
SELECT patient_id, diagnosis, COUNT(diagnosis)
FROM admissions
GROUP BY patient_id, diagnosis
HAVING COUNT(diagnosis) > 1

-- Two new columns with Aggregates
SELECT 
  (SELECT count(*) FROM patients WHERE gender='M') AS male_count, 
  (SELECT count(*) FROM patients WHERE gender='F') AS female_count;

-- LEFT JOIN - find a NULL
-- cities without users
SELECT cities.name, users.id  
FROM cities LEFT JOIN users   
    ON users.city_id = cities.id  
WHERE users.id IS NULL

-- Get earliest date
SELECT a.user_id, a.created_at, a.product  
-- self join will filter for the first purchase date
FROM transactions a INNER JOIN (  
    SELECT user_id, MIN(created_at) AS min_created_at  
    FROM transactions  
-- 1 is shorthand for GROUP BY user_id (first col in SELECT)
    GROUP BY 1) AS b  
    ON a.user_id = b.user_id  
       a.created_at = b.min_created_at

-- Second highest 
SELECT
    IFNULL(  -- if null return specific value
        (SELECT DISTINCT Salary  
        FROM Employee  
        ORDER BY Salary DESC  
        LIMIT 1  -- limit return
        OFFSET 1 -- disregard top n rows
        ), null) as SecondHighestSalary  
FROM Employee  
LIMIT 1
------------------------------------

SELECT MAX(salary) AS SecondHighestSalary  
FROM Employee  
-- exclude max
WHERE salary != (SELECT MAX(salary) FROM Employee)

-- Self Join

-- find employee that is also a manager
SELECT a.name, b.name 
FROM Employee a, Employee b 
WHERE a.mgr_id = b.emp_id

--------------------------------------
-- include employees whether or not they have managers
SELECT a.name, b.name 
FROM Employee a LEFT OUTER JOIN 
     Employee b ON a.emp_id = b.emp_id
-------------------------------------

SELECT a.name 
FROM Employee a JOIN Employee b ON a.ManagerId = b.Id 
WHERE a.salary > b.salary

-- Find Duplicates
SELECT Email 
-- subquery
FROM (  
    SELECT Email, COUNT(Email)  
    FROM Person  
    GROUP BY Email  
) as email_count  
WHERE count > 1

------------------------------------

SELECT Email  
FROM Person  
GROUP BY Email  
HAVING count(Email) > 1

-------------------------------------

DELETE 
FROM Person a 
WHERE id != (SELECT MAX(id) 
			 FROM Person b 
			 WHERE a.p_id = b.p_id);

-- Difference between consecutive Dates
SELECT DISTINCT a.Id
FROM Weather a, Weather b -- self join
WHERE a.Temperature > b.Temperature  
AND DATEDIFF(a.Recorddate, b.Recorddate) = 1

-- Department Highest Salary
SELECT DeptID, MAX(Salary) 
FROM Employee 
GROUP BY DeptID

----------------------------------------
SELECT DeptName, MAX(Salary) 
-- RIGHT JOIN to include departments name without employee
FROM Employee e RIGHT JOIN Department d 
ON e.DeptId = d.DeptID 
GROUP BY DeptName;

----------------------------------------
SELECT  
    d.name AS 'Department',  
    e.name AS 'Employee',  
    Salary  
FROM Employee e INNER JOIN Department d ON 
	 e.DepartmentId = d.Id  
WHERE (DepartmentId, Salary) IN 
      (SELECT DepartmentId, MAX(Salary)  
       FROM Employee  
       GROUP BY DepartmentId)

-- Greater than average
SELECT student, marks 
FROM students 
WHERE marks > (SELECT AVG(marks) from students)

-- Exchange Positions
SELECT   
    CASE   
    -- last id stays inplace when uneven no. of records 
        WHEN((SELECT MAX(id) FROM seat)%2 = 1) AND 
        id = (SELECT MAX(id) FROM seat) THEN id 
        WHEN id%2 = 1 THEN id + 1  -- uneven no. become even
        ELSE id - 1  -- even no. become uneven
    END AS id, student  
FROM seat  
ORDER BY id

-- GetDate(), ISDATE()
-- works with Microsoft SQL Server, Oracle, MySQL
SELECT YEAR(GetDate());

-- returns 1(true) or 0(false) - only in MYSQL
SELECT  ISDATE('1/08/13') AS "MM/DD/YY";

-- Between
SELECT DISTINCT EmpName 
FROM Employees 
WHERE date_of_birth BETWEEN ‘01/01/1960’ AND ‘31/12/1975’;

-- LIKE()
-- underscore _ signifies single chars % zero or more
SELECT * FROM Employees WHERE EmpName like 'S____%s';

