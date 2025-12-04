-- Operational Efficiency & Audience Growth
------------------------------

-- Monthly Attendance trends
SELECT
    YEAR(month_year)  AS year,
    MONTH(month_year) AS month,
    DATE_FORMAT(month_year, '%Y-%m') AS year_mon,
    total_attendance,
    total_first_time_visitors
FROM attendance
WHERE month_year < '2025-01-01'          
ORDER BY year, month;


-- Seasonal pattern: average attendance by calendar month
SELECT
    MONTH(month_year) AS month,
    DATE_FORMAT(month_year, '%M') AS month_name,
    AVG(total_attendance) AS avg_monthly_attendance,
    AVG(total_first_time_visitors) AS avg_monthly_first_time_visitors,
    AVG(
        total_first_time_visitors / NULLIF(total_attendance, 0)
    ) AS avg_first_time_ratio
FROM attendance
WHERE month_year < '2025-01-01'
GROUP BY month, month_name
ORDER BY avg_monthly_attendance DESC, avg_monthly_first_time_visitors DESC;


-- Monthly retention metrics over a two-year period
SELECT
    DATE_FORMAT(month_year, '%Y-%m') AS year_mon,
    total_attendance,
    total_first_time_visitors,
    (total_attendance - total_first_time_visitors) AS returning_visitors,
    ROUND(
        total_first_time_visitors / NULLIF(total_attendance, 0),
        3
    ) AS first_time_ratio,
    ROUND(
        (total_attendance - total_first_time_visitors) / NULLIF(total_attendance, 0),
        3
    ) AS returning_ratio
FROM attendance
WHERE month_year BETWEEN '2023-01-01' AND '2024-12-31'
  AND total_attendance > 0
ORDER BY year_mon;


-- Yearly retention metrics
SELECT
    YEAR(month_year) AS year,
    SUM(total_attendance)           AS total_attendance,
    SUM(total_first_time_visitors)  AS total_first_time_visitors,
    SUM(total_attendance - total_first_time_visitors) AS total_returning_visitors,
    ROUND(
        SUM(total_first_time_visitors) / NULLIF(SUM(total_attendance), 0),
        3
    ) AS first_time_ratio,
    ROUND(
        SUM(total_attendance - total_first_time_visitors)
        / NULLIF(SUM(total_attendance), 0),
        3
    ) AS returning_ratio
FROM attendance
WHERE month_year BETWEEN '2023-01-01' AND '2024-12-31'
GROUP BY YEAR(month_year)
ORDER BY year;


-- Pearson Correlation between first-time visitors and total attendance
SELECT
    stats.n AS num_months,
    stats.sum_x / stats.n AS avg_first_time_ratio,
    stats.sum_y / stats.n AS avg_total_attendance,
    (
        stats.n * stats.sum_xy - stats.sum_x * stats.sum_y
    ) /
    NULLIF(
        SQRT(
            (stats.n * stats.sum_x2 - POW(stats.sum_x, 2)) *
            (stats.n * stats.sum_y2 - POW(stats.sum_y, 2))
        ),
        0
    ) AS pearson_r_first_time_ratio_vs_attendance
FROM (
    SELECT
        COUNT(*) AS n,
        SUM(first_time_ratio) AS sum_x,
        SUM(total_attendance) AS sum_y,
        SUM(first_time_ratio * total_attendance) AS sum_xy,
        SUM(POW(first_time_ratio, 2)) AS sum_x2,
        SUM(POW(total_attendance, 2)) AS sum_y2
    FROM (
        SELECT
            month_year,
            total_attendance,
            total_first_time_visitors / NULLIF(total_attendance, 0) AS first_time_ratio
        FROM attendance
        WHERE total_attendance > 0
          AND month_year < '2025-01-01'
    ) AS m
) AS stats;


-- Monthly returning visitors + donations
SELECT
    a.month_year,
    (a.total_attendance - a.total_first_time_visitors) AS returning_visitors,
    COALESCE(d.monthly_donations, 0) AS monthly_donations
