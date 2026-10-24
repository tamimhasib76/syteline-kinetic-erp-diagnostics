# Test Evidence Log

This file records the environments in which the scripts in this repository have
actually been executed. It is updated as testing is performed. Absence of an
entry for a given version means that version is **untested**.

## Environment 1 — <label, e.g. "Internal SyteLine 10 test DB">

| Item | Value |
| :--- | :--- |
| SyteLine / CSI version | <e.g. 10.0.x> |
| SQL Server version & build | <e.g. SQL Server 2019 CU18, 15.0.4322.2> |
| Deployment | On-premises / Azure SQL MI / Azure SQL DB |
| Login used | <e.g. sql_test_reader> |
| Permissions granted | <e.g. VIEW SERVER STATE; SELECT on item_mst, custaddr_mst> |
| Test date | <YYYY-MM-DD> |

| Script | Ran as-is? | Rows / errors | Notes |
| :--- | :--- | :--- | :--- |
| `sql/01_syteline_blocking_spid_check.sql` | Yes / No | <e.g. 0 blocking rows (idle test DB)> | <any adjustment> |
| `sql/02_syteline_slow_report_tuning_check.sql` | Yes / No | <e.g. 25 rows returned> | <any adjustment> |
| `sql/03_syteline_data_health_check_readonly.sql` | Yes / No | <e.g. 3 queries, 41 rows total> | <table-name change made> |

## Environment 2 — <label>

(Repeat the block per tested environment.)

## Notes on scope

- These tests record **that the scripts executed and returned rows** in the
  listed environment. They do not certify correctness of the diagnostics
  themselves against every possible SyteLine configuration.
- Azure SQL Database and Azure SQL Managed Instance are not covered unless
  explicitly listed above.
- When a script required modification for a given environment, the adjustment
  is described in the "Notes" column and applied (or documented) in the script.