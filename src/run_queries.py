"""Run every .sql file in queries/ against database/sales.db.

Each query writes its result to results/<query_name>.csv and the run prints a
summary table. Usage: python src/run_queries.py
"""
import sqlite3
from pathlib import Path

import pandas as pd


def main():
    conn = sqlite3.connect("database/sales.db")
    Path("results").mkdir(exist_ok=True)
    for sql_file in sorted(Path("queries").glob("*.sql")):
        df = pd.read_sql_query(sql_file.read_text(), conn)
        out = Path("results") / (sql_file.stem + ".csv")
        df.to_csv(out, index=False)
        print(f"== {sql_file.stem} -> {out} ({len(df)} rows)")
        print(df.head(10).to_string(index=False))
        print()
    conn.close()


if __name__ == "__main__":
    main()