FROM attendance AS a
LEFT JOIN (
    SELECT
        DATE_FORMAT(date, '%Y-%m') AS month_key,
        SUM(donation_received) AS monthly_donations
    FROM donations
    GROUP BY month_key
) AS d
    ON DATE_FORMAT(a.month_year, '%Y-%m') = d.month_key
WHERE a.month_year < '2025-01-01'
ORDER BY a.month_year;

-- Pearson correlation: returning_visitors vs monthly_donations
SELECT
    (stats.n * stats.sum_xy - stats.sum_x * stats.sum_y) /
    NULLIF(
        SQRT(
            (stats.n * stats.sum_x2 - POW(stats.sum_x, 2)) *
            (stats.n * stats.sum_y2 - POW(stats.sum_y, 2))
        ),
        0
    ) AS pearson_r_returning_vs_donations
FROM (
    SELECT
        COUNT(*) AS n,
        SUM(returning_visitors) AS sum_x,
        SUM(monthly_donations) AS sum_y,
        SUM(returning_visitors * monthly_donations) AS sum_xy,
        SUM(POW(returning_visitors, 2)) AS sum_x2,
        SUM(POW(monthly_donations, 2)) AS sum_y2
    FROM (
        SELECT
            (a.total_attendance - a.total_first_time_visitors) AS returning_visitors,
            COALESCE(d.monthly_donations, 0) AS monthly_donations
        FROM attendance AS a
        LEFT JOIN (
            SELECT
                DATE_FORMAT(date, '%Y-%m') AS month_key,
                SUM(donation_received) AS monthly_donations
            FROM donations
            GROUP BY month_key
        ) AS d
            ON DATE_FORMAT(a.month_year, '%Y-%m') = d.month_key
        WHERE a.month_year < '2025-01-01'
          AND a.total_attendance > 0
    ) AS m
) AS stats;



-- Event Performance
---------------------------


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


-- Financial Analysis
---------------------------


-- Monthly ticket revenue VS Montly donations
WITH monthly_ticket_revenue AS (
    SELECT
        DATE_FORMAT(t.date, '%Y-%m-01') AS month_key,
        SUM(t.ticket_prices) AS ticket_revenue
    FROM tickets t
    WHERE t.ticket_prices IS NOT NULL
      AND t.event_title NOT LIKE '%ticket protection%'
    GROUP BY month_key
),

monthly_donations AS (
    SELECT
        DATE_FORMAT(d.date, '%Y-%m-01') AS month_key,
        SUM(donation_received) AS donation_total
    FROM donations d
    GROUP BY month_key
),

events_by_month AS (
    SELECT
        DATE_FORMAT(e.date, '%Y-%m-01') AS month_key,
        GROUP_CONCAT(e.event_title ORDER BY e.event_title SEPARATOR ', ') AS events_in_month
    FROM events e
    GROUP BY month_key
)

SELECT
    COALESCE(mtr.month_key, md.month_key) AS month,
    COALESCE(mtr.ticket_revenue, 0) AS ticket_revenue,
    COALESCE(md.donation_total, 0) AS donation_total,
    e.events_in_month,
    CASE
        WHEN COALESCE(mtr.ticket_revenue, 0) > COALESCE(md.donation_total, 0)
            THEN 'Ticket-Driven Month'
        ELSE 'Donor-Driven Month'
    END AS primary_profit_driver
FROM monthly_ticket_revenue mtr
JOIN monthly_donations md
    ON mtr.month_key = md.month_key
LEFT JOIN events_by_month e
    ON e.month_key = COALESCE(mtr.month_key, md.month_key)
ORDER BY month;


