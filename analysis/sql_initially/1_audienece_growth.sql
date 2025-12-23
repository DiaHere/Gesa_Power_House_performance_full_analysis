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