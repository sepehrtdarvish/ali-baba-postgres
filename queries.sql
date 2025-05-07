
SELECT username, email
FROM Users u
WHERE NOT EXISTS (
    SELECT 1
    FROM Reservation r
    WHERE r.user_id = u.id
);

SELECT DISTINCT u.username, u.email
FROM Users u
JOIN Reservation r ON u.id = r.user_id;

SELECT
    u.username,
    DATE_TRUNC('month', t.created_at) AS month,
    SUM(t.paid_amount) AS total_paid
FROM Users u
JOIN Reservation r ON u.id = r.user_id
JOIN Transaction t ON t.id = r.transaction
GROUP BY u.username, month
ORDER BY month;

SELECT u.username, l.city
FROM Users u
JOIN Reservation r ON u.id = r.user_id
JOIN Seat s ON s.id = r.seat
JOIN Ticket t ON s.ticket = t.id
JOIN Location l ON l.id = t.origin
GROUP BY u.username, l.city
HAVING COUNT(*) = 1;

SELECT u.*
FROM Users u
JOIN Reservation r ON u.id = r.user_id
ORDER BY r.created_at DESC
LIMIT 1;

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

SELECT v.type, COUNT(*) AS ticket_count
FROM Ticket t
JOIN Vehicle v ON t.vehicle = v.id
GROUP BY v.type;

SELECT u.username, COUNT(*) AS ticket_count
FROM Users u
JOIN Reservation r ON u.id = r.user_id
WHERE r.created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY u.username
ORDER BY ticket_count DESC
LIMIT 3;

SELECT l.city, COUNT(*) AS sold_tickets
FROM Ticket t
JOIN Location l ON l.id = t.origin
WHERE l.province = 'Tehran'
GROUP BY l.city;

SELECT DISTINCT l.city
FROM Users u
JOIN Reservation r ON u.id = r.user_id
JOIN Seat s ON r.seat = s.id
JOIN Ticket t ON s.ticket = t.id
JOIN Location l ON t.origin = l.id
WHERE u.signup_date = (SELECT MIN(signup_date) FROM Users);

SELECT username
FROM Users
WHERE is_admin = TRUE;

SELECT u.username
FROM Users u
JOIN Reservation r ON u.id = r.user_id
GROUP BY u.username
HAVING COUNT(*) >= 2;

SELECT u.username
FROM Users u
JOIN Reservation r ON u.id = r.user_id
JOIN Seat s ON r.seat = s.id
JOIN Ticket t ON s.ticket = t.id
JOIN Vehicle v ON t.vehicle = v.id
WHERE v.type = 'train'
GROUP BY u.username
HAVING COUNT(*) <= 2;

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

SELECT t.*
FROM Ticket t
JOIN Seat s ON s.ticket = t.id
JOIN Reservation r ON s.id = r.seat
WHERE DATE(r.created_at) = CURRENT_DATE
ORDER BY r.created_at;

SELECT ticket, COUNT(*) AS ticket_count
FROM Seat
GROUP BY ticket
ORDER BY ticket_count DESC
OFFSET 1 LIMIT 1;

SELECT u.username, COUNT(*) AS cancellations,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS cancel_percent
FROM Users u
JOIN Ticket t ON u.id = t.who_canceled
WHERE u.is_admin = TRUE
GROUP BY u.username
ORDER BY cancellations DESC
LIMIT 1;

UPDATE Users
SET username = 'Reddington'
WHERE id = (
    SELECT who_canceled
    FROM Ticket
    WHERE is_canceld = TRUE
    GROUP BY who_canceled
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

DELETE FROM Ticket
WHERE is_canceld = TRUE
  AND who_canceled = (
    SELECT id FROM Users WHERE username = 'Reddington'
);

DELETE FROM Ticket
WHERE is_canceld = TRUE;

UPDATE Seat
SET price = price * 0.9
WHERE ticket IN (
    SELECT t.id
    FROM Ticket t
    JOIN Vehicle v ON t.vehicle = v.id
    WHERE v.name = 'Mahan'
      AND DATE(t.start_at) = CURRENT_DATE
);

SELECT subject, COUNT(*) AS report_count
FROM Report
GROUP BY subject
ORDER BY report_count DESC
LIMIT 1;
