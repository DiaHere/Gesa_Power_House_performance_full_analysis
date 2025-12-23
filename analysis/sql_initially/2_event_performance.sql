
-- Precheck if number of tickets match attendance
WITH MonthlyTickets AS (
    SELECT 
        MONTH(date) AS month_num,
        YEAR(date) AS year_num,
        COUNT(tickets_id) AS num_of_tickets
    FROM tickets
    GROUP BY YEAR(date), MONTH(date)
)
SELECT 
    t.month_num,
    t.num_of_tickets,
    a.total_attendance,  -- No SUM needed here!
    t.num_of_tickets - COALESCE(a.total_attendance, 0) AS difference
FROM MonthlyTickets AS t
LEFT JOIN attendance AS a
    ON t.month_num = MONTH(a.month_year) 
    AND t.year_num = YEAR(a.month_year);
-- It seems number of tickets mismatches the number of attendance. 
-- Therefore, I'll be evaluting events' performance based num of attendance
-- as its a more reliable dataset.  


-- Top 10 events with the most attendance
SELECT 
    e.event_title, 
    ROUND(a.total_attendance / monthly_event_counts.num_events, 2) AS avg_attendance_per_event,
    a.month_year
FROM events AS e 
LEFT JOIN attendance AS a 
    ON MONTH(e.date) = MONTH(a.month_year) AND YEAR(e.date) = YEAR(a.month_year) 
LEFT JOIN ( 
    SELECT 
        MONTH(date) AS month, 
        YEAR(date) AS year, COUNT(*) AS num_events 
    FROM events 
    GROUP BY YEAR(date), MONTH(date) 
    ) AS monthly_event_counts 
    ON MONTH(e.date) = monthly_event_counts.month AND YEAR(e.date) = monthly_event_counts.year 
ORDER BY avg_attendance_per_event DESC 
limit 10;

-- Top 10 events with the least attendance
SELECT 
    e.event_title, 
    ROUND(a.total_attendance / monthly_event_counts.num_events, 2) AS avg_attendance_per_event,
    a.month_year
FROM events AS e 
LEFT JOIN attendance AS a 
    ON MONTH(e.date) = MONTH(a.month_year) AND YEAR(e.date) = YEAR(a.month_year) 
LEFT JOIN ( 
    SELECT 
        MONTH(date) AS month, 
        YEAR(date) AS year, COUNT(*) AS num_events 
    FROM events 
    GROUP BY YEAR(date), MONTH(date) 
    ) AS monthly_event_counts 
    ON MONTH(e.date) = monthly_event_counts.month AND YEAR(e.date) = monthly_event_counts.year 
ORDER BY avg_attendance_per_event ASC 
limit 10;


-- Correlation between average event duration per month and monthly total attendance
WITH monthly_durations AS (
    SELECT
        DATE_FORMAT(e.date, '%Y-%m-01') AS month_key,
        AVG(e.end_time - e.start_time)  AS avg_event_duration
    FROM events e
    GROUP BY month_key
),
monthly_attendance AS (
    SELECT
        DATE_FORMAT(a.month_year, '%Y-%m-01') AS month_key,
        a.total_attendance
    FROM attendance a
),
monthly_join AS (
    SELECT
        md.month_key,
        md.avg_event_duration,
        ma.total_attendance
    FROM monthly_durations md
    JOIN monthly_attendance ma
        ON md.month_key = ma.month_key
    WHERE md.avg_event_duration IS NOT NULL
      AND ma.total_attendance IS NOT NULL
),
agg AS (
    SELECT
        COUNT(*) AS n,
        SUM(avg_event_duration) AS sum_x,
        SUM(total_attendance) AS sum_y,
        SUM(avg_event_duration * total_attendance) AS sum_xy,
        SUM(avg_event_duration * avg_event_duration) AS sum_x2,
        SUM(total_attendance * total_attendance) AS sum_y2
    FROM monthly_join
)
SELECT
    (n * sum_xy - sum_x * sum_y) /
    SQRT( (n * sum_x2 - sum_x * sum_x) *
          (n * sum_y2 - sum_y * sum_y) ) AS corr_duration_vs_attendance
FROM agg;


-- Correlation between average ticket price per month and monthly total attendance
WITH monthly_prices AS (
    SELECT
        DATE_FORMAT(t.date, '%Y-%m-01') AS month_key,
        AVG(t.ticket_prices) AS avg_ticket_price
    FROM tickets t
    WHERE t.ticket_prices IS NOT NULL
    GROUP BY month_key
),
monthly_attendance AS (
    SELECT
        DATE_FORMAT(a.month_year, '%Y-%m-01') AS month_key,
        a.total_attendance
    FROM attendance a
),
monthly_join AS (
    SELECT
        mp.month_key,
        mp.avg_ticket_price,
        ma.total_attendance
    FROM monthly_prices mp
    JOIN monthly_attendance ma
        ON mp.month_key = ma.month_key
    WHERE mp.avg_ticket_price IS NOT NULL
      AND ma.total_attendance IS NOT NULL
),
agg AS (
    SELECT
        COUNT(*) AS n,
        SUM(avg_ticket_price) AS sum_x,
        SUM(total_attendance) AS sum_y,
        SUM(avg_ticket_price * total_attendance) AS sum_xy,
        SUM(avg_ticket_price * avg_ticket_price) AS sum_x2,
        SUM(total_attendance * total_attendance) AS sum_y2
    FROM monthly_join
)
SELECT
    (n * sum_xy - sum_x * sum_y) /
    SQRT( (n * sum_x2 - sum_x * sum_x) *
          (n * sum_y2 - sum_y * sum_y) ) AS corr_price_vs_attendance
FROM agg;


-- ticket price per event
SELECT
    event_id,
    event_title,
    MIN(ticket_prices) AS min_price,
    MAX(ticket_prices) AS max_price,
    ROUND(AVG(ticket_prices), 2) AS avg_price,
    COUNT(*) AS tickets_sold
FROM tickets
WHERE ticket_prices IS NOT NULL
  AND event_title NOT LIKE '%ticket protection%'
GROUP BY event_title, event_id
ORDER BY min_price DESC;