-- ============================================================
-- CareBridge Health - Business Case SQL Analysis
-- Tool: BigQuery (Standard SQL)
-- Tables: campaigns, customers, claims
-- Purpose: Exploratory and business-case queries supporting
--          the Tableau dashboard and stakeholder presentation.
-- ============================================================


-- ============================================================
-- QUESTION 1
-- Which campaign categories are most efficient at acquiring
-- customers, and how does acquisition cost vary by category?
-- ============================================================

-- Clarify:
-- "Efficient" means low cost per signup. We define cost per signup
-- as total campaign spend divided by total signups attributed to
-- that campaign category. We join campaigns to customers on
-- campaign_id to count signups per category.

-- Communicate:
-- Aggregate campaign cost by category, count distinct customer
-- signups per category, then calculate cost per signup.
-- Order by cost per signup ascending to surface the most
-- efficient categories first.

SELECT
    c.campaign_category,
    ROUND(SUM(c.cost), 2) AS total_spend,
    COUNT(DISTINCT cu.customer_id) AS total_signups,
    ROUND(SUM(c.cost) / NULLIF(COUNT(DISTINCT cu.customer_id), 0), 2) AS cost_per_signup
FROM
    campaigns c
LEFT JOIN
    customers cu ON c.campaign_id = cu.campaign_id
GROUP BY
    c.campaign_category
ORDER BY
    cost_per_signup ASC;

-- Bonus: Break down by campaign_type within each category
-- to identify which campaign type drives efficiency within
-- high-performing categories.

SELECT
    c.campaign_category,
    c.campaign_type,
    ROUND(SUM(c.cost), 2) AS total_spend,
    COUNT(DISTINCT cu.customer_id) AS total_signups,
    ROUND(SUM(c.cost) / NULLIF(COUNT(DISTINCT cu.customer_id), 0), 2) AS cost_per_signup
FROM
    campaigns c
LEFT JOIN
    customers cu ON c.campaign_id = cu.campaign_id
GROUP BY
    c.campaign_category,
    c.campaign_type
ORDER BY
    c.campaign_category,
    cost_per_signup ASC;


-- ============================================================
-- QUESTION 2
-- Which campaigns generate the highest downstream claims
-- exposure, and does acquisition efficiency align with
-- claims risk?
-- ============================================================

-- Clarify:
-- This is the core business question: are the cheapest campaigns
-- to acquire customers also the safest from a claims perspective?
-- We join all three tables - campaigns -> customers -> claims -
-- and compare cost per signup against average claim amount
-- per campaign category.

-- Communicate:
-- Multi-table join: campaigns to customers on campaign_id,
-- customers to claims on customer_id. Aggregate total claims,
-- average claim amount, and cost per signup side by side.
-- Flag categories where average claim amount exceeds the
-- portfolio average of $267 as higher-risk.

WITH campaign_signups AS (
    SELECT
        c.campaign_id,
        c.campaign_category,
        c.cost,
        COUNT(DISTINCT cu.customer_id) AS signups
    FROM
        campaigns c
    LEFT JOIN
        customers cu ON c.campaign_id = cu.campaign_id
    GROUP BY
        c.campaign_id,
        c.campaign_category,
        c.cost
),

campaign_spend AS (
    SELECT
        campaign_category,
        ROUND(SUM(cost), 2) AS total_spend,
        SUM(signups) AS total_signups,
        ROUND(SUM(cost) / NULLIF(SUM(signups), 0), 2) AS cost_per_signup
    FROM
        campaign_signups
    GROUP BY
        campaign_category
),

campaign_claims AS (
    SELECT
        c.campaign_category,
        COUNT(cl.claim_id) AS total_claims,
        ROUND(SUM(cl.claim_amount), 2) AS total_claim_amount,
        ROUND(AVG(cl.claim_amount), 2) AS avg_claim_amount
    FROM
        campaigns c
    LEFT JOIN
        customers cu ON c.campaign_id = cu.campaign_id
    LEFT JOIN
        claims cl ON cu.customer_id = cl.customer_id
    GROUP BY
        c.campaign_category
)

SELECT
    cs.campaign_category,
    cs.total_spend,
    cs.total_signups,
    cs.cost_per_signup,
    cc.total_claims,
    cc.total_claim_amount,
    cc.avg_claim_amount,
    CASE
        WHEN cc.avg_claim_amount > 267 THEN 'Higher Risk'
        WHEN cc.avg_claim_amount <= 267 THEN 'Within Average'
        ELSE 'No Claims Data'
    END AS claims_risk_flag
FROM
    campaign_spend cs
LEFT JOIN
    campaign_claims cc ON cs.campaign_category = cc.campaign_category
ORDER BY
    cc.avg_claim_amount DESC;


-- ============================================================
-- QUESTION 3
-- How does claims exposure vary by plan type, and which plans
-- carry the highest financial risk to CareBridge?
-- ============================================================

-- Clarify:
-- We want to understand whether certain plan types (Bronze,
-- Silver, Gold, Platinum) disproportionately drive claims cost.
-- We also want covered vs. uncovered amounts to understand
-- CareBridge's net exposure per plan.

-- Communicate:
-- Join customers to claims on customer_id. Group by plan.
-- Calculate total claims, total claim amount, total covered
-- amount, and the gap (uncovered amount = claim - covered).
-- Order by total claim amount descending.

