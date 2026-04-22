-- =========================================
-- Music Event Passes Database
-- MySQL Views
-- =========================================

USE music_event_db;

-- =========================================
-- VIEW: event_sales_summary
-- Peak sales per event — sold, revenue, % filled
-- =========================================
CREATE OR REPLACE VIEW event_sales_summary AS
SELECT
    e.event_id,
    e.name                                          AS event_name,
    e.city,
    e.capacity,
    COALESCE(SUM(CASE WHEN s.status = 'Confirmed' THEN s.quantity     ELSE 0 END), 0) AS total_sold,
    COALESCE(SUM(CASE WHEN s.status = 'Confirmed' THEN s.total_amount ELSE 0 END), 0) AS total_revenue,
    ROUND(
        COALESCE(SUM(CASE WHEN s.status = 'Confirmed' THEN s.quantity ELSE 0 END), 0)
        / e.capacity * 100, 1
    )                                               AS pct_sold
FROM event e
LEFT JOIN pass_type pt ON pt.event_id = e.event_id
LEFT JOIN sale s       ON s.pass_id   = pt.pass_id
GROUP BY e.event_id, e.name, e.city, e.capacity;

-- =========================================
-- VIEW: pass_inventory
-- Live quota and remaining tickets per pass type
-- =========================================
CREATE OR REPLACE VIEW pass_inventory AS
SELECT
    pt.pass_id,
    e.name                           AS event_name,
    pt.category,
    pt.price,
    pt.total_quota,
    pt.sold_count,
    (pt.total_quota - pt.sold_count) AS remaining
FROM pass_type pt
JOIN event e ON e.event_id = pt.event_id;

-- =========================================
-- VIEW: scan_log_detail
-- Full scan log joined with buyer and event info
-- =========================================
CREATE OR REPLACE VIEW scan_log_detail AS
SELECT
    sl.log_id,
    sl.sale_id,
    sl.gate,
    sl.result,
    sl.scanned_at,
    sl.operator,
    a.name       AS buyer_name,
    a.email      AS buyer_email,
    pt.category  AS pass_type,
    e.name       AS event_name
FROM scan_log sl
JOIN sale      s  ON s.sale_id     = sl.sale_id
JOIN attendee  a  ON a.attendee_id = s.attendee_id
JOIN pass_type pt ON pt.pass_id    = s.pass_id
JOIN event     e  ON e.event_id    = pt.event_id;

-- =========================================
-- VIEW: scan_alerts
-- All Denied and Duplicate scans for security review
-- =========================================
CREATE OR REPLACE VIEW scan_alerts AS
SELECT *
FROM scan_log_detail
WHERE result IN ('Denied', 'Duplicate')
ORDER BY scanned_at DESC;

-- =========================================
-- VIEW: revenue_by_category
-- Revenue totals grouped by pass category
-- =========================================
CREATE OR REPLACE VIEW revenue_by_category AS
SELECT
    pt.category,
    COUNT(s.sale_id)    AS total_sales,
    SUM(s.quantity)     AS tickets_sold,
    SUM(s.total_amount) AS total_revenue
FROM sale s
JOIN pass_type pt ON pt.pass_id = s.pass_id
WHERE s.status = 'Confirmed'
GROUP BY pt.category
ORDER BY total_revenue DESC;
