-- LEETCODE: 

-- 1327. List the Products Ordered in a Period
SELECT p.product_name, SUM(unit) unit
FROM Products p JOIN Orders o ON p.product_id = o.product_id
WHERE DATE_FORMAT(order_date, "%Y-%m") = '2020-02'
GROUP BY p.product_name
HAVING SUM(unit) >= 100

-- 1484. Group Sold Products By The Date
SELECT sell_date, COUNT(DISTINCT(product)) num_sold, 
    GROUP_CONCAT(DISTINCT product ORDER BY product ASC SEPARATOR ',') products
FROM Activities
GROUP BY sell_date
ORDER BY sell_date

-- 196. Delete Duplicate Emails
DELETE A 
FROM Person A, Person B
WHERE A.Email = B.Email 
AND A.Id > B.Id

-- 176. Second Highest Salary
SELECT IFNULL(  
-- putting the whole statement in IFNULL, to avoid emty result                                   
(SELECT DISTINCT salary
    FROM Employee
    ORDER BY salary DESC
    -- OFFSET lets us skip the first row
    LIMIT 1 OFFSET 1), NULL) AS SecondHighestSalary;

--  1527. Patients With a Condition
SELECT patient_id, patient_name, conditions
FROM Patients
WHERE conditions LIKE '% DIAB1%' OR conditions LIKE 'DIAB1%'

-- Fix Names in a Table
SELECT user_id, CONCAT(UPPER(SUBSTRING(name, 1,1)), LOWER(SUBSTRING(name, 2, 100))) name  
FROM Users 
ORDER BY user_id

-- Department Top Three Salaries
WITH Top AS (SELECT d.name Department, e.salary Salary, e.name Employee,
    -- DENSE_RANK consecutive ranks, while RANK skips ranks for ties
    DENSE_RANK() OVER(PARTITION BY e.departmentId ORDER BY e.salary DESC) AS top_salaries
FROM Employee e JOIN Department d ON e.departmentId = d.id) 

SELECT Department, Employee, Salary
FROM Top
-- Check if the Salary is in the top3 of the Department
WHERE (Department, Salary) IN 
    (SELECT Department, Salary
        FROM Top
        WHERE top_salaries <=3
        -- GROUP BY removes duplicates
        GROUP BY Salary, Department)

-- Resaturant Growth
SELECT
    visited_on,
    (SELECT SUM(amount) FROM customer 
    -- The inner subquery is correlated with the outer query. 
    -- So that for every row in the outer query, the window [visited_on - 6 days, visited_on] is calculated
    WHERE visited_on BETWEEN (c.visited_on - INTERVAL 6 DAY) AND c.visited_on) AS amount,
    ROUND((SELECT SUM(amount) / 7 FROM customer WHERE visited_on BETWEEN (c.visited_on - INTERVAL 6 DAY) AND c.visited_on ),2) AS average_amount
FROM customer c
-- By limiting the date to one week after the min date, we get the sum and average of the last 7 days
WHERE visited_on >= (SELECT DATE_ADD(MIN(visited_on), INTERVAL 6 DAY) FROM customer)
GROUP BY visited_on;

-- Exchange Seats
SELECT IF(id < (SELECT MAX(id) FROM Seat), 
    IF(id%2=0, id-1, id+1),
    IF(id%2=0, id-1, id)
    ) AS id, student
FROM Seat
ORDER BY id;


-- Employees Whose Manager Left the Company
SELECT a.employee_id
FROM (SELECT employee_id, manager_id 
    FROM Employees
    WHERE salary<30000 AND manager_id IS NOT NULL
    ) a LEFT JOIN Employees b ON a.manager_id = b.employee_id
WHERE b.employee_id IS NULL
ORDER BY a.employee_id


-- Count Salary Categories
SELECT 'Low Salary' AS category, COUNT(CASE WHEN income < 20000 THEN 1 END) AS accounts_count 
FROM Accounts
UNION ALL
SELECT 'Average Salary' AS category, COUNT(CASE WHEN income BETWEEN 20000 AND 50000 THEN 1 END) AS accounts_count 
FROM Accounts
UNION ALL
SELECT 'High Salary' AS category, COUNT(CASE WHEN income > 50000 THEN 1 END) AS accounts_count 
FROM Accounts;

