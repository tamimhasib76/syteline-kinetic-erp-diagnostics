/*
 * File: 03_syteline_data_health_check_readonly.sql
 * System: Infor SyteLine / CloudSuite Industrial
 * Author: Al Hasib Tamim — Clear Cutover (https://clearcutover.com/)
 * Service Reference: https://clearcutover.com/syteline
 *
 * Purpose:
 *   Starter read-only SQL checks to catch master data exceptions before MRP
 *   runs, financial costing rolls, or ERP migration extraction cycles.
 *
 * BEFORE RUNNING — VERIFY FOR YOUR INSTALLATION:
 *   - Table names: this script assumes standard `_mst` master tables
 *     (item_mst, custaddr_mst). Some environments expose site-filtered views
 *     (`item`, `custaddr`) instead, or use `_mst_all` variants. Confirm with
 *     SELECT name FROM sys.objects WHERE name LIKE '%item%' before running.
 *   - Column names: `unit_cost`, `cur_u_cost`, `lead_time`, `paper_time`,
 *     `p_m_t_code`, `stat`, `cust_seq`, `cust_num` are standard but can
 *     differ across versions and customizations. Verify in your schema.
 *   - Site scope: `_mst` tables usually contain all sites. Uncomment the
 *     `site_ref` line in each query to scope to a single site.
 *
 * All queries are read-only. Requires SELECT permission on the referenced
 * tables/views in the target database.
 */

-- -----------------------------------------------------------------------------
-- 1. Active items with zero or NULL unit cost
--    If you also want to restrict by item category (manufactured / purchased),
--    add a filter after verifying the valid p_m_t_code values in your
--    installation (they are not universal across versions):
--        AND p_m_t_code IN ('M','P')   -- example only
--    The query as shipped does NOT restrict by p_m_t_code.
-- -----------------------------------------------------------------------------
SELECT
    item,
    description,
    p_m_t_code,
    stat,
    unit_cost,
    cur_u_cost
FROM dbo.item_mst
WHERE stat = 'A'
  AND ISNULL(unit_cost, 0) = 0
  -- AND site_ref = '<your_site>'   -- uncomment to scope to one site
;

-- -----------------------------------------------------------------------------
-- 2. Active items with missing or zero lead time
-- -----------------------------------------------------------------------------
SELECT
    item,
    description,
    p_m_t_code,
    lead_time,
    paper_time
FROM dbo.item_mst
WHERE stat = 'A'
  AND ISNULL(lead_time, 0) <= 0
  -- AND site_ref = '<your_site>'   -- uncomment to scope to one site
;

-- -----------------------------------------------------------------------------
-- 3. Duplicate customer names across distinct customer numbers
--    (useful before migration extraction)
-- Checks across all custaddr rows (both cust_seq = 0 primary bill-to
-- and cust_seq > 0 ship-to) and counts how many matching records are
-- primary bill-to accounts (cust_seq = 0).
-- -----------------------------------------------------------------------------
SELECT
    LTRIM(RTRIM(name)) AS normalized_customer_name,
    COUNT(DISTINCT cust_num) AS customer_count,
    COUNT(DISTINCT CASE WHEN cust_seq = 0 THEN cust_num END) AS bill_to_customer_count,
    MIN(cust_num) AS first_cust_num,
    MAX(cust_num) AS last_cust_num
FROM dbo.custaddr_mst
WHERE LTRIM(RTRIM(ISNULL(name, ''))) <> ''
GROUP BY LTRIM(RTRIM(name))
HAVING COUNT(DISTINCT cust_num) > 1
ORDER BY customer_count DESC;
