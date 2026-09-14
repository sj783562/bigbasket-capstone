# BigBasket Category Performance Diagnostic

## Overview
This project analyzes BigBasket category performance against monthly revenue targets using a single, connected diagnostic across four tools: SQLite (SQL), Google Sheets, Tableau Public, and Python/Pandas. The same underlying data is verified three ways — proving consistent numbers survive SQL, spreadsheet, and dashboard reporting untouched — and independently cross-validated a fourth way by cleaning a separate, deliberately messy raw export in Pandas.

## Repository structure
- `generate_data.py` — deterministic data generator (random seed 42). Builds `bigbasket_capstone.db` and the raw Part 4 exports.
- `bigbasket_capstone.db` — SQLite database (31 products, 50 customers, 500 orders, 6 category targets).
- `orders_raw.csv`, `products.csv` — messy raw exports used only in Part 4.
- `verify.sql` — row-count and status-breakdown verification queries.
- `01_foundations.sql` — WHERE, DISTINCT, ORDER BY/LIMIT, Alias, IN, BETWEEN/NOT BETWEEN, IS NULL.
- `02_aggregation_joins.sql` — INNER JOIN + HAVING aggregation; LEFT JOIN preserving zero-order products.
- `03_reporting.sql` — CASE WHEN tiering, monthly category report, target variance analysis.
- `monthly_category_revenue.csv` — exported output of the Part 1 monthly report query (36 rows, grand total ₹88,282). Fixed input for Parts 2 and 3.
- `BigBasket Capstone.xlsx` — Google Sheets workbook: Monthly Data, Category Targets, Pivot Table, and Category Summary (XLOOKUP, variance, nested-IF tiering, conditional formatting, SQL reconciliation).
- `analysis.ipynb` — Jupyter notebook: Pandas cleaning (dedup, casing fixes, missing-value handling, IQR outlier capping), derived columns, groupby/merge analysis, cross-validation against Part 1, 3 visualizations, 3 insights.
- `ai_log.md` — two AI-assisted prompts (RCTCF-structured), one for Part 1 SQL and one for Part 4 Pandas, each with a concrete verification step.
- `DATA_STORY.md` — interpretation of dashboard findings and two recommendations for the category team.

## How to regenerate the data
```bash
python3 generate_data.py
```
Do not modify `random.seed(42)` or any fixed lists — every acceptance number in this project depends on this exact, deterministic output.

## Live Tableau Public dashboard
**[https://public.tableau.com/app/profile/sarthak.joshi8426/viz/BigBasketCapstoneprojectdashboard/Bigbasketcategoryperformance?publish=yes]**

The dashboard includes a monthly revenue trend line, a category revenue bar chart color-coded by target status (green = Above Target, amber = Below Target - Watch, red = Below Target - Critical), 4 KPI cards (Total Revenue, Total Delivered Orders, Average Order Value, Categories Meeting Target), and a category filter that drives every chart on the dashboard.

## Data story
See [`DATA_STORY.md`](./DATA_STORY.md) for the full breakdown of which categories are ahead of and behind target, and two concrete recommendations for BigBasket's category team.

## Cross-validation summary
| Check | Part 1 (SQL) | Part 4 (Python) | Match? |
|---|---|---|---|
| Top category | Household Essentials (₹21,715) | Household Essentials (₹20,910) | Yes — same category, different exact totals due to independent data cleaning |
| Top supplier | HomeEssentials Traders | HomeEssentials Traders | Yes |

Part 4's exact rupee totals differ from Part 1's because Part 4 started from a messier raw export (duplicates, casing issues, missing values, outliers) and applied its own defensible cleaning choices, while Part 1 worked from the already-clean database — this is expected, and documented in `analysis.ipynb`.

## AI-assisted prompting
See [`ai_log.md`](./ai_log.md) for both required RCTCF-structured prompts and their verification steps.
