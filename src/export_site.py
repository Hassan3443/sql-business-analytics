"""Prepare docs/ for the live SQL playground (GitHub Pages).

Copies database/sales.db and writes docs/queries.json from queries/*.sql.
The first comment line(s) of each file become the description.
Usage: python src/export_site.py
"""
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"


def describe(sql: str) -> str:
    lines = []
    for line in sql.splitlines():
        if line.startswith("--"):
            lines.append(line[2:].strip())
        else:
            break
    return " ".join(lines)


def main():
    DOCS.mkdir(exist_ok=True)
    shutil.copyfile(ROOT / "database" / "sales.db", DOCS / "sales.db")
    queries = []
    for path in sorted((ROOT / "queries").glob("*.sql")):
        sql = path.read_text().strip()
        number, _, name = path.stem.partition("_")
        queries.append({"id": path.stem, "number": int(number), "title": name.replace("_", " ").capitalize(),
                        "description": describe(sql), "sql": sql})
    (DOCS / "queries.json").write_text(json.dumps(queries, indent=1), encoding="utf-8")
    print(f"exported {len(queries)} queries and the database to docs/")


if __name__ == "__main__":
    main()
