# Epicor Kinetic Subcontract Checklist: SSRS Reports, BAQs & DMT Pre-Load Validation

Maintained by **Al Hasib Tamim** at **[Clear Cutover — Epicor Kinetic Partner Subcontracting](https://clearcutover.com/epicor-kinetic)**.

For fixed-fee partner ticket rates, see **[Clear Cutover Pricing](https://clearcutover.com/pricing)**.

> **How to read this checklist.** Items are labelled as:
> - **[Common pattern]** — a failure seen often in practice; confirm against the actual BAQ before applying.
> - **[Environment-specific]** — depends on customizations, target tenant, or release.
> - **[SQL Server behaviour]** — standard SQL Server behaviour that commonly affects report and BAQ developers.
>
> Kinetic behaviour varies by release and between cloud and on-premises, so check each item against the version you're working on.

## 1. BAQ Troubleshooting & QA Checklist

When a client BAQ returns duplicated rows, inflated order totals, missing records, or `0%` KPI fields, check these failure points first:

- [ ] **[Common pattern] Missing `Company` join:** Verify every table join includes `Company = Company`. Missing predicates allow cross-company records to bleed into results in a multi-company database.
- [ ] **[Common pattern] `CustID` joined to `CustNum`:** Confirm joins use matching key types. `CustNum` is the internal integer key; `CustID` is the alphanumeric display ID. Joining `CustID` to `CustNum` causes type-conversion errors or silent wrong matches. Check the join in the BAQ designer.
- [ ] **[Common pattern] Release-level joins multiplying order lines:** Check whether `OrderRel` is joined directly to `OrderDtl` without aggregation, which can multiply line totals across multi-release sales orders.
- [ ] **[Common pattern] Subquery criteria placement:** Verify whether filter criteria sit on an inner or left-joined subquery that does not restrict the top-level output rows.
- [ ] **[Environment-specific] Wrong date field on overdue/late logic:** Confirm whether `"late"` / `"overdue"` calculated fields reference `NeedByDate` vs `RequestDate` — this differs by business rule, not universally.
- [ ] **[SQL Server behaviour] Integer division returning `0%`:** Cast numerator/denominator to `DECIMAL` before dividing (e.g., fill-rate calculations) so integer division does not truncate percentages.

## 2. SSRS Report & Post-Upgrade RDD Checklist

- [ ] **[Common pattern] Avoid `Sync Dataset` on customized reports:** Using `Sync Dataset` in Report Style Maintenance can corrupt customized multi-join report datasets. Prefer editing the RDL dataset query and field list by hand — but test against your Kinetic version first; behaviour has varied between releases.
- [ ] **[Common pattern] Work on a copy of the standard RDD / Report Style:** Never modify system base styles; copy them. Confirm which styles your release treats as "system base".
- [ ] **[Common pattern] Trace `"Invalid Column Name"` after upgrades:** Compare the upgraded release's base RDD against the custom RDD copy to identify deprecated or renamed columns.
- [ ] **[Environment-specific] Verify cloud upload persistence:** On Kinetic Cloud, preserve exact filenames from the downloaded report zip bundle and re-download the `.rdl` after uploading to confirm the change persisted. This is a known source of "my upload didn't take" tickets.

## 3. DMT Pre-Load CSV Validation Checklist

Run these checks against CSV batches before executing Data Management Tool (DMT) loads — especially when migrating from [Infor SyteLine to Epicor Kinetic](https://clearcutover.com/epicor-kinetic):

- [ ] **[Common pattern] Dependency load order (typical example, verify target-tenant requirements):** Validate and load parent tables before child tables within the same `Company`:
  1. Customer before Customer Ship To and Sales Order Header
  2. Part before Part Plant and Sales Order Line
  3. Sales Order Header before Sales Order Line, and Sales Order Line before Sales Order Release

  Actual dependencies vary by DMT template and target-tenant configuration — confirm in the DMT template's field documentation for the release you're using.
- [ ] **[Environment-specific] `CustID` vs. `CustNum` mapping:** A common approach is to carry legacy customer numbers (such as SyteLine `cust_num`) into Kinetic as `CustID`, and let Kinetic assign `CustNum` itself. Confirm this matches your source-to-target mapping before loading.
- [ ] **[Common pattern] Referential integrity within batch & existing records:** Verify every child row's parent key exists either in the current parent CSV batch or in an export of existing target-tenant records.
- [ ] **[Common pattern] Whitespace, characters & valid codes:** Strip hidden trailing spaces and non-printable characters, and validate all `UOM`, `Site`/`Plant`, and `WarehouseCode` values against target configuration tables before running DMT.
