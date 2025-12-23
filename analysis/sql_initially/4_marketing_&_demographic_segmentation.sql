-- Estimated attendance by age group using survey demographics + attendance

WITH survey_with_month AS (
    -- Surveys with age info + month key
    SELECT
        pes.survey_id,
        pes.age_group,
        DATE_FORMAT(pes.date, '%Y-%m-01') AS month_key
    FROM post_event_surveys pes
    WHERE pes.age_group IS NOT NULL
),

month_age_counts AS (
    -- Count surveys per (month, age_group)
    SELECT
        month_key,
        age_group,
        COUNT(*) AS survey_count
    FROM survey_with_month
    GROUP BY
        month_key,
        age_group
),

month_survey_totals AS (
    -- Total surveys per month (denominator)
    SELECT
        month_key,
        SUM(survey_count) AS total_surveys_in_month
    FROM month_age_counts
    GROUP BY month_key
),

month_attendance AS (
    -- Actual attendance per month
    SELECT
        a.month_year AS month_key,
        a.total_attendance
    FROM attendance a
    WHERE a.total_attendance IS NOT NULL
),

estimated_age_attendance AS (
    -- Estimate attendees in each age_group across months
    -- est = (survey_count / total_surveys_in_month) * total_attendance
    SELECT
        mac.age_group,
        SUM(
            mac.survey_count
            * ma.total_attendance
            / NULLIF(mst.total_surveys_in_month, 0)
        ) AS estimated_attendance
    FROM month_age_counts mac
    JOIN month_survey_totals mst
        ON mac.month_key = mst.month_key
    JOIN month_attendance ma
        ON mac.month_key = ma.month_key
    GROUP BY
        mac.age_group
),

total_attendance AS (
    -- Grand total attendance over the same period
    SELECT
        SUM(total_attendance) AS grand_total_attendance
    FROM attendance
    WHERE total_attendance IS NOT NULL
)

SELECT
    ea.age_group,
    ROUND(ea.estimated_attendance, 0) AS estimated_attendance,
    ROUND(
        ea.estimated_attendance / ta.grand_total_attendance,
        3
    ) AS share_of_total_attendance
FROM estimated_age_attendance ea
CROSS JOIN total_attendance ta
ORDER BY ea.age_group;

-- Estimated attendance by income group using survey demographics + attendance

WITH survey_with_month AS (
    -- Surveys with income info + month key
    SELECT
        pes.survey_id,
        pes.annual_household_income,
        DATE_FORMAT(pes.date, '%Y-%m-01') AS month_key
    FROM post_event_surveys pes
    WHERE pes.annual_household_income IS NOT NULL
),

month_income_counts AS (
    -- Count surveys per (month, income_group)
    SELECT
        month_key,
        annual_household_income,
        COUNT(*) AS survey_count
    FROM survey_with_month
    GROUP BY
        month_key,
        annual_household_income
),

month_survey_totals AS (
    -- Total surveys per month (denominator)
    SELECT
        month_key,
        SUM(survey_count) AS total_surveys_in_month
    FROM month_income_counts
    GROUP BY month_key
),

month_attendance AS (
    -- Actual attendance per month
    SELECT
        a.month_year AS month_key,
        a.total_attendance
    FROM attendance a
    WHERE a.total_attendance IS NOT NULL
),

estimated_income_attendance AS (
    -- Estimate attendees in each income group across months
    SELECT
        mic.annual_household_income,
        SUM(
            mic.survey_count
            * ma.total_attendance
            / NULLIF(mst.total_surveys_in_month, 0)
        ) AS estimated_attendance
    FROM month_income_counts mic
    JOIN month_survey_totals mst
        ON mic.month_key = mst.month_key
    JOIN month_attendance ma
        ON mic.month_key = ma.month_key
    GROUP BY
        mic.annual_household_income
),

total_attendance AS (
    -- Grand total attendance over the same period
    SELECT
        SUM(total_attendance) AS grand_total_attendance
    FROM attendance
    WHERE total_attendance IS NOT NULL
)

SELECT
    ea.annual_household_income,
    ROUND(ea.estimated_attendance, 0) AS estimated_attendance,
    ROUND(
        ea.estimated_attendance / ta.grand_total_attendance,
        3
    ) AS share_of_total_attendance
FROM estimated_income_attendance ea
CROSS JOIN total_attendance ta
ORDER BY ea.annual_household_income;



