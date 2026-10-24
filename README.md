# Infor SyteLine (CSI) & Epicor Kinetic ERP Diagnostics Toolkit

Practical, read-only SQL Server diagnostic queries, cached-procedure performance checks, TaskMan troubleshooting checklists, and Epicor Kinetic BAQ / DMT pre-load validation checklists.

Maintained by **Al Hasib Tamim** at **[Clear Cutover](https://clearcutover.com/)** — fixed-price contractor for [Infor SyteLine & CloudSuite Industrial](https://clearcutover.com/syteline) and [Epicor Kinetic Partner Subcontracting](https://clearcutover.com/epicor-kinetic).

Toolkit home page with usage notes: **[SyteLine SQL diagnostics toolkit](https://clearcutover.com/tools/syteline-sql-diagnostics)**

> **Before you run anything:** these are starting points, not certified tools. Schema, permissions, and site scope vary between SyteLine versions and customizations, so verify each script on a test copy of your database first. `TESTING.md` lists the environments the scripts have been run against.

## Supported Versions & Prerequisites

- **Infor SyteLine / CSI:** 8, 9, 10 (on-premises SQL Server). CloudSuite Industrial cloud tenants may restrict DMV access.
- **Epicor Kinetic:** Cloud and on-premises. Behaviour varies by release, so check each item against the version you're working on.
- **SQL Server:** `sys.dm_exec_input_buffer` requires SQL Server 2014 SP2 / 2016+. On older versions use `DBCC INPUTBUFFER`.
- **Permissions (per script, per SQL Server version):**
  - `sql/01_syteline_blocking_spid_check.sql` uses `sys.dm_exec_requests`, `sys.dm_exec_sessions`, `sys.dm_exec_sql_text`, and `sys.dm_exec_input_buffer`. These are **server-scoped** DMVs and require `VIEW SERVER STATE` (on SQL Server 2022 and later, the narrower `VIEW SERVER PERFORMANCE STATE` is also enough). `VIEW DATABASE STATE` is **not** sufficient for this script on on-premises SQL Server. Azure SQL Database and Azure SQL Managed Instance have service-specific requirements — confirm against Microsoft's current documentation before relying on this script there.
  - `sql/02_syteline_slow_report_tuning_check.sql` uses `sys.dm_exec_procedure_stats`. On **on-premises SQL Server**, the required permission is `VIEW SERVER STATE` (on SQL Server 2022 and later, the narrower `VIEW SERVER PERFORMANCE STATE` is also enough). `VIEW DATABASE STATE` is **not** sufficient for this DMV on on-premises SQL Server. **Azure SQL Database and Azure SQL Managed Instance have service-specific permission requirements** — confirm the current requirement for your service tier against Microsoft's documentation before relying on this script there. If `OBJECT_NAME(...)` returns `NULL`, the login may lack metadata visibility on the procedure; granting `VIEW DEFINITION` can address that visibility issue, but it does **not** replace the DMV permission above.
  - `sql/03_syteline_data_health_check_readonly.sql` reads ordinary user tables (`item_mst`, `custaddr_mst`). It requires only `SELECT` on those tables/views in the target database.
- **Schema note:** Table names in `sql/03_*` assume standard `_mst` master tables (e.g., `item_mst`, `custaddr_mst`). Some environments expose site-filtered views (`item`, `custaddr`) instead, or use `_mst_all` variants. Verify against your installation's schema and site scope before running.

## What Is Inside This Repository

| File Path | ERP System | Purpose | Companion Technical Guide |
| :--- | :--- | :--- | :--- |
| `sql/01_syteline_blocking_spid_check.sql` | Infor SyteLine 8 / 9 / 10 (On-Premises) | Identifies long-running background tasks holding SQL locks and inspects `sys.dm_exec_input_buffer` before any administrative intervention. Diagnostic only by default; the `KILL` command is commented out. | [Why a SyteLine task runs for days](https://clearcutover.com/blog/syteline-task-running-for-days-wrong-range) |
| `sql/02_syteline_slow_report_tuning_check.sql` | Infor SyteLine / CSI & SSRS | Lists the slowest **cached** report stored procedures by elapsed time and logical reads, plus a manual SSMS testing template for isolating cursor, scalar-UDF, and non-SARGable predicate issues. Does not auto-detect query patterns. | [Why your SyteLine report is slow](https://clearcutover.com/blog/syteline-slow-report-sql-tuning) |
| `sql/03_syteline_data_health_check_readonly.sql` | Infor SyteLine / CSI (`_mst` tables) | Read-only pre-MRP and pre-cutover exception queries for zero-cost items, missing lead times, and duplicate customer names. Verify table names and site scope for your version. | [Infor SyteLine data health check & upgrade support](https://clearcutover.com/syteline) |
| `checklists/syteline_taskman_stuck_report_checklist.md` | Infor SyteLine / CSI | 5-step verification chain for reports stuck in `WAITING`, `READY`, or `RUNNING`, or finishing with no PDF in the output folder. | [SyteLine report stuck in WAITING](https://clearcutover.com/blog/syteline-report-stuck-waiting-no-pdf) |
| `checklists/epicor_kinetic_baq_and_dmt_checklist.md` | Epicor Kinetic (Cloud & On-Premises) | Audit checklist for common BAQ defects, post-upgrade SSRS/RDD errors, and DMT CSV pre-load validation rules. Items are labelled as common failure patterns, SQL Server behaviour, or environment-specific checks. | [Epicor Kinetic subcontract: SSRS reports, BAQs and DMT](https://clearcutover.com/epicor-kinetic) |
| `TESTING.md` | — | Log of the environments, SQL Server builds, and permission sets the scripts have been run against. | — |

## Complete Infor SyteLine & ERP Reference Guides

All scripts and checklists in this repository come from my ERP administration and report-development work at Clear Cutover. Read the full step-by-step guides on the [Clear Cutover Blog](https://clearcutover.com/blog):

- **Backlog Management & Triage:** [The SyteLine report and data backlog](https://clearcutover.com/blog/syteline-report-data-backlog-guide)
- **Queue & TaskMan Troubleshooting:** [SyteLine report stuck in WAITING, or no PDF in the output folder](https://clearcutover.com/blog/syteline-report-stuck-waiting-no-pdf)
- **SQL Locking & Stuck Processes:** [Why a SyteLine task runs for days](https://clearcutover.com/blog/syteline-task-running-for-days-wrong-range)
- **Report Performance & T-SQL Tuning:** [Why your SyteLine report is slow](https://clearcutover.com/blog/syteline-slow-report-sql-tuning)
- **Background Automation:** [How to schedule a SyteLine report or utility to run automatically](https://clearcutover.com/blog/syteline-schedule-report-background-queue)
- **Task Architecture (`RPT`, `SP`, `EXE`, `IDOMTH`):** [SyteLine Background Task Definitions explained](https://clearcutover.com/blog/syteline-background-task-definitions)
- **Report Modernization:** [Converting SyteLine Crystal Reports to SSRS](https://clearcutover.com/blog/syteline-crystal-to-ssrs-migration)
- **Hiring & Rate Benchmarks:** [SyteLine consultant rates in 2026](https://clearcutover.com/blog/syteline-consultant-rates-hiring-guide)

## Safety & Read-Only Usage Guidelines

1. **Test Environment First:** Run all diagnostic and tuning queries against a copy or test database first, never blind in production.
2. **Read-Only Diagnostics by Default:** Every `.sql` script here is read-only (`SELECT` against DMVs or standard tables). The `KILL <spid>` command in `01_syteline_blocking_spid_check.sql` is commented out. It must only be executed by a system administrator after verifying the session's `input_buffer`, `start_time`, and Active Background Tasks parameters — and re-verifying the SPID immediately before running, because session IDs are reused.
3. **No Direct Table Updates for Application Data:** Fix bad master or transactional data through the SyteLine application, IDOs, or validated DMT loads rather than raw SQL `UPDATE` statements.
4. **Cached Statistics Caveat:** The procedure-stats query in `02_*` reads the plan cache. Statistics disappear when plans are evicted (memory pressure, recompile, restart) and cover only the current database's cached procedures.

## About Clear Cutover

**[Clear Cutover](https://clearcutover.com/)** clears the report, data, and support tickets that internal ERP teams and partner queues never get to — at a fixed price agreed in writing before work starts:

- **Infor SyteLine & CloudSuite Industrial:** Backlog sprints, SSRS and Crystal report changes, DataViews, slow-report T-SQL tuning, version 10 / cloud upgrade report inventories, ongoing support plans ([See SyteLine services](https://clearcutover.com/syteline)).
- **Epicor Kinetic (White-Label Partner Subcontracting):** SSRS field and layout adds, post-upgrade RDD/RDL fixes, BAQ fixes, new BAQ Reports, DMT pre-load CSV validation ([See Epicor Kinetic services](https://clearcutover.com/epicor-kinetic)).
- **Transparent Pricing:** Published base rates and typical fixed-ticket prices ([See typical prices](https://clearcutover.com/pricing) or [request a fixed quote](https://clearcutover.com/contact)).

## License

Released under the MIT License. Not affiliated with Infor or Epicor; all trademarks belong to their respective owners.

If you reference or adapt these scripts in a blog post, wiki, or training material, a link back to the [toolkit page](https://clearcutover.com/tools/syteline-sql-diagnostics) is appreciated.
