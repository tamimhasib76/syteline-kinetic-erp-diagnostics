# Infor SyteLine Report Stuck in WAITING / No PDF Checklist

Maintained by **Al Hasib Tamim** at **[Clear Cutover](https://clearcutover.com/syteline)**.

Full Troubleshooting Guide: **[SyteLine report stuck in WAITING, or no PDF in the output folder](https://clearcutover.com/blog/syteline-report-stuck-waiting-no-pdf)**.

## Quick 5-Step Diagnostic Chain

1. **Check 1 — `Background Task History`:**
   - Filter by the submitting user and the report's task name (`Background Task Definitions`: [See executable types RPT, SP, EXE, IDOMTH](https://clearcutover.com/blog/syteline-background-task-definitions)).
   - **No record at all:** Form-side submission problem. Test with another user and check custom form event handlers.
   - **Record with error message:** Read the full error text for the failing stored procedure or file path.
   - **Record says completed:** Proceed to Check 4 (output path and permissions).

2. **Check 2 — `Active Background Tasks` Status:**
   - **`WAITING` past scheduled time:** The scheduling/release service is not releasing queued tasks ([See Background Queue scheduling guide](https://clearcutover.com/blog/syteline-schedule-report-background-queue)).
   - **`READY` and not moving:** `TaskMan` is not polling or picking up new tasks.
   - **`RUNNING` much longer than normal:** Proceed to Check 5.

3. **Check 3 — `TaskMan` & Windows Services (Post-Patch Night Check):**
   - Confirm `TaskMan` and companion SyteLine services started after Windows patching.
   - Check that no duplicate `TaskMan` instances are polling the same database with mismatched folder paths.

4. **Check 4 — Output Folder & `Report Options`:**
   - Verify the service account running `TaskMan` has write permissions to the output directory and that user `Report Options` point to a valid network path.

5. **Check 5 — Hanging Report or Bad Parameter Range:**
   - Inspect task parameters in `Active Background Tasks` for mistyped wide ranges ([See wrong-range blocking guide](https://clearcutover.com/blog/syteline-task-running-for-days-wrong-range)).
   - Run the underlying stored procedure in SSMS against your test database to isolate SQL execution time vs. SSRS/Crystal rendering time ([See T-SQL report tuning guide](https://clearcutover.com/blog/syteline-slow-report-sql-tuning)).