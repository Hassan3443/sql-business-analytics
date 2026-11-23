# SQL Business Analytics

A relational sales database (SQLite) loaded from raw CSVs, plus a set of SQL queries that answer the questions a business actually asks: revenue trends, top customers, category and region performance, fulfillment health, repeat purchase behavior and cohort value.

Built to show practical SQL for analytics: multi-table joins, aggregations, window-free cohort logic, CTEs, subqueries and date functions, all runnable end to end with one command.

## The data

Four tables built from generated CSVs (1,200 customers, 25 products, 2,187 orders, 3,330 line items over 2024-2025):

```
customers (customer_id, name, region, signup_date)
products  (product_id, product_name, category, unit_price)
orders    (order_id, customer_id, order_date, status)
order_items (item_id, order_id, product_id, quantity, unit_price)
```

## Business questions answered

| Query | Question |
| --- | --- |
| `01_monthly_revenue.sql` | How does delivered revenue trend month over month? |
| `02_top_customers.sql` | Who are the top 10 customers by lifetime revenue? |
| `03_category_performance.sql` | Which categories drive revenue and units sold? |
| `04_region_analysis.sql` | How do regions compare on revenue and average order value? |
| `05_repeat_purchase_rate.sql` | What share of customers ordered more than once? |
| `06_cancel_return_rates.sql` | How healthy is fulfillment (delivered / shipped / cancelled / returned)? |
| `07_top_products.sql` | Which products sell the most units? |
| `08_customer_cohort_revenue.sql` | Do older signup cohorts spend more per customer? |

## Headline results

- **Electronics** is 51% of delivered revenue; Books just 4.5%
- **Cairo** leads on revenue (1.64M EGP) but **Alexandria** has the highest average order value (2,863 EGP)
- **64%** of customers are repeat buyers
- Fulfillment: 78.6% delivered, 5.2% cancelled, 3.9% returned

Full result tables in [results/](results/).

## Project structure

```
sql-business-analytics/
├── data/                    # source CSVs (synthetic, reproducible)
├── database/sales.db        # built SQLite database
├── queries/                 # one .sql file per business question
├── results/                 # query output CSVs
├── src/
│   ├── generate_data.py     # regenerates the CSVs (fixed seed)
│   ├── build_db.py          # schema + CSV loader
│   └── run_queries.py       # runs all queries, exports results
└── requirements.txt
```

## Run it

```bash
pip install -r requirements.txt
python src/generate_data.py   # optional: CSVs are included
python src/build_db.py        # build database/sales.db
python src/run_queries.py     # run every query in queries/
```

## Tools

SQL (SQLite), Python, Pandas

## Note on the data

The dataset is synthetic, generated with a fixed random seed so every number above reproduces exactly. The schema mirrors a standard e-commerce export, so pointing `build_db.py` at real CSVs with the same columns needs no code changes.

## Author

Hassan Ashraf - [github.com/Hassan3443](https://github.com/Hassan3443)
