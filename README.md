# Music-Event-Passes-DB

## About This Project

This project simulates a real-world **music event ticketing system** built entirely in MySQL. It handles everything from organizing events and selling passes to tracking entry scans at the gate — with full automation via stored procedures and triggers.

The main focus areas are:
- **Peak sales tracking** — which events are selling out fastest, which pass tiers earn the most
- **Scan log management** — detecting duplicate entries, denied access, and flagging security incidents in real time

---

## Database Structure

**7 Tables:**

| Table | Purpose |
|-------|---------|
| `organizer` | Event organizer details |
| `event` | Music events with capacity and status |
| `pass_type` | Ticket tiers (General, VIP, VVIP, etc.) per event |
| `attendee` | Ticket buyers |
| `sale` | Purchase records with payment info |
| `scan_log` | Every gate entry attempt |
| `scan_audit` | Auto-logged changes to scan results |

---

## How the System Works

```
Organizer → Event → Pass Type → Sale → Scan Log
                                           ↓
                                      Scan Audit
                                           ↓
                                   Peak Sales Views
```

When a ticket is sold, the `sold_count` in `pass_type` updates automatically via trigger. When a gate scan happens via `CALL record_scan()`, the system checks if the ticket was already used — and marks the result as `Granted`, `Denied`, or `Duplicate` without any manual input.

---

## Files

```
music_event_passes_db/
├── schema.sql        → table definitions, ENUMs, foreign keys
├── data.sql          → seed data for all 5 events
├── triggers.sql      → 4 triggers (quota check, audit, sold count)
├── procedure.sql     → 4 stored procedures (scan, sell, refund, cancel)
├── views.sql         → 5 views (peak sales, inventory, alerts, revenue)
├── index.sql         → 10 indexes for query optimization
├── queries.sql       → all analytical queries used in the project
├── transactions.sql  → ACID transaction demonstrations
└── screenshots      → MySQL Workbench output screenshots
```

---

## Setup Instructions

**Step 1 — Run in this order:**
```
schema.sql
data.sql
triggers.sql
procedure.sql
views.sql

```

**Step 2 — Run any query from `queries.sql` or use the stored procedures:**
```sql
-- Check peak sales across all events
SELECT * FROM event_sales_summary ORDER BY pct_sold DESC;

-- Simulate a gate scan
CALL record_scan(1, 'Gate A', 'Operator_01');

-- See security alerts (denied/duplicate scans)
SELECT * FROM scan_alerts;
```

## DBMS Concepts Used

- Relational modeling with foreign keys and ENUMs
- Stored procedures with conditional logic (`IF`, `SIGNAL`)
- Triggers for automation (quota enforcement, audit trail)
- Views for abstraction and analytics
- Indexes for query performance
- Transactions with `SAVEPOINT` and `ROLLBACK`

---

## Author
**Harshita Upadhyaya**  