-- Months and Events that had the highest net revenue
WITH monthly_financials AS (
    SELECT
        DATE_FORMAT(d, '%Y-%m-01') AS year_mon,
        SUM(ticket_revenue)   AS ticket_revenue,
        SUM(donation_revenue) AS donation_revenue,
        SUM(refund_amount)    AS refund_amount
    FROM (
        -- Ticket revenue
        SELECT
            t.date AS d,
            t.ticket_prices AS ticket_revenue,
            0 AS donation_revenue,
            0 AS refund_amount
        FROM tickets t

        UNION ALL

        -- Donations
        SELECT
            d.date AS d,
            0 AS ticket_revenue,
            d.donation_received AS donation_revenue,
            0 AS refund_amount
        FROM donations d

        UNION ALL

        -- Credit refunds (money going out)
        SELECT
            r.date AS d,
            0 AS ticket_revenue,
            0 AS donation_revenue,
            r.credit_refunded AS refund_amount
        FROM credit_refunds r
    ) AS x
    GROUP BY DATE_FORMAT(d, '%Y-%m-01')
),
events_per_month AS (
    -- Ticket revenue by event within each month
    SELECT
        DATE_FORMAT(t.date, '%Y-%m-01') AS year_mon,
        e.event_title,
        SUM(t.ticket_prices) AS event_ticket_revenue
    FROM tickets t
    JOIN events e
        ON t.event_id = e.event_id
    GROUP BY
        DATE_FORMAT(t.date, '%Y-%m-01'),
        e.event_title
),
ranked_months AS (
    SELECT
        year_mon,
        (ticket_revenue + donation_revenue - refund_amount) AS month_net_revenue,
        ticket_revenue,
        donation_revenue,
        refund_amount
    FROM monthly_financials
    ORDER BY month_net_revenue DESC
    LIMIT 5
)

SELECT
    rm.year_mon,
    rm.month_net_revenue,
    rm.ticket_revenue,
    rm.donation_revenue,
    rm.refund_amount,
    epm.event_title,
    epm.event_ticket_revenue
FROM ranked_months rm
LEFT JOIN events_per_month epm
    ON epm.year_mon = rm.year_mon
ORDER BY
    rm.month_net_revenue DESC,
    epm.event_ticket_revenue DESC;

-- chart monthly financial performance to see strongest and weakest theatre's fiscal points
WITH monthly_financials AS (
    SELECT
        DATE_FORMAT(x.d, '%Y-%m-01') AS year_mon,
        SUM(x.ticket_revenue) AS ticket_revenue,
        SUM(x.donation_revenue) AS donation_revenue,
        SUM(x.refund_amount) AS refund_amount
    FROM (
        -- Ticket revenue
        SELECT
            t.date AS d,
            t.ticket_prices AS ticket_revenue,
            0 AS donation_revenue,
            0 AS refund_amount
        FROM tickets t

        UNION ALL

        -- Donations
        SELECT
            d.date AS d,
            0 AS ticket_revenue,
            d.donation_received   AS donation_revenue,
            0 AS refund_amount
        FROM donations d

        UNION ALL

        -- Credit refunds (money going out)
        SELECT
            r.date AS d,
            0 AS ticket_revenue,
            0 AS donation_revenue,
            r.credit_refunded AS refund_amount
        FROM credit_refunds r
    ) AS x
    GROUP BY DATE_FORMAT(x.d, '%Y-%m-01')
)

SELECT
    mf.year_mon,
    mf.ticket_revenue,
    mf.donation_revenue,
    mf.refund_amount,
    (mf.ticket_revenue + mf.donation_revenue - mf.refund_amount) AS net_revenue
FROM monthly_financials mf
ORDER BY
    net_revenue DESC;   

-- Correlation between 
WITH monthly_financials AS (
    SELECT
        DATE_FORMAT(x.d, '%Y-%m-01') AS year_mon,
        SUM(x.ticket_revenue) AS ticket_revenue,
        SUM(x.donation_revenue) AS donation_revenue,
        SUM(x.refund_amount) AS refund_amount
    FROM (
        -- Ticket revenue
        SELECT
            t.date AS d,
            t.ticket_prices AS ticket_revenue,
            0 AS donation_revenue,
            0 AS refund_amount
        FROM tickets t

        UNION ALL

        -- Donations
        SELECT
            d.date AS d,
            0 AS ticket_revenue,
            d.donation_received AS donation_revenue,
            0 AS refund_amount
        FROM donations d

        UNION ALL

        -- Credit refunds
        SELECT
            r.date AS d,
            0 AS ticket_revenue,
            0 AS donation_revenue,
            r.credit_refunded AS refund_amount
        FROM credit_refunds r
    ) AS x
    GROUP BY DATE_FORMAT(x.d, '%Y-%m-01')
),

