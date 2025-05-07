-- 1 checked
SELECT username, email
FROM Users u
WHERE NOT EXISTS (
    SELECT 1
    FROM Reservation r
    WHERE r.user_id = u.id
);

-- 2 checked
SELECT DISTINCT u.username, u.email
FROM Users u
JOIN Reservation r ON u.id = r.user_id;

-- 3 checked
SELECT
    u.username,
    DATE_TRUNC('month', t.created_at) AS month,
    SUM(t.paid_amount) AS total_paid
FROM Users u
JOIN Reservation r ON u.id = r.user_id
JOIN Transaction t ON t.id = r.transaction
GROUP BY u.username, month
ORDER BY u.username;

-- 4 checked
SELECT u.username
FROM Users u
JOIN Reservation r ON u.id = r.user_id
JOIN Seat s ON s.id = r.seat
JOIN Ticket t ON s.ticket = t.id
JOIN Location l ON l.id = t.origin
GROUP BY u.username
HAVING COUNT(*) = COUNT(DISTINCT l.city);

-- 5 checked
SELECT u.*
FROM Users u
JOIN Reservation r ON u.id = r.user_id
ORDER BY r.created_at DESC
LIMIT 1;

-- 6 checked
SELECT u.email
FROM Users u
JOIN Reservation r ON u.id = r.user_id
JOIN Transaction t ON t.id = r.transaction
GROUP BY u.id, u.email
HAVING SUM(t.paid_amount) > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(t2.paid_amount) AS total
        FROM Reservation r2
        JOIN Transaction t2 ON t2.id = r2.transaction
        GROUP BY r2.user_id
    ) sub
);

-- 7 checked
SELECT v.type, COUNT(*) AS ticket_count
FROM Ticket t
JOIN Vehicle v ON t.vehicle = v.id
GROUP BY v.type;

-- 8 checked
SELECT u.username, COUNT(*) AS ticket_count
FROM Users u
JOIN Reservation r ON u.id = r.user_id
WHERE r.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY u.username
ORDER BY ticket_count DESC
LIMIT 3;

-- 9 checked
SELECT l.city, COUNT(*) AS sold_tickets
FROM Ticket t
JOIN Location l ON l.id = t.origin
WHERE l.province = 'Illinois'
GROUP BY l.city;

-- 10 checked
SELECT DISTINCT l.city
FROM Users u
JOIN Reservation r ON u.id = r.user_id
JOIN Seat s ON r.seat = s.id
JOIN Ticket t ON s.ticket = t.id
JOIN Location l ON t.origin = l.id
WHERE u.signup_date = (SELECT MIN(signup_date) FROM Users);

-- 11 checked
SELECT username
FROM Users
WHERE is_admin = TRUE;

-- 12 checked
SELECT u.username
FROM Users u
JOIN Reservation r ON u.id = r.user_id
GROUP BY u.username
HAVING COUNT(*) >= 2;

-- 13 checked
SELECT Distinct u.username
FROM Users u
JOIN Reservation r ON u.id = r.user_id
JOIN Seat s ON r.seat = s.id
JOIN Ticket t ON s.ticket = t.id
JOIN Vehicle v ON t.vehicle = v.id
GROUP BY u.username, v.type
HAVING COUNT(*) <= 2;

-- 14 
SELECT u.email
FROM Users u
WHERE NOT EXISTS (
    SELECT DISTINCT v.type
    FROM Vehicle v
    EXCEPT
    SELECT DISTINCT v2.type
    FROM Reservation r
    JOIN Seat s ON r.seat = s.id
    JOIN Ticket t ON s.ticket = t.id
    JOIN Vehicle v2 ON t.vehicle = v2.id
    WHERE r.user_id = u.id
);

-- 15 checked
SELECT r.*
from Reservation r 
WHERE DATE(r.created_at) = CURRENT_DATE
ORDER BY r.created_at;

-- 16 checked
SELECT r.ticket, COUNT(*) AS reservation_count
FROM Reservation r
JOIN Seat s ON r.seat = s.id
GROUP BY s.ticket
ORDER BY reservation_count DESC
OFFSET 1 LIMIT 1;

-- 17 checked
SELECT u.username, COUNT(*) AS cancellations,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS cancel_percent
FROM Users u
JOIN Ticket t ON u.id = t.who_canceled
GROUP BY u.username
ORDER BY cancellations DESC
LIMIT 1;

-- 18 
UPDATE Users
SET username = 'Raddington'
WHERE id = (
    SELECT user_id
    FROM Reservation
    WHERE is_cancelled = TRUE
    GROUP BY user_id
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

-- 19 checked
DELETE FROM Reservation r
WHERE r.is_cancelled = TRUE
  AND user_id = (
    SELECT id FROM Users WHERE username = 'Reddington'
);

-- 20 checked
DELETE FROM Reservation r
WHERE r.is_cancelled = TRUE;

-- 21 checked
UPDATE Seat
SET price = price * 0.9
WHERE ticket IN (
    SELECT t.id
    FROM Ticket t
    JOIN Vehicle v ON t.vehicle = v.id
    WHERE v.name = 'Mahan'
      AND DATE(t.start_at) = CURRENT_DATE
);

-- 22 checked
SELECT subject, COUNT(*) AS report_count
FROM Report
GROUP BY subject
ORDER BY report_count DESC
LIMIT 1;