-- Last Person to Fit in the Bus
SELECT person_name  
FROM 
(SELECT *,
SUM(weight) OVER(ORDER BY turn) as total
FROM Queue) sub
WHERE total <=1000
ORDER BY total DESC
LIMIT 1

-- Product Price at a Given Date
SELECT product_id, new_price AS price
FROM (SELECT product_id, new_price, change_date,
ROW_NUMBER() OVER(PARTITION BY product_id ORDER BY change_date DESC) rn
FROM Products
WHERE change_date<="2019-08-16") sub
WHERE rn=1

UNION 

SELECT product_id, 10 AS price
FROM Products 
GROUP BY product_id
HAVING MIN(change_date)>"2019-08-16"


-- Consecutive Numbers
SELECT DISTINCT(num) AS ConsecutiveNums 
FROM
    (SELECT num, 
    LAG(num) OVER(ORDER BY id) AS p1, 
    LAG(num, 2) OVER(ORDER BY id) AS p2
    FROM Logs) s
WHERE num = p1 AND num = p2

-- Triangle Judgement
SELECT *, 
IF((x+y>z AND  x+z>y AND z+y>x), "Yes", "No") AS triangle
FROM Triangle

-- Primary Department for Each Employee
SELECT employee_id, department_id 
FROM Employee
WHERE primary_flag ="Y"

UNION

SELECT employee_id, department_id 
FROM Employee
GROUP BY employee_id
HAVING COUNT(employee_id)=1;
---------------------------------------------------------
SELECT employee_id, department_id 
FROM Employee
WHERE primary_flag ="Y" OR employee_id IN 
    (SELECT employee_id
    FROM Employee
    GROUP BY employee_id
    HAVING COUNT(employee_id)=1)




-- The Number of Employees Which Report to Each Employee
SELECT m.employee_id, m.name, COUNT(*) AS reports_count, ROUND(AVG(e.age)) AS average_age 
FROM Employees e JOIN Employees m ON e.reports_to = m.employee_id 
GROUP BY m.employee_id
ORDER BY m.employee_id


-- Customers Who Bought All Products
SELECT customer_id 
FROM Customer
GROUP BY customer_id 
HAVING COUNT(DISTINCT(product_key)) = (SELECT COUNT(DISTINCT(product_key)) FROM Product)


-- Biggest Single Number
SELECT MAX(num) AS num
FROM
(SELECT num
FROM MyNumbers 
GROUP BY num
HAVING Count(num)=1) s

-- Product Sales Analysis III
SELECT product_id, year AS first_year, quantity, price
FROM SALES 
WHERE (product_id, year) 
IN (SELECT product_id, MIN(year) FROM SALES GROUP BY product_id)

------------------------------------------------------------------

SELECT product_id, year AS first_year, quantity, price
FROM
(SELECT s.product_id, year, quantity, price,
RANK() OVER(PARTITION BY s.product_id ORDER BY year) AS rn
FROM Sales s JOIN Product p ON s.product_id = p.product_id) sub
WHERE rn=1;

-- User Activity for the Past 30 Days I
SELECT activity_date AS day, COUNT(DISTINCT(user_id)) AS active_users 
FROM (SELECT activity_date, user_id
        FROM Activity 
        -- SUBDATE subtracts days from a date
        WHERE activity_date > SUBDATE("2019-07-27", 30) 
        AND activity_date <= "2019-07-27") sub
GROUP BY activity_date 
--------------------------------------------------------------------
SELECT activity_date AS day, COUNT(DISTINCT(user_id)) AS active_users 
FROM Activity 
WHERE (activity_date > SUBDATE("2019-07-27", 30) AND activity_date <= "2019-07-27")
GROUP BY activity_date 

-- Game Play Analysis IV
SELECT ROUND(SUM(IF(next_day IS NULL, 0, 1))/COUNT(DISTINCT(a.player_id)), 2) AS fraction
FROM Activity a LEFT JOIN
(SELECT player_id, MIN(event_date) + INTERVAL 1 DAY AS next_day
FROM Activity
GROUP BY player_id) b
ON a.player_id = b.player_id AND a.event_date = b.next_day

-- Immediate Food Delivery II
SELECT ROUND(AVG(immediate)*100, 2) AS immediate_percentage 
FROM 
(SELECT 
customer_id,
IF(order_date=customer_pref_delivery_date, 1, 0) AS immediate,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) as rn
FROM Delivery) sub
WHERE rn=1;

-- Monthly Transactions I
SELECT 
    DATE_FORMAT(trans_date, "%Y-%m") as month,
    country,
    COUNT(id) AS trans_count,
    SUM(IF(state='approved',1,0)) AS approved_count,
    SUM(amount) AS trans_total_amount,
    SUM(IF(state='approved', amount, 0)) AS approved_total_amount 
FROM Transactions
GROUP BY month, country


-- Queries Quality and Percentage
SELECT 
a.query_name, 
ROUND(AVG(rating/position), 2) AS quality,
ROUND(AVG(IF(rating<3, 1,0))*100, 2) AS poor_query_percentage 
FROM Queries a 
WHERE query_name IS NOT NULL
GROUP BY a.query_name

-- Percentage of Users Attended a Contest
SELECT 
    r.contest_id, 
    ROUND((COUNT(DISTINCT(r.user_id))/(SELECT COUNT(*) FROM Users))*100, 2) AS percentage 
FROM Users u JOIN Register r ON u.user_id = r.user_id
GROUP BY r.contest_id 
ORDER BY percentage DESC, r.contest_id 

-- Project Employees I
SELECT p.project_id, ROUND(AVG(experience_years), 2) AS average_years 
FROM Project p JOIN Employee e ON p.employee_id = e.employee_id 
GROUP BY p.project_id

-- Average Selling Price
SELECT p.product_id, IFNULL(ROUND(SUM(price*units)/SUM(units), 2),0) AS average_price 
FROM Prices p LEFT JOIN UnitsSold u
ON p.product_id = u.product_id 
AND u.purchase_date <= p.end_date AND  u.purchase_date >= p.start_date 
GROUP BY p.product_id

-- Not Boring Movies
SELECT *
FROM Cinema
WHERE description <> 'boring' AND MOD(id, 2)=1
ORDER BY rating DESC
---------------------------------------------------
SELECT *
FROM Cinema
WHERE description <> 'boring' AND id%2=1
ORDER BY rating DESC

-- Confirmation Rate
SELECT t.user_id, ROUND((c.confirmations/t.total), 2) AS confirmation_rate 
FROM
    (SELECT s.user_id, Count(*) total
    FROM Signups s LEFT JOIN Confirmations c
    ON s.user_id = c.user_id
    GROUP BY s.user_id) AS t
JOIN
    (SELECT s.user_id, 
        SUM(CASE WHEN c.action = 'confirmed' THEN 1 ELSE  0 END) AS confirmations
    FROM Signups s LEFT JOIN Confirmations c
    ON s.user_id = c.user_id
    GROUP BY s.user_id) c
ON t.user_id = c.user_id
---------------------------------------------------
SELECT s.user_id, ROUND(AVG(IF(action='confirmed', 1,0)), 2) as confirmation_rate
FROM Signups s LEFT JOIN Confirmations c
ON s.user_id = c.user_id
GROUP BY s.user_id


-- Students and Examinations
SELECT 
    st.student_id, 
    st.student_name, 
    s.subject_name,
    COUNT(e.subject_name) AS attended_exams 
FROM Students st CROSS JOIN  Subjects s -- cross join for all possible combinations
LEFT JOIN Examinations e ON st.student_id = e.student_id -- LEFT JOIN to retain all combination for 0 counts
AND s.subject_name = e.subject_name -- JOIN students and subjects for pairs of student-subject
-- GROUP BY subeject_name from Subjects table to keep subjects even without any examinations
GROUP BY st.student_id, st.student_name, s.subject_name 
ORDER BY st.student_id, s.subject_name;

-- Average Time of Process per Machine
SELECT  
    a.machine_id, 
    ROUND(AVG(a.timestamp - b.timestamp), 3) AS processing_time
FROM Activity a
JOIN Activity b
ON a.machine_id = b.machine_id 
AND a.process_id = b.process_id 
AND a.activity_type ='end' 
AND b.activity_type='start'
GROUP BY machine_id

-- Employee Bonus
SELECT name, bonus
FROM Employee e LEFT JOIN Bonus b ON e.empId = b.empId
WHERE bonus < 1000 OR bonus IS NULL