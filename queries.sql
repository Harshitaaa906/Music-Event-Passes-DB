
USE music_event_db;

-- =========================================
--  DATA VIEW
-- =========================================

-- View all events
SELECT * FROM event;

-- View all pass types
SELECT * FROM pass_type;

-- View all attendees
SELECT * FROM attendee;

-- View all sales
SELECT * FROM sale;

-- View all scan logs
SELECT * FROM scan_log;

-- =========================================
-- JOIN QUERIES 
-- =========================================

-- Attendee with sale details
SELECT a.name, s.sale_id, s.total_amount, s.status
FROM attendee a
JOIN sale s ON a.attendee_id = s.attendee_id;

-- Sale with pass and event info
SELECT s.sale_id, a.name AS buyer, e.name AS event_name,
       pt.category, s.quantity, s.total_amount
FROM sale s
JOIN attendee  a  ON a.attendee_id = s.attendee_id
JOIN pass_type pt ON pt.pass_id    = s.pass_id
JOIN event     e  ON e.event_id    = pt.event_id;

-- Scan log with buyer and event context
SELECT sl.log_id, a.name AS buyer, e.name AS event_name,
       sl.gate, sl.result, sl.scanned_at
FROM scan_log sl
JOIN sale      s  ON s.sale_id     = sl.sale_id
JOIN attendee  a  ON a.attendee_id = s.attendee_id
JOIN pass_type pt ON pt.pass_id    = s.pass_id
JOIN event     e  ON e.event_id    = pt.event_id;

-- =========================================
-- PEAK SALES ANALYSIS
-- =========================================

-- Total sold and revenue per event
SELECT * FROM event_sales_summary ORDER BY pct_sold DESC;

-- Top selling pass category
SELECT category, SUM(sold_count) AS total_sold
FROM pass_type
GROUP BY category
ORDER BY total_sold DESC;

-- Events with more than 50% capacity sold
SELECT event_name, capacity, total_sold, pct_sold
FROM event_sales_summary
WHERE pct_sold > 50;

-- =========================================
-- SCANNING LOG ANALYSIS
-- =========================================

-- Scan result totals
SELECT result, COUNT(*) AS total
FROM scan_log
GROUP BY result;

-- Duplicate and denied scans (security alerts)
SELECT * FROM scan_alerts;

-- Scans per gate with breakdown
SELECT gate,
       COUNT(*) AS total_scans,
       SUM(CASE WHEN result = 'Granted'   THEN 1 ELSE 0 END) AS granted,
       SUM(CASE WHEN result = 'Denied'    THEN 1 ELSE 0 END) AS denied,
       SUM(CASE WHEN result = 'Duplicate' THEN 1 ELSE 0 END) AS duplicates
FROM scan_log
GROUP BY gate
ORDER BY total_scans DESC;

-- Hourly scan volume
SELECT HOUR(scanned_at) AS hour_of_day,
       COUNT(*) AS scans
FROM scan_log
WHERE result = 'Granted'
GROUP BY HOUR(scanned_at)
ORDER BY hour_of_day;

-- =========================================
-- AGGREGATE ANALYSIS
-- =========================================

-- Total revenue per event
SELECT e.name, SUM(s.total_amount) AS revenue
FROM sale s
JOIN pass_type pt ON pt.pass_id = s.pass_id
JOIN event     e  ON e.event_id = pt.event_id
WHERE s.status = 'Confirmed'
GROUP BY e.name
ORDER BY revenue DESC;

-- Average sale value
SELECT AVG(total_amount) AS avg_sale FROM sale;

-- Revenue breakdown by pass category
SELECT * FROM revenue_by_category;

-- =========================================
-- BUSINESS INSIGHTS
-- =========================================

-- Near-sold-out passes (less than 100 remaining)
SELECT event_name, category, total_quota, sold_count, remaining
FROM pass_inventory
WHERE remaining < 100;

-- All refunded sales
SELECT * FROM sale WHERE status = 'Refunded';

-- =========================================
-- SUBQUERY
-- =========================================

-- Attendees who purchased VIP or VVIP passes
SELECT name FROM attendee
WHERE attendee_id IN (
    SELECT attendee_id FROM sale
    WHERE pass_id IN (
        SELECT pass_id FROM pass_type WHERE category IN ('VIP', 'VVIP')
    )
);

-- Events that have not had any scans yet
SELECT name FROM event
WHERE event_id NOT IN (
    SELECT DISTINCT pt.event_id
    FROM scan_log sl
    JOIN sale s       ON s.sale_id  = sl.sale_id
    JOIN pass_type pt ON pt.pass_id = s.pass_id
);

-- =========================================
-- ORDER + LIMIT
-- =========================================

-- Top 5 highest value sales
SELECT * FROM sale
ORDER BY total_amount DESC
LIMIT 5;

-- 10 most recent gate scans
SELECT * FROM scan_log
ORDER BY scanned_at DESC
LIMIT 10;
