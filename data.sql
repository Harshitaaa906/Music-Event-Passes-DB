-- =========================================
-- Music Event Passes Database
-- MySQL Sample Data
-- =========================================

USE music_event_db;

-- =========================================
-- ORGANIZERS
-- =========================================
INSERT INTO organizer (name, email, phone, company) VALUES
('Raj Kapoor',    'raj.kapoor@starnightevents.com',  '9871452301', 'StarNight Events'),
('Aakash Mehta',  'aakash@livebeatconcerts.in',      '9823017645', 'LiveBeat Concerts'),
('Neha Sinha',    'neha.sinha@indiecollective.org',  '9910384726', 'Indie Collective'),
('Rahul Sharma',  'rahul.s@campusvibes.co.in',       '9845621038', 'Campus Vibes'),
('Priya Oberoi',  'priya.oberoi@soulmusic.in',       '9932107854', 'Soul Music Co.');

-- =========================================
-- EVENTS
-- =========================================
INSERT INTO event (organizer_id, name, venue, city, event_date, capacity, status) VALUES
(1, 'Bollywood Night',    'Delhi Arena',      'Delhi',   '2026-08-05 18:00:00', 8000,  'Upcoming'),
(2, 'DJ Snake Live',      'Mumbai Stadium',   'Mumbai',  '2026-08-20 20:00:00', 12000, 'Completed'),
(3, 'Indie Music Fest',   'Pune Grounds',     'Pune',    '2026-09-10 17:00:00', 5000,  'Upcoming'),
(4, 'College Fest Beats', 'Delhi University', 'Delhi',   '2026-09-25 16:00:00', 3000,  'Upcoming'),
(5, 'Arijit Singh Live',  'Kolkata Stadium',  'Kolkata', '2026-10-15 19:30:00', 7000,  'Upcoming');

-- =========================================
-- PASS TYPES
-- =========================================
INSERT INTO pass_type (event_id, category, price, total_quota) VALUES
-- Bollywood Night
(1, 'General',    799.00,  5000),
(1, 'VIP',       1999.00,  1500),
(1, 'VVIP',      4999.00,   500),
-- DJ Snake Live
(2, 'General',   1299.00,  8000),
(2, 'VIP',       3499.00,  3000),
(2, 'VVIP',      7999.00,  1000),
-- Indie Music Fest
(3, 'Early Bird',  599.00, 1000),
(3, 'General',     999.00, 3500),
(3, 'VIP',        2499.00,  500),
-- College Fest Beats
(4, 'General',     299.00, 2000),
(4, 'VIP',         799.00,  800),
-- Arijit Singh Live
(5, 'General',    1499.00, 5000),
(5, 'VIP',        3999.00, 1500),
(5, 'Group',      1199.00,  500);

-- =========================================
-- ATTENDEES
-- =========================================
INSERT INTO attendee (name, email, phone, city) VALUES
('Riya Malhotra',  'riya.malhotra92@gmail.com',  '9871234509', 'Delhi'),
('Sameer Khan',    'sameerkhan_official@yahoo.in','9823456712', 'Mumbai'),
('Deepika Nair',   'deepika.nair@rediffmail.com', '9945671823', 'Kochi'),
('Aditya Rawat',   'aditya.rawat21@gmail.com',   '9867345621', 'Dehradun'),
('Shruti Joshi',   'shruti.j.pune@gmail.com',    '9912045678', 'Pune'),
('Manav Bhatia',   'manav.bhatia@outlook.com',   '9836712049', 'Chandigarh'),
('Tanvi Desai',    'tanvi.desai.ahm@gmail.com',  '9978234561', 'Ahmedabad'),
('Kunal Verma',    'kunal_v@hotmail.com',         '9823901456', 'Lucknow'),
('Priya Nambiar',  'priyanambiar03@gmail.com',   '9947823016', 'Chennai'),
('Aryan Sethi',    'aryan.sethi.del@gmail.com',  '9810934572', 'Delhi');

-- =========================================
-- SALES (10 records)
-- =========================================
INSERT INTO sale (pass_id, attendee_id, quantity, total_amount, payment_method, status, sale_date) VALUES
(1,  1,  1,   799.00, 'UPI',         'Confirmed', '2026-06-14 11:23:00'),
(2,  6,  2,  3998.00, 'Card',        'Confirmed', '2026-06-17 09:47:00'),
(3,  2,  1,  4999.00, 'Net Banking', 'Confirmed', '2026-07-08 20:31:00'),
(4,  9,  1,  1299.00, 'Card',        'Confirmed', '2026-06-03 10:14:00'),
(5,  3,  2,  6998.00, 'UPI',         'Confirmed', '2026-06-09 18:42:00'),
(6,  2,  1,  7999.00, 'Net Banking', 'Confirmed', '2026-07-01 14:07:00'),
(7,  4,  2,  1198.00, 'UPI',         'Confirmed', '2026-07-15 17:28:00'),
(10, 5,  3,   897.00, 'Cash',        'Confirmed', '2026-08-10 16:38:00'),
(12, 3,  1,  1499.00, 'Card',        'Confirmed', '2026-08-20 19:45:00'),
(13, 8,  2,  7998.00, 'UPI',         'Confirmed', '2026-08-22 10:07:00');

-- =========================================
-- UPDATE sold_count to match confirmed sales
-- =========================================
UPDATE pass_type SET sold_count = 1  WHERE pass_id = 1;
UPDATE pass_type SET sold_count = 2  WHERE pass_id = 2;
UPDATE pass_type SET sold_count = 1  WHERE pass_id = 3;
UPDATE pass_type SET sold_count = 1  WHERE pass_id = 4;
UPDATE pass_type SET sold_count = 2  WHERE pass_id = 5;
UPDATE pass_type SET sold_count = 1  WHERE pass_id = 6;
UPDATE pass_type SET sold_count = 2  WHERE pass_id = 7;
UPDATE pass_type SET sold_count = 3  WHERE pass_id = 10;
UPDATE pass_type SET sold_count = 1  WHERE pass_id = 12;
UPDATE pass_type SET sold_count = 2  WHERE pass_id = 13;

-- =========================================
-- SCAN LOGS
-- =========================================
INSERT INTO scan_log (sale_id, gate, result, scanned_at, operator) VALUES
(4,  'Gate B',   'Granted',   '2026-08-20 19:38:00', 'Rajan'),
(5,  'VIP Gate', 'Granted',   '2026-08-20 19:51:00', 'Mehak'),
(6,  'VIP Gate', 'Granted',   '2026-08-20 20:03:00', 'Mehak'),
(4,  'Gate C',   'Duplicate', '2026-08-20 21:14:00', 'Suresh'),
(3,  'Gate A',   'Denied',    '2026-08-20 20:22:00', 'Rajan');
