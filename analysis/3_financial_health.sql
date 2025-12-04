
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

