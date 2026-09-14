# AI-Assisted Prompting Log

This is a log of all AI-assisted prompts used throughout this project. All of the following prompts were analyzed using the RCTCF framework. All of the AI's suggestions were then manually reviewed and checked against a known, correct response.

## Prompt 1: Variance / Percentage Variance Query Review

**Role:**

You are an expert SQLite developer reviewing my query for correctness, edge cases, and performance.

**Context:**

I have a SQLite database named `bigbasket_capstone.db`, and within it, a table named `category_targets` with two columns: `category` and `target_revenue_inr`. My current query retrieves the total Delivered revenue per category using the `orders` and `products` tables. It joins this result with `category_targets` to compute variance, percentage variance, and status, all based on integer values for `total_revenue` and `target_revenue_inr`.

**Task:**

Critique my provided query for:
- Correctness (logical and syntax)
- Readability
- Performance
- Potential edge cases or bugs

Provide suggested improvements where applicable, adhering to the specified constraints.

**Constraints:**
- The solution must use SQLite syntax.
- The output must include all original columns: `category`, `total_revenue`, `target_revenue_inr`, `variance`, `pct_variance`, and `status`.
- The core functionality (calculating delivered revenue and its deviation from target) must remain unchanged.

**Format:**
- List what is good about the current query.
- List what can be improved.
- Highlight any risks or bugs identified.
- Present the improved query.
- Add any final suggestions for future improvement.
- Include the original query.

### Original Query

```sql
SELECT
    r.category,
    r.total_revenue,
    t.target_revenue_inr,
    (t.target_revenue_inr - r.total_revenue) AS variance,
    ((r.total_revenue - t.target_revenue_inr) * 100.0) / t.target_revenue_inr AS pct_variance,
    CASE
        WHEN r.total_revenue >= t.target_revenue_inr THEN 'Above Target'
        WHEN r.total_revenue >= t.target_revenue_inr * 0.85 THEN 'Below Target - Watch'
        ELSE 'Below Target - Critical'
    END AS status

FROM (
    SELECT
        p.category,
        SUM(o.amount_inr) AS total_revenue

    FROM orders o

    JOIN products p 
    ON o.product_id = p.product_id

    WHERE o.status = 'Delivered'
    GROUP BY p.category
) r
JOIN category_targets t 
ON r.category = t.category;
```

### AI-Improved Query

```sql
WITH category_revenue AS (
    SELECT
        p.category,
        SUM(o.amount_inr) AS total_revenue

    FROM orders o

    JOIN products p 
    ON o.product_id = p.product_id

    WHERE o.status = 'Delivered'
    GROUP BY p.category
)

SELECT
    r.category,
    r.total_revenue,
    t.target_revenue_inr,
    (r.total_revenue - t.target_revenue_inr) AS variance,
    CASE
        WHEN t.target_revenue_inr = 0 THEN NULL
        ELSE ((r.total_revenue - t.target_revenue_inr) * 100.0) / t.target_revenue_inr
    END AS pct_variance,
    CASE
        WHEN r.total_revenue >= t.target_revenue_inr THEN 'Above Target'
        WHEN r.total_revenue >= t.target_revenue_inr * 0.85 THEN 'Below Target - Watch'
        ELSE 'Below Target - Critical'
    END AS status

FROM category_revenue r

JOIN category_targets t 
ON r.category = t.category;
```

### Comparison: Original vs Improved

| Aspect | Original | Improved | Verdict |
|---|---|---|---|
| Readability | Uses a nested subquery in the FROM clause. | Uses a named Common Table Expression (CTE). | Adopted |
| % Variance Calculation | Multiplies by 100.0 for decimal percentage. | Multiplies by 100.0 for decimal percentage. | No change |
| Zero-Target Handling | No protection; division by zero is possible. | Includes CASE to return NULL when `target_revenue_inr` is 0. | Adopted |
| Duplicate Category Risk | Would duplicate if `category_targets` had duplicates. | Same risk. | N/A (Primary Key) |
| Missing Category Risk | INNER JOIN excludes categories without a matching target. | Same behavior. | N/A (Expected) |
| Status Column | Included and correctly formatted. | Included and correctly formatted. | Retained |
| Variance Calculation | `target_revenue_inr - total_revenue`. | `total_revenue - target_revenue_inr`. | Adopted |

**Variance Calculation Change:**

