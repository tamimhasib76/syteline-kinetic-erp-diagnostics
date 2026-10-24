# Test Evidence Log

This file records the environments in which the scripts in this repository have
actually been executed. Absence of an entry for a given version means that
version is **untested**.

## Recorded environments

No environments recorded yet. Entries will be added here as each script is run
against a SyteLine test database.

If you run a script in your own environment, an issue or pull request with the
details below is welcome.

## Entry format

Each tested environment is recorded as:

```text
Environment: <label, e.g. "SyteLine 10 test DB">
SyteLine / CSI version:     <e.g. 10.0.x>
SQL Server version & build: <e.g. SQL Server 2019 CU18, 15.0.4322.2>
Deployment:                 <on-premises / Azure SQL MI / Azure SQL DB>
Permissions granted:        <e.g. VIEW SERVER STATE; SELECT on item_mst, custaddr_mst>
Test date:                  <YYYY-MM-DD>

Script                                          Ran as-is?  Rows / errors   Notes
sql/01_syteline_blocking_spid_check.sql         Yes / No    ...             ...
sql/02_syteline_slow_report_tuning_check.sql    Yes / No    ...             ...
sql/03_syteline_data_health_check_readonly.sql  Yes / No    ...             ...
```

## Notes on scope

- These tests record **that the scripts executed and returned rows** in the
  listed environment. They do not certify correctness of the diagnostics
  themselves against every possible SyteLine configuration.
- Azure SQL Database and Azure SQL Managed Instance are not covered unless
  explicitly listed above.
- When a script required modification for a given environment, the adjustment
  is described in the "Notes" column and applied (or documented) in the script.