attendance_financials AS (
    SELECT
        a.month_year AS year_mon,
        a.total_attendance,
        (mf.ticket_revenue + mf.donation_revenue - mf.refund_amount) AS net_revenue
    FROM attendance a
    JOIN monthly_financials mf
        ON mf.year_mon = a.month_year
)

-- Pearson correlation between attendance and net revenue
SELECT
    (COUNT(*) * SUM(total_attendance * net_revenue)
        - SUM(total_attendance) * SUM(net_revenue))
    /
    SQRT(
        (COUNT(*) * SUM(POW(total_attendance, 2)) - POW(SUM(total_attendance), 2))
        *
        (COUNT(*) * SUM(POW(net_revenue, 2)) - POW(SUM(net_revenue), 2))
    )
    AS attendance_netRevenue_correlation
FROM attendance_financials;



-- Attendance influence on NET revenue while balancing seasonal patterns
WITH monthly_financials AS (
    -- Build monthly net revenue (tickets + donations – refunds)
    SELECT
        DATE_FORMAT(x.d, '%Y-%m-01') AS year_mon,
        SUM(x.ticket_revenue) AS ticket_revenue,
        SUM(x.donation_revenue) AS donation_revenue,
        SUM(x.refund_amount) AS refund_amount,
        SUM(x.ticket_revenue + x.donation_revenue - x.refund_amount) AS net_revenue
    FROM (
        SELECT
            t.date AS d,
            t.ticket_prices AS ticket_revenue,
            0 AS donation_revenue,
            0 AS refund_amount
        FROM tickets t

        UNION ALL

        SELECT
            d.date AS d,
            0 AS ticket_revenue,
            d.donation_received AS donation_revenue,
            0 AS refund_amount
        FROM donations d

        UNION ALL

        SELECT
            r.date AS d,
            0 AS ticket_revenue,
            0 AS donation_revenue,
            r.credit_refunded AS refund_amount
        FROM credit_refunds r
    ) x
    GROUP BY DATE_FORMAT(x.d, '%Y-%m-01')
),

monthly AS (
    -- Combine attendance with net revenue
    SELECT
        a.month_year,
        MONTH(a.month_year) AS month_num,
        a.total_attendance,
        mf.net_revenue
    FROM attendance a
    JOIN monthly_financials mf
        ON mf.year_mon = a.month_year
),

month_means AS (
    -- Monthly seasonal means
    SELECT
        month_num,
        AVG(total_attendance) AS avg_attendance,
        AVG(net_revenue)      AS avg_net_revenue
    FROM monthly
    GROUP BY month_num
),

demeaned AS (
    -- Remove monthly seasonal patterns (residualization)
    SELECT
        m.month_year,
        m.month_num,
        m.total_attendance,
        m.net_revenue,
        m.total_attendance - mm.avg_attendance AS att_resid,
        m.net_revenue      - mm.avg_net_revenue AS rev_resid
    FROM monthly m
    JOIN month_means mm
        ON m.month_num = mm.month_num
)

-- Regression + adjusted correlation
SELECT
    -- β coefficient: Effect of attendance on net revenue
    SUM(att_resid * rev_resid) / SUM(att_resid * att_resid)
        AS beta_attendance_effect,

    -- Correlation after seasonal adjustment	
    SUM(att_resid * rev_resid)
        / SQRT(SUM(att_resid * att_resid) * SUM(rev_resid * rev_resid))
        AS corr_attendance_netRevenue_adj
FROM demeaned;