The change from `target_revenue_inr - r.total_revenue` to `r.total_revenue - t.target_revenue_inr` makes the variance column's sign easier to interpret. A positive value now clearly indicates performance exceeding the target, and a negative value indicates underperformance. This is a business logic enhancement rather than a formatting or technical one.

**Verification and Decision:**
- Both the original and improved queries were executed on `bigbasket_capstone.db`.
- The generated output for categories, total revenue, and target revenue remained identical across both queries.
- The `pct_variance` and `status` columns' calculations also matched for non-zero targets.
- The `category_targets` table was inspected and confirmed to have 6 distinct categories with no zero targets, and `category` is its primary key, eliminating duplicate category risks.
- The change in the variance calculation was intentional, and the result was verified for interpretability.
- Based on the review, the improved query was adopted. The CTE significantly enhances readability. While zero-target handling wasn't strictly necessary for the current dataset, it's a good defensive programming practice that was kept.

**Final Suggestions from the AI Review:**
- Employ CTEs: use them for clarity and modularity in complex queries (adopted).
- Add defensive zero-target checks: protect against division by zero, even if the data doesn't currently show zeros (adopted).
- Investigate missing/duplicate keys: always consider the implications of INNER vs. LEFT joins and the uniqueness of joining keys (checked; not an issue here).
- Indexing: for large datasets, ensure appropriate indexes are present on `orders.product_id`, `products.product_id`, and `category_targets.category`. The current dataset is small, so it wasn't an immediate concern.

---

## Prompt 2 — Part 4: IQR Outlier Capping Scope Review

**Role:** You are an experienced Python/Pandas developer reviewing my data-cleaning code for bugs and correctness.

**Context:** I have a cleaned orders DataFrame `clean` with a `status` column (Delivered/Cancelled/Pending) and an `amount_inr` column. I calculate IQR-based outlier bounds and cap high values using `.clip()`.

**Task:** Review my IQR outlier-capping code for correctness and any scope or logic issues.

**Constraints:** Must only apply outlier detection/capping logic to Delivered orders, per the assignment brief. Must preserve row count (capping, not dropping).

**Format:** List what's good, what can be improved, any risks, and a corrected version if needed.

**Original code:**
```python
delivered = clean[clean["status"] == "Delivered"]

Q1 = delivered["amount_inr"].quantile(0.25)
Q3 = delivered["amount_inr"].quantile(0.75)
IQR = Q3 - Q1
upper_fence = Q3 + 1.5 * IQR

print(f"Q1 = {Q1}, Q3 = {Q3}, IQR = {IQR}, upper fence = {upper_fence}")

capped_count = (clean["amount_inr"] > upper_fence).sum()
clean["amount_inr"] = clean["amount_inr"].clip(upper=upper_fence)
print(f"Capped {capped_count} rows")
```

**AI's suggestion:** The IQR formula itself (Q1, Q3, IQR, upper fence) is correctly calculated from the Delivered subset. However, the flagged issue was a scope mismatch: `Q1`/`Q3` are computed only from Delivered orders, but the `capped_count` check and the actual `.clip()` operation are applied to `clean["amount_inr"]` — the entire dataset, including Cancelled and Pending orders. This means a high-value Cancelled or Pending order could get capped even though the fence was never calculated with that population in mind. Suggested fix: scope both the fence calculation and the capping consistently using a `delivered_mask`, so only Delivered rows are ever touched:
```python
delivered_mask = clean["status"] == "Delivered"
Q1 = clean.loc[delivered_mask, "amount_inr"].quantile(0.25)
Q3 = clean.loc[delivered_mask, "amount_inr"].quantile(0.75)
IQR = Q3 - Q1
upper_fence = Q3 + 1.5 * IQR
capped_count = (clean.loc[delivered_mask, "amount_inr"] > upper_fence).sum()
clean.loc[delivered_mask, "amount_inr"] = clean.loc[delivered_mask, "amount_inr"].clip(upper=upper_fence)
```

**Verification performed:** Ran a direct check against my actual cleaned data: `clean[(clean["status"] != "Delivered") & (clean["amount_inr"] > upper_fence)]` returned 0 rows. This confirms that although the original code's scope mismatch was a real bug in principle, no Cancelled or Pending order in this specific dataset actually exceeded the upper fence, so the original capping output (21 rows capped) is numerically unaffected. I kept the corrected, properly-scoped version in my final notebook as the more defensible approach, since it protects against this issue on any future or different dataset even though it didn't change results here.