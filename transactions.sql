-- =========================================
-- Music Event Passes Database
-- MySQL Transactions — ACID Demonstrations
-- =========================================

USE music_event_db;

-- =========================================
-- BASIC TRANSACTION (COMMIT)
-- =========================================
START TRANSACTION;

UPDATE sale
SET status = 'Confirmed'
WHERE sale_id = 1;

COMMIT;

-- =========================================
-- TRANSACTION WITH ROLLBACK
-- =========================================
START TRANSACTION;

UPDATE sale
SET status = 'Refunded'
WHERE sale_id = 2;

ROLLBACK;

-- =========================================
-- SCAN + SALE CONFIRMATION (ATOMIC)
-- =========================================
START TRANSACTION;

UPDATE sale
SET status = 'Confirmed'
WHERE sale_id = 3;

INSERT INTO scan_log (sale_id, gate, result, operator)
VALUES (3, 'Gate A', 'Granted', 'Operator_01');

COMMIT;

-- =========================================
-- SAVEPOINT EXAMPLE
-- =========================================
START TRANSACTION;

UPDATE sale SET status = 'Confirmed' WHERE sale_id = 4;

SAVEPOINT before_scan;

INSERT INTO scan_log (sale_id, gate, result, operator)
VALUES (4, 'VIP Gate', 'Granted', 'Operator_02');

-- Undo only the scan insert, keep sale update
ROLLBACK TO SAVEPOINT before_scan;

COMMIT;

-- =========================================
-- ERROR HANDLING SCENARIO
-- =========================================
START TRANSACTION;

UPDATE sale SET status = 'Confirmed' WHERE sale_id = 5;

-- This will fail: sale_id 9999 does not exist (FK violation)
INSERT INTO scan_log (sale_id, gate, result, operator)
VALUES (9999, 'Gate C', 'Granted', 'Operator_03');

ROLLBACK;

-- =========================================
-- BULK SCAN OPERATION (ATOMIC)
-- =========================================
START TRANSACTION;

CALL record_scan(6, 'Gate A',   'Operator_01');
CALL record_scan(7, 'VIP Gate', 'Operator_02');
CALL record_scan(9, 'Gate B',   'Operator_03');

COMMIT;
