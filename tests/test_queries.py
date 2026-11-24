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
