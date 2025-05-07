
-- 1. Get user tickets by email or phone
CREATE OR REPLACE FUNCTION get_user_tickets(contact TEXT)
RETURNS TABLE(ticket_id UUID, start_at TIMESTAMP, created_at TIMESTAMP) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.start_at, r.created_at
    FROM Users u
    JOIN Reservation r ON u.id = r.user
    JOIN Seat s ON r.seat = s.id
    JOIN Ticket t ON s.ticket = t.id
    WHERE u.email = contact OR u.username = contact
    ORDER BY r.created_at;
END;
$$ LANGUAGE plpgsql;

-- 2. Get users with cancelled reservations
CREATE OR REPLACE FUNCTION get_users_with_cancelled_reservations(contact TEXT)
RETURNS TABLE(username TEXT, email TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT u.username, u.email
    FROM Users u
    JOIN Reservation r ON u.id = r.user
    WHERE r.is_cancelled = TRUE AND (u.email = contact OR u.username = contact);
END;
$$ LANGUAGE plpgsql;

-- 3. Get tickets by city
CREATE OR REPLACE FUNCTION get_tickets_by_city(city_name TEXT)
RETURNS TABLE(ticket_id UUID, start_time TIMESTAMP, origin UUID, destination UUID) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.start_at, t.origin, t.destination
    FROM Ticket t
    JOIN Location l ON t.origin = l.id OR t.destination = l.id
    WHERE l.city = city_name;
END;
$$ LANGUAGE plpgsql;

-- 4. Search tickets by phrase
CREATE OR REPLACE FUNCTION search_tickets_by_phrase(phrase TEXT)
RETURNS TABLE(ticket_id UUID, class VARCHAR, username TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.class, u.username
    FROM Ticket t
    JOIN Seat s ON t.id = s.ticket
    JOIN Reservation r ON r.seat = s.id
    JOIN Users u ON r.user = u.id
    JOIN Location lo ON lo.id = t.origin OR lo.id = t.destination
    WHERE u.username ILIKE '%' || phrase || '%'
       OR lo.city ILIKE '%' || phrase || '%'
       OR t.class ILIKE '%' || phrase || '%';
END;
$$ LANGUAGE plpgsql;

-- 5. Get users from same hometown
CREATE OR REPLACE FUNCTION get_users_same_hometown(contact TEXT)
RETURNS TABLE(username TEXT, email TEXT) AS $$
DECLARE
    user_town TEXT;
BEGIN
    SELECT home_town INTO user_town FROM Users
    WHERE email = contact OR username = contact;

    RETURN QUERY
    SELECT username, email
    FROM Users
    WHERE home_town = user_town AND (email <> contact AND username <> contact);
END;
$$ LANGUAGE plpgsql;

-- 6. Top buyers since a date
CREATE OR REPLACE FUNCTION top_buyers_since(from_date TIMESTAMP, n INT)
RETURNS TABLE(username TEXT, ticket_count INT) AS $$
BEGIN
    RETURN QUERY
    SELECT u.username, COUNT(*) AS ticket_count
    FROM Users u
    JOIN Reservation r ON u.id = r.user
    WHERE r.created_at >= from_date AND r.is_cancelled = FALSE
    GROUP BY u.id
    ORDER BY ticket_count DESC
    LIMIT n;
END;
$$ LANGUAGE plpgsql;

-- 7. Cancelled tickets by vehicle type
CREATE OR REPLACE FUNCTION cancelled_tickets_by_vehicle_type(vtype TEXT)
RETURNS TABLE(ticket_id UUID, start_time TIMESTAMP, cancelled_by UUID) AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.start_at, t.who_canceled
    FROM Ticket t
    JOIN Vehicle v ON t.vehicle = v.id
    WHERE v.type = vtype AND t.is_canceld = TRUE
    ORDER BY t.start_at;
END;
$$ LANGUAGE plpgsql;

-- 8. Top reporters by subject
CREATE OR REPLACE FUNCTION top_reporters_by_subject(subject_input TEXT)
RETURNS TABLE(username TEXT, report_count INT) AS $$
BEGIN
    RETURN QUERY
    SELECT u.username, COUNT(*) AS report_count
    FROM Report r
    JOIN Users u ON r.user_id = u.id
    WHERE r.subject = subject_input
    GROUP BY u.id
    ORDER BY report_count DESC;
END;
$$ LANGUAGE plpgsql;
