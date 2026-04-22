-- =========================================
-- Music Event Passes Database
-- MySQL Triggers
-- =========================================

USE music_event_db;
DELIMITER $$

-- =========================================
-- TRIGGER: Audit scan result changes
-- Fires when scan_log.result is updated
-- =========================================
CREATE TRIGGER trg_scan_audit
AFTER UPDATE ON scan_log
FOR EACH ROW
BEGIN
    IF OLD.result != NEW.result THEN
        INSERT INTO scan_audit (sale_id, action, old_result, new_result)
        VALUES (OLD.sale_id, 'SCAN RESULT CHANGE', OLD.result, NEW.result);
    END IF;
END$$

-- =========================================
-- TRIGGER: Auto-increment sold_count on sale
-- Fires after a new confirmed sale is inserted
-- =========================================
CREATE TRIGGER trg_increment_sold
AFTER INSERT ON sale
FOR EACH ROW
BEGIN
    IF NEW.status = 'Confirmed' THEN
        UPDATE pass_type
        SET sold_count = sold_count + NEW.quantity
        WHERE pass_id = NEW.pass_id;
    END IF;
END$$

-- =========================================
-- TRIGGER: Restore quota on refund/cancel
-- Fires when sale status changes
-- =========================================
CREATE TRIGGER trg_restore_quota
AFTER UPDATE ON sale
FOR EACH ROW
BEGIN
    IF OLD.status = 'Confirmed' AND NEW.status IN ('Refunded', 'Cancelled') THEN
        UPDATE pass_type
        SET sold_count = GREATEST(0, sold_count - OLD.quantity)
        WHERE pass_id = OLD.pass_id;
    END IF;
END$$

-- =========================================
-- TRIGGER: Block overselling
-- Fires before a new sale is inserted
-- =========================================
CREATE TRIGGER trg_check_quota
BEFORE INSERT ON sale
FOR EACH ROW
BEGIN
    DECLARE available INT;
    SELECT (total_quota - sold_count) INTO available
    FROM pass_type WHERE pass_id = NEW.pass_id;

    IF NEW.status = 'Confirmed' AND NEW.quantity > available THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough quota remaining for this pass type.';
    END IF;
END$$

DELIMITER ;
