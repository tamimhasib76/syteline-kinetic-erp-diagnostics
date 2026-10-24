/*
File: 01_syteline_blocking_spid_check.sql
System: Infor SyteLine 8, 9, 10 (On-Premises SQL Server)
Author: Al Hasib Tamim — Clear Cutover (https://clearcutover.com/)
Full Guide: https://clearcutover.com/blog/syteline-task-running-for-days-wrong-range

Purpose:
When one SyteLine process (such as invoicing) stops while small reports keep running,
another background task with a mistyped parameter range may be holding locks on shared
order/shipment tables.

SAFETY NOTES — READ BEFORE RUNNING:
- These queries are DIAGNOSTIC ONLY. They do not modify data.
- A blocking session may be doing legitimate work. Do not kill it without confirmation.
- A blocking SPID can change or end between Step 1 and Step 2. Re-run Step 1
  immediately before any intervention to confirm the SPID is still the correct one.
- Killing a session can trigger a transaction rollback that takes longer than the
  original task. Monitor with KILL ... WITH STATUSONLY.
- A test database will typically NOT reproduce production blocking behaviour
  (different data volumes, isolated workload, no live users). A clean test run
  is not evidence that there is no production issue.
- Requires VIEW SERVER STATE on SQL Server 2019 and earlier, or
  VIEW SERVER PERFORMANCE STATE on SQL Server 2022+. VIEW DATABASE STATE is not
  sufficient for these server-scoped DMVs on on-premises SQL Server. Azure SQL
  Database and Azure SQL Managed Instance have service-specific requirements —
  confirm against Microsoft's current documentation before relying on this
  script there.
- sys.dm_exec_input_buffer requires SQL Server 2014 SP2 / 2016+. On older versions
  use DBCC INPUTBUFFER(<spid>).

Step 1: Identify active blocking sessions.
Step 2: Inspect the blocking SPID's input buffer, login time, and host BEFORE touching it.
*/

-- =============================================================================
-- STEP 1: Find blocked requests and the blocking_session_id (SPID)
-- =============================================================================
SELECT
    r.session_id           AS blocked_spid,
    r.blocking_session_id  AS blocking_spid,
    r.status,
    r.wait_type,
    r.wait_time / 1000     AS wait_seconds,
    DB_NAME(r.database_id) AS database_name,
    t.text                 AS running_sql
FROM sys.dm_exec_requests AS r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) AS t
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;

-- =============================================================================
-- STEP 2: Confirm the blocking session's identity and parameters FIRST
-- Replace 123 below with the blocking_spid returned in Step 1.
-- Re-run Step 1 to confirm the SPID is still the same session before proceeding.
-- Verify that:
--   1. The input_buffer shows the expected background procedure (e.g., packing slip)
--   2. The host_name matches your TaskMan / utility server
--   3. The start_time matches the RUNNING task in SyteLine Active Background Tasks
-- =============================================================================
DECLARE @BlockingSPID INT = 123; -- Replace with confirmed blocking_spid

SELECT
    s.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    s.login_time,
    r.start_time,
    r.status,
    ib.event_info AS input_buffer
FROM sys.dm_exec_sessions AS s
LEFT JOIN sys.dm_exec_requests AS r
    ON r.session_id = s.session_id
CROSS APPLY sys.dm_exec_input_buffer(s.session_id, NULL) AS ib
WHERE s.session_id = @BlockingSPID;

/*
STEP 3 (ADMIN ONLY — DO NOT RUN UNTIL STEP 2 IS VERIFIED AND STEP 1 HAS BEEN
RE-RUN TO CONFIRM THE SPID IS STILL THE SAME SESSION):

    KILL 123;
    KILL 123 WITH STATUSONLY;   -- Watch rollback progress; do not restart TaskMan
                                -- during rollback.

Killing a session that is not actually the intended blocker can break a running
application transaction. Confirm twice. Prefer cancelling the task from SyteLine
Active Background Tasks where possible.
*/