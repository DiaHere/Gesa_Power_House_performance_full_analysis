-- Normalized schema for theatre performance data
CREATE DATABASE IF NOT EXISTS theatre_performance_data;
USE theatre_performance_data;

-- Create attendance table
CREATE TABLE IF NOT EXISTS attendance(
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    month_year DATE UNIQUE,
    total_days_in_use INT,
    num_sep_events INT,
    total_unique_patrons INT,
    total_attendance INT,
    total_first_time_visitors INT
);

-- later verified to be incorrect data
ALTER TABLE attendance
DROP COLUMN num_sep_events,
DROP COLUMN total_days_in_use;


-- Create events table
CREATE TABLE IF NOT EXISTS events(
    event_id INT AUTO_INCREMENT PRIMARY KEY,
    event_title VARCHAR(100) UNIQUE,
    date DATE,
    start_time INT,
    end_time INT
);

-- Insert missing events
INSERT INTO events (event_title, date, start_time, end_time)
SELECT 
    t.event_title,
    MAX(t.date) AS date,
    NULL AS start_time,
    NULL AS end_time
FROM tickets t
LEFT JOIN events e
    ON t.event_title = e.event_title
WHERE e.event_id IS NULL           
GROUP BY t.event_title;


CREATE TABLE IF NOT EXISTS post_event_surveys(
    survey_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT,
    event_title VARCHAR(100),
    date DATE,
    source_of_hearing TEXT,
    age_group VARCHAR(15),
    annual_household_income VARCHAR(20),
    overal_event_expression TEXT,
    feeback_suggestion TEXT,
    FOREIGN KEY (event_id) REFERENCES events(event_id)
);

-- Fill in event_id on post_event_surveys using space-insensitive matching
UPDATE post_event_surveys AS pes
JOIN events AS e
  ON REPLACE(LOWER(pes.event_title), ' ', '') =
     REPLACE(LOWER(e.event_title), ' ', '')
SET pes.event_id = e.event_id
WHERE pes.event_id IS NULL;


-- Create donations table
CREATE TABLE IF NOT EXISTS donations(
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE,
    donation_received INT
);

-- Create Credit Refunds table
CREATE TABLE IF NOT EXISTS credit_refunds(
    refunds_id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE,
    credit_refunded INT,
    payment_type VARCHAR(20)
);

-- Create tickets table
CREATE TABLE IF NOT EXISTS tickets(
    tickets_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id INT,
    date DATE,
    event_title VARCHAR(100),
    payment_type VARCHAR(20),
    ticket_prices INT,
    FOREIGN KEY (event_id) REFERENCES events(event_id)
);

-- Link tickets with events
UPDATE tickets t
JOIN events e 
    ON t.event_title = e.event_title
SET t.event_id = e.event_id
WHERE t.event_id IS NULL;

-- Create a CTE calendar table
SET @startdate := '2023-01-01', 
    @enddate := '2025-03-01';

CREATE TABLE IF NOT EXISTS dim_calendar(
    calendar_date DATE PRIMARY KEY
);

INSERT IGNORE INTO dim_calendar (calendar_date)
SELECT calendar_date 
FROM (
    WITH RECURSIVE cal AS (
    SELECT @startdate AS calendar_date
    UNION ALL
    SELECT DATE_ADD(calendar_date, INTERVAL 1 DAY)
    FROM   cal
    WHERE  calendar_date <= @enddate
    )
    SELECT calendar_date FROM cal
) AS x;