"""Load the CSVs in data/ into a SQLite database at database/sales.db."""
import sqlite3
from pathlib import Path

import pandas as pd

SCHEMA = """
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    region TEXT NOT NULL,
    signup_date DATE NOT NULL
);
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category TEXT NOT NULL,
    unit_price REAL NOT NULL
);
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    order_date DATE NOT NULL,
    status TEXT NOT NULL
);
CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    unit_price REAL NOT NULL
);
CREATE INDEX idx_orders_date ON orders(order_date);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_items_product ON order_items(product_id);
"""


def main():
    db_path = Path("database/sales.db")
    db_path.parent.mkdir(exist_ok=True)
    if db_path.exists():
        db_path.unlink()
    conn = sqlite3.connect(db_path)
    conn.executescript(SCHEMA)
    for table in ["customers", "products", "orders", "order_items"]:
        df = pd.read_csv(f"data/{table}.csv")
        df.to_sql(table, conn, if_exists="append", index=False)
        print(f"loaded {len(df)} rows into {table}")
    conn.commit()
    conn.close()
    print(f"Database ready at {db_path}")


if __name__ == "__main__":
    main()
