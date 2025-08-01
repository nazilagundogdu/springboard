/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

    SELECT name 
    FROM `Facilities` 
    WHERE membercost !=0;

/* Q2: How many facilities do not charge a fee to members? */

    SELECT COUNT(facid) 
    FROM `Facilities` 
    WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

    SELECT facid, name, membercost, monthlymaintenance 
    FROM `Facilities` 
    WHERE
        membercost !=0
        AND 
        membercost < 0.2 * monthlymaintenance;


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

    SELECT *
    FROM `Facilities` 
    WHERE
        facid IN (1, 5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

    SELECT name,
    CASE 
        WHEN monthlymaintenance > 100 THEN "expensive"
        ELSE "cheap"
    END AS monthlymaintenance
    FROM `Facilities`;


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

    SELECT firstname, surname, joindate
    FROM Members
    WHERE joindate = (SELECT MAX(joindate) FROM Members);


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

    SELECT DISTINCT(CONCAT_WS(' ', firstname , surname)) AS fullname, f.name
    FROM `Members` AS m
    INNER JOIN `Bookings` AS b
    ON b.memid = m.memid
    INNER JOIN  `Facilities` AS f
    ON f.facid = b.facid
    WHERE name LIKE "%Tennis Court%"
    ORDER by fullname



/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

    SELECT CONCAT_WS( ' ', firstname, surname ) AS fullname, f.name, 
    CASE
            WHEN (`membercost` * slots) > 30 THEN `membercost` * slots
            WHEN (`guestcost` * slots) > 30 THEN `guestcost` * slots
        END AS COST
    FROM `Bookings` AS b
    INNER JOIN `Members` AS m
    ON b.memid = m.memid
    INNER JOIN `Facilities` AS f
    ON b.facid = f.facid
    WHERE `starttime` LIKE "2012-09-14%"
    ORDER BY COST DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

    SELECT CONCAT_WS( ' ', firstname, surname ) AS fullname, name, COST
    FROM
        (SELECT name, memid,
        CASE
            WHEN (`membercost` * slots) > 30 THEN `membercost` * slots
            WHEN (`guestcost` * slots) > 30 THEN `guestcost` * slots
            END AS COST
        FROM `Facilities` AS f
        INNER JOIN `Bookings` AS b
        ON f.facid = b.facid
        WHERE `starttime` LIKE "2012-09-14%") AS sub
    INNER JOIN `Members` AS m
    ON sub.memid = m.memid
    ORDER BY COST DESC;



/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

    from sqlalchemy import create_engine, text
    import pandas as pd
    engine = create_engine('sqlite:///sqlite_db_pythonsqlite.db')
    con = engine.connect()

    rs = con.execute(text("""
    SELECT 
        f.name, 
        (
            SUM(
                CASE 
                    WHEN b.memid = 0 THEN f.guestcost * b.slots 
                    ELSE f.membercost * b.slots 
                END
            ) - f.monthlymaintenance
        ) AS net_revenue 
    FROM Bookings AS b 
    LEFT JOIN Facilities AS f ON b.facid = f.facid 
    GROUP BY f.name, f.monthlymaintenance 
    HAVING net_revenue < 1000 
    ORDER BY net_revenue;
    """))

    df = pd.DataFrame(rs.fetchall())
    df.columns = rs.keys()


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

    rs = con.execute(text("""
    SELECT  surname, firstname, recommendedby  
    FROM `Members` 
    ORDER BY surname, firstname"""))

/* Q12: Find the facilities with their usage by member, but not guests */

    con.execute(text("""
    SELECT b.facid, SUM(b.slots) AS Total_Member_Usage, f.name
    FROM `Bookings` AS b
    LEFT JOIN `Facilities` AS f
    ON b.facid = f.facid
    WHERE (b.memid !=0)
    GROUP BY b.facid
    ORDER BY Total_Member_Usage DESC;"""))

/* Q13: Find the facilities usage by month, but not guests */
    
    rs = con.execute(text("""
    SELECT b.facid, SUM(b.slots) AS Total_Member_Usage, strftime('%m', b.starttime) AS Month, f.name
    FROM `Bookings` AS b
    LEFT JOIN `Facilities` AS f
    ON b.facid = f.facid
    WHERE (b.memid !=0)
    GROUP BY b.facid, Month
    ORDER BY Total_Member_Usage DESC;"""))
