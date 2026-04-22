-- =========================================
-- Music Event Passes Database
-- MySQL Stored Procedures
-- =========================================

USE music_event_db;
DELIMITER $$

-- =========================================
-- PROCEDURE: Record Gate Scan
-- Auto-detects Granted / Denied / Duplicate
-- =========================================
CREATE PROCEDURE record_scan(
    IN p_sale_id  INT,
    IN p_gate     VARCHAR(50),
    IN p_operator VARCHAR(100)
)
BEGIN
    DECLARE v_status   VARCHAR(50);
    DECLARE v_count    INT;
    DECLARE v_result   VARCHAR(50);

    SELECT status INTO v_status
    FROM sale WHERE sale_id = p_sale_id;

    IF v_status IN ('Refunded', 'Cancelled') THEN
        SET v_result = 'Denied';
    ELSE
        SELECT COUNT(*) INTO v_count
        FROM scan_log
        WHERE sale_id = p_sale_id AND result = 'Granted';

        IF v_count > 0 THEN
            SET v_result = 'Duplicate';
        ELSE
            SET v_result = 'Granted';
        END IF;
    END IF;

    INSERT INTO scan_log (sale_id, gate, result, operator)
    VALUES (p_sale_id, p_gate, v_result, p_operator);
END$$

-- =========================================
-- PROCEDURE: Issue Sale
-- Validates quota then inserts confirmed sale
-- =========================================
CREATE PROCEDURE issue_sale(
    IN p_pass_id        INT,
    IN p_attendee_id    INT,
    IN p_quantity       INT,
    IN p_payment_method VARCHAR(50)
)
BEGIN
    DECLARE v_price     DECIMAL(10,2);
    DECLARE v_available INT;

    SELECT price, (total_quota - sold_count)
    INTO v_price, v_available
    FROM pass_type WHERE pass_id = p_pass_id;

    IF p_quantity > v_available THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough tickets available for this pass type.';
    END IF;

    INSERT INTO sale (pass_id, attendee_id, quantity, total_amount, payment_method, status)
    VALUES (p_pass_id, p_attendee_id, p_quantity, v_price * p_quantity, p_payment_method, 'Confirmed');
END$$

-- =========================================
-- PROCEDURE: Refund Sale
-- Updates sale status to Refunded
-- =========================================
CREATE PROCEDURE refund_sale(IN p_sale_id INT)
BEGIN
    UPDATE sale
    SET status = 'Refunded'
    WHERE sale_id = p_sale_id;
END$$

-- =========================================
-- PROCEDURE: Cancel Event
-- Cancels event and all linked confirmed sales
-- =========================================
CREATE PROCEDURE cancel_event(IN p_event_id INT)
BEGIN
    UPDATE event
    SET status = 'Cancelled'
    WHERE event_id = p_event_id;

    UPDATE sale
    SET status = 'Cancelled'
    WHERE pass_id IN (
        SELECT pass_id FROM pass_type WHERE event_id = p_event_id
    )
    AND status IN ('Confirmed', 'Pending');
END$$

DELIMITER ;
