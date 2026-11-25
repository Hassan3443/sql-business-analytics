"""Smoke and correctness tests: every query runs and key invariants hold."""
import sqlite3
import subprocess
import sys
from pathlib import Path

import pandas as pd
import pytest

ROOT = Path(__file__).resolve().parents[1]


@pytest.fixture(scope="module")
def conn():
    subprocess.run([sys.executable, "src/build_db.py"], cwd=ROOT, check=True, capture_output=True)
    c = sqlite3.connect(ROOT / "database" / "sales.db")
    yield c
    c.close()


QUERIES = sorted((ROOT / "queries").glob("*.sql"))


@pytest.mark.parametrize("path", QUERIES, ids=[q.stem for q in QUERIES])
def test_query_runs_and_returns_rows(conn, path):
    df = pd.read_sql_query(path.read_text(), conn)
    assert len(df) > 0


def run(conn, name):
    return pd.read_sql_query((ROOT / "queries" / f"{name}.sql").read_text(), conn)


def test_running_total_ends_at_total_revenue(conn):
    monthly = run(conn, "01_monthly_revenue")
    running = run(conn, "09_running_total_revenue")
    assert running["cumulative_revenue"].iloc[-1] == pytest.approx(monthly["revenue"].sum(), rel=1e-6)
    assert running["pct_of_total"].sum() == pytest.approx(100, abs=0.5)


def test_mom_growth_first_month_is_null(conn):
    df = run(conn, "10_mom_growth")
    assert pd.isna(df["mom_growth_pct"].iloc[0])


def test_top_products_at_most_three_per_category(conn):
    df = run(conn, "11_top_products_per_category")
    assert df.groupby("category").size().max() <= 3


def test_deciles_cover_all_customers_and_revenue(conn):
    df = run(conn, "12_customer_spend_deciles")
    assert len(df) == 10
    assert df["pct_of_revenue"].sum() == pytest.approx(100, abs=0.5)
    assert df["revenue"].is_monotonic_decreasing


def test_region_shares_sum_to_100(conn):
    df = run(conn, "15_region_share_and_rank")
    assert df["pct_of_total"].sum() == pytest.approx(100, abs=0.5)
    assert df["gap_to_leader"].iloc[0] == 0


def test_lifetime_value_matches_delivered_revenue(conn):
    ltv = run(conn, "17_customer_lifetime_value")
    monthly = run(conn, "01_monthly_revenue")
    assert ltv["lifetime_value"].sum() == pytest.approx(monthly["revenue"].sum(), rel=1e-4)
    assert set(ltv["value_tier"]) == {"Top 25%", "Upper middle", "Lower middle", "Bottom 25%"}
    assert ltv["lifetime_value"].is_monotonic_decreasing


def test_products_bought_together_pairs_are_ordered_and_distinct(conn):
    df = run(conn, "18_products_bought_together")
    assert (df["product_a"] != df["product_b"]).all()
    assert df["orders_together"].is_monotonic_decreasing


def test_customers_at_risk_are_repeat_buyers_and_inactive(conn):
    df = run(conn, "19_customers_at_risk")
    assert (df["delivered_orders"] >= 2).all()
    assert (df["days_since_last_order"] > 90).all()


def test_basket_shares_sum_to_100_and_value_grows_with_items(conn):
    df = run(conn, "20_basket_size_and_value")
    assert df["pct_of_orders"].sum() == pytest.approx(100, abs=0.5)
    assert df["avg_order_value"].is_monotonic_increasing


def test_category_mix_adds_up(conn):
    df = run(conn, "21_category_mix_by_region")
    assert (df[["electronics_pct", "books_pct", "other_pct"]].sum(axis=1)).between(99.7, 100.3).all()


def test_site_export_matches_queries(conn):
    import json
    subprocess.run([sys.executable, "src/export_site.py"], cwd=ROOT, check=True, capture_output=True)
    exported = json.loads((ROOT / "docs" / "queries.json").read_text())
    assert [q["id"] for q in exported] == [p.stem for p in QUERIES]
    assert (ROOT / "docs" / "sales.db").stat().st_size > 0
