/*
 * File: 02_syteline_slow_report_tuning_check.sql
 * System: Infor SyteLine / CloudSuite Industrial (SQL Server & SSRS)
 * Author: Al Hasib Tamim — Clear Cutover (https://clearcutover.com/)
 * Full Guide: https://clearcutover.com/blog/syteline-slow-report-sql-tuning
 * Related:    https://clearcutover.com/blog/syteline-background-task-definitions
 *
 * Purpose:
 *   Section 1 — list the slowest CACHED stored procedures in the CURRENT database
 *               by average elapsed time and logical reads. Useful for ranking
 *               candidate report procedures (typically RPT*Sp) worth reviewing.
 *   Section 2 — a commented-out manual testing template for running a specific
 *               procedure in SSMS with SET STATISTICS IO/TIME ON, so you can
 *               inspect the actual plan for cursors, scalar UDFs, non-SARGable
 *               predicates, and missing site_ref filters.
 *
 * Limitations:
 *   - This script does NOT automatically detect non-SARGable predicates, missing
 *     site_ref joins, or cursor bottlenecks. That analysis is manual (Section 2).
 *   - sys.dm_exec_procedure_stats reads the plan cache. Rows disappear when plans
 *     are evicted (memory pressure, recompile, restart, statistics update).
 *   - Statistics are per-database and per-cached-plan, not a historical record.
 *     The database_id = DB_ID() filter means procedures cached in other
 *     databases will not appear.
 *   - Permission (on-premises SQL Server): VIEW SERVER STATE on SQL Server 2019
 *     and earlier; VIEW SERVER PERFORMANCE STATE on SQL Server 2022+.
 *     VIEW DATABASE STATE is not sufficient for this DMV on on-premises
 *     SQL Server. Azure SQL Database and Azure SQL Managed Instance have
 *     service-specific requirements — confirm against Microsoft's current
 *     documentation before relying on this script there.
 *   - If OBJECT_NAME() returns NULL, check metadata visibility (VIEW DEFINITION)
 *     and confirm the procedure exists in the database being queried. Neither
 *     replaces the DMV permission above.
 */

-- =============================================================================
-- 1. List top 25 slowest cached stored procedures in the current database
-- Note: Standard SyteLine report procedures typically match '%Rpt%Sp%', but custom
-- report procedures may use site-specific prefixes. Comment out the LIKE filter
-- to inspect all cached stored procedures in the database.
-- =============================================================================
SELECT TOP 25
    OBJECT_NAME(ps.object_id, ps.database_id) AS procedure_name,
    ps.execution_count,
    CAST(ps.total_elapsed_time / 1000000.0 / NULLIF(ps.execution_count, 0) AS DECIMAL(12, 2)) AS avg_elapsed_seconds,
    CAST(ps.max_elapsed_time   / 1000000.0 AS DECIMAL(12, 2)) AS max_elapsed_seconds,
    CAST(ps.total_worker_time  / 1000000.0 / NULLIF(ps.execution_count, 0) AS DECIMAL(12, 2)) AS avg_cpu_seconds,
    ps.total_logical_reads / NULLIF(ps.execution_count, 0) AS avg_logical_reads,
    ps.last_execution_time
FROM sys.dm_exec_procedure_stats AS ps
WHERE ps.database_id = DB_ID()
  AND ps.execution_count > 0
  AND OBJECT_NAME(ps.object_id, ps.database_id) LIKE '%Rpt%Sp%'  -- comment out to include non-Rpt names
ORDER BY avg_elapsed_seconds DESC;

-- =============================================================================
-- 2. Manual diagnostic template — run in SSMS against a TEST database
--    with parameters copied from Background Task History.
--
-- What to look for in the actual execution plan:
--   - Cursors looping row-by-row over invoices or open items
--     (replace with set-based CASE aging buckets where possible)
--   - Scalar UDFs called inside SELECT or WHERE clauses
--   - Non-SARGable date conversions
--     (e.g., CONVERT(VARCHAR, inv_date) = '2026-01-01'
--      instead of inv_date >= '2026-01-01' AND inv_date < '2026-02-01')
--   - Missing site_ref predicates on _mst_all views
--   - Key lookups / scans on large order / invoice tables
-- =============================================================================
/*
SET STATISTICS IO, TIME ON;
-- EXEC dbo.Rpt_AccountsReceivableAgingSp ...   (paste parameters)
SET STATISTICS IO, TIME OFF;
*/