-- =========================================
-- Music Event Passes Database
-- MySQL Schema
-- =========================================

CREATE DATABASE IF NOT EXISTS music_event_db;
USE music_event_db;

-- =========================================
-- TABLE: organizer
-- =========================================
CREATE TABLE organizer (
    organizer_id   INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    email          VARCHAR(100) UNIQUE NOT NULL,
    phone          VARCHAR(15)  UNIQUE NOT NULL,
    company        VARCHAR(100),
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- TABLE: event
-- =========================================
CREATE TABLE event (
    event_id       INT AUTO_INCREMENT PRIMARY KEY,
    organizer_id   INT,
    name           VARCHAR(150) NOT NULL,
    venue          VARCHAR(200),
    city           VARCHAR(80),
    event_date     DATETIME NOT NULL,
    capacity       INT NOT NULL,
    status         ENUM('Upcoming','Live','Completed','Cancelled') DEFAULT 'Upcoming',
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_event_organizer FOREIGN KEY (organizer_id)
        REFERENCES organizer(organizer_id) ON DELETE CASCADE
);

-- =========================================
-- TABLE: pass_type
-- =========================================
CREATE TABLE pass_type (
    pass_id        INT AUTO_INCREMENT PRIMARY KEY,
    event_id       INT,
    category       ENUM('General','VIP','VVIP','Backstage','Early Bird','Group'),
    price          DECIMAL(10,2) NOT NULL,
    total_quota    INT NOT NULL,
    sold_count     INT NOT NULL DEFAULT 0,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pass_event FOREIGN KEY (event_id)
        REFERENCES event(event_id) ON DELETE CASCADE
);

-- =========================================
-- TABLE: attendee
-- =========================================
CREATE TABLE attendee (
    attendee_id    INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(100) NOT NULL,
    email          VARCHAR(100) UNIQUE NOT NULL,
    phone          VARCHAR(15),
    city           VARCHAR(80),
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- TABLE: sale
-- =========================================
CREATE TABLE sale (
    sale_id        INT AUTO_INCREMENT PRIMARY KEY,
    pass_id        INT,
    attendee_id    INT,
    quantity       INT NOT NULL DEFAULT 1,
    total_amount   DECIMAL(10,2) NOT NULL,
    payment_method ENUM('UPI','Card','Cash','Net Banking','Wallet'),
    status         ENUM('Confirmed','Pending','Refunded','Cancelled') DEFAULT 'Confirmed',
    sale_date      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sale_pass     FOREIGN KEY (pass_id)
        REFERENCES pass_type(pass_id) ON DELETE RESTRICT,
    CONSTRAINT fk_sale_attendee FOREIGN KEY (attendee_id)
        REFERENCES attendee(attendee_id) ON DELETE RESTRICT
);

-- =========================================
-- TABLE: scan_log
-- =========================================
CREATE TABLE scan_log (
    log_id      INT AUTO_INCREMENT PRIMARY KEY,
    sale_id     INT,
    gate        VARCHAR(50),
    result      ENUM('Granted','Denied','Duplicate') DEFAULT 'Granted',
    scanned_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator    VARCHAR(100),
    CONSTRAINT fk_scan_sale FOREIGN KEY (sale_id)
        REFERENCES sale(sale_id) ON DELETE RESTRICT
);

-- =========================================
-- TABLE: scan_audit
-- =========================================
CREATE TABLE scan_audit (
    audit_id    INT AUTO_INCREMENT PRIMARY KEY,
    sale_id     INT,
    action      VARCHAR(100),
    old_result  VARCHAR(50),
    new_result  VARCHAR(50),
    action_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