SELECT
    cu.plan,
    COUNT(DISTINCT cu.customer_id) AS total_customers,
    COUNT(cl.claim_id) AS total_claims,
    ROUND(SUM(cl.claim_amount), 2) AS total_claim_amount,
    ROUND(SUM(cl.covered_amount), 2) AS total_covered_amount,
    ROUND(SUM(cl.claim_amount - cl.covered_amount), 2) AS total_uncovered_amount,
    ROUND(AVG(cl.claim_amount), 2) AS avg_claim_amount,
    ROUND(COUNT(cl.claim_id) / COUNT(DISTINCT cu.customer_id), 2) AS claims_per_customer
FROM
    customers cu
LEFT JOIN
    claims cl ON cu.customer_id = cl.customer_id
GROUP BY
    cu.plan
ORDER BY
    total_claim_amount DESC;


-- ============================================================
-- QUESTION 4
-- What is the monthly claims trend over time, and when did
-- claims peak? (Validates the mid-2022 peak finding)
-- ============================================================

-- Clarify:
-- We want a month-by-month view of claim volume and total
-- claim amounts to confirm the mid-2022 peak and the decline
-- into 2023 referenced in the dashboard insights.

-- Communicate:
-- Truncate claim_date to month using DATE_TRUNC. Aggregate
-- claim count and total claim amount per month. Use a window
-- function to add a 3-month rolling average for trend clarity.

SELECT
    DATE_TRUNC(cl.claim_date, MONTH) AS claim_month,
    COUNT(cl.claim_id) AS monthly_claims,
    ROUND(SUM(cl.claim_amount), 2) AS monthly_claim_amount,
    ROUND(
        AVG(SUM(cl.claim_amount)) OVER (
            ORDER BY DATE_TRUNC(cl.claim_date, MONTH)
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ), 2
    ) AS rolling_3mo_avg_amount
FROM
    claims cl
GROUP BY
    claim_month
ORDER BY
    claim_month ASC;


-- ============================================================
-- QUESTION 5
-- Which customer acquisition channels (first_touch) produce
-- the highest-value customers by claims and plan type?
-- ============================================================

-- Clarify:
-- first_touch in the customers table records the channel
-- (direct, email, marketplace, referral, social) through which
-- the customer first engaged. We want to know which channels
-- bring in customers who file more or costlier claims -
-- this helps marketing prioritize lower-risk acquisition sources.

-- Communicate:
-- Join customers to claims. Group by first_touch channel.
-- Calculate total customers, claims per customer, average
-- claim amount, and plan distribution to understand the
-- risk profile of each acquisition channel.

WITH channel_claims AS (
    SELECT
        cu.first_touch,
        cu.plan,
        COUNT(DISTINCT cu.customer_id) AS customers,
        COUNT(cl.claim_id) AS total_claims,
        ROUND(SUM(cl.claim_amount), 2) AS total_claim_amount,
        ROUND(AVG(cl.claim_amount), 2) AS avg_claim_amount
    FROM
        customers cu
    LEFT JOIN
        claims cl ON cu.customer_id = cl.customer_id
    GROUP BY
        cu.first_touch,
        cu.plan
)

SELECT
    first_touch,
    SUM(customers) AS total_customers,
    SUM(total_claims) AS total_claims,
    ROUND(SUM(total_claims) / NULLIF(SUM(customers), 0), 2) AS claims_per_customer,
    ROUND(SUM(total_claim_amount) / NULLIF(SUM(total_claims), 0), 2) AS avg_claim_amount,
    STRING_AGG(
        CONCAT(plan, ': ', CAST(customers AS STRING)),
        ' | '
        ORDER BY customers DESC
    ) AS plan_breakdown
FROM
    channel_claims
GROUP BY
    first_touch
ORDER BY
    avg_claim_amount DESC;


-- ============================================================
-- QUESTION 6 (Data Integrity)
-- Investigate the Family Coverage Plan NULL clicks anomaly-
-- is it a tracking gap or a campaign that never ran?
-- ============================================================

-- Clarify:
-- Family Coverage Plan campaigns show NULL clicks (not zero),
-- which is different from campaigns with 0 clicks. NULL suggests
-- the click data was never captured, not that no clicks occurred.
-- We want to confirm: did these campaigns generate any signups
-- despite NULL clicks? If yes, the tracking is broken.
-- If no, the campaigns may never have run.

-- Communicate:
-- Filter campaigns to Family Coverage Plan. Left join to
-- customers to check for signups. Show campaign_id, cost,
-- impressions, clicks, and signup count side by side.
-- A campaign with impressions + signups but NULL clicks
-- confirms a tracking/data capture gap.

SELECT
    c.campaign_id,
    c.campaign_category,
    c.campaign_type,
    c.cost,
    c.impressions,
    c.clicks,
    COUNT(DISTINCT cu.customer_id) AS signups,
    CASE
        WHEN c.clicks IS NULL AND COUNT(DISTINCT cu.customer_id) > 0
            THEN 'Tracking Gap - signups exist but clicks not recorded'
        WHEN c.clicks IS NULL AND COUNT(DISTINCT cu.customer_id) = 0
            THEN 'Campaign May Not Have Run - no clicks or signups'
        WHEN c.clicks = 0 AND COUNT(DISTINCT cu.customer_id) = 0
            THEN 'Confirmed Zero Performance'
        ELSE 'Normal'
    END AS data_quality_flag
FROM
    campaigns c
LEFT JOIN
    customers cu ON c.campaign_id = cu.campaign_id
WHERE
    c.campaign_category = 'Family Coverage Plan'
GROUP BY
    c.campaign_id,
    c.campaign_category,
    c.campaign_type,
    c.cost,
    c.impressions,
    c.clicks;
