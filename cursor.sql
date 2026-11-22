-- cursor.sql
USE telecom_db;

-- Cursor version: visit each prepaid subscriber below 50 units.
DROP PROCEDURE IF EXISTS sp_notify_low_balance_cursor;
DELIMITER $$

CREATE PROCEDURE sp_notify_low_balance_cursor()
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_subscriber_id INT;
    DECLARE v_balance DECIMAL(10,2);

    DECLARE low_balance_cursor CURSOR FOR
        SELECT subscriber_id, balance
        FROM subscribers
        WHERE user_type = 'PREPAID'
          AND balance < 50;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    OPEN low_balance_cursor;

    read_loop: LOOP
        FETCH low_balance_cursor INTO v_subscriber_id, v_balance;

        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO notifications(subscriber_id, message)
        VALUES (
            v_subscriber_id,
            CONCAT('Your prepaid balance is low: ', v_balance, ' units.')
        );
    END LOOP;

    CLOSE low_balance_cursor;
END$$

DELIMITER ;

-- Set-based version: one INSERT ... SELECT instead of row-by-row processing.
-- Run this after clearing notifications if you want to compare equal workloads.
DROP PROCEDURE IF EXISTS sp_notify_low_balance_set;
DELIMITER $$

CREATE PROCEDURE sp_notify_low_balance_set()
BEGIN
    INSERT INTO notifications(subscriber_id, message)
    SELECT subscriber_id,
           CONCAT('Your prepaid balance is low: ', balance, ' units.')
    FROM subscribers
    WHERE user_type = 'PREPAID'
      AND balance < 50;
END$$

DELIMITER ;

-- Demo and timing comparison:
-- 1) Clear old notifications before each test so both methods process the same rows.
TRUNCATE TABLE notifications;

SET @start_cursor = NOW(6);
CALL sp_notify_low_balance_cursor();
SET @cursor_microseconds = TIMESTAMPDIFF(MICROSECOND, @start_cursor, NOW(6));
SELECT @cursor_microseconds AS cursor_time_microseconds;

SELECT * FROM notifications;

TRUNCATE TABLE notifications;

SET @start_set = NOW(6);
CALL sp_notify_low_balance_set();
SET @set_microseconds = TIMESTAMPDIFF(MICROSECOND, @start_set, NOW(6));
SELECT @set_microseconds AS set_based_time_microseconds;

SELECT * FROM notifications;

-- Usually INSERT ... SELECT is faster for bulk work because the database
-- processes the matching rows as one set rather than fetching them one by one.
-- Actual timing depends on data size, indexes, server load and hardware.
