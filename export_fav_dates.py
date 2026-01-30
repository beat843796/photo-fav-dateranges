#!/usr/bin/env python3
import argparse
import csv
import datetime as dt
import sqlite3
from typing import Iterable


APPLE_EPOCH = dt.datetime(2001, 1, 1, tzinfo=dt.timezone.utc)
DEFAULT_DB_PATH = "db_copy/Photos.sqlite"


def apple_time_to_iso(seconds: float) -> str:
    # Photos stores timestamps as seconds since 2001-01-01 (UTC).
    stamp = APPLE_EPOCH + dt.timedelta(seconds=seconds)
    return stamp.strftime("%Y-%m-%dT%H:%M:%SZ")


def fetch_dates(conn: sqlite3.Connection, include_videos: bool) -> Iterable[float]:
    if include_videos:
        sql = """
            SELECT ZDATECREATED
            FROM ZASSET
            WHERE ZFAVORITE = 1 AND ZDATECREATED IS NOT NULL
            ORDER BY ZDATECREATED
        """
        params = ()
    else:
        sql = """
            SELECT ZDATECREATED
            FROM ZASSET
            WHERE ZFAVORITE = 1 AND ZDATECREATED IS NOT NULL AND ZKIND = 0
            ORDER BY ZDATECREATED
        """
        params = ()

    cur = conn.execute(sql, params)
    for (value,) in cur:
        if value is None:
            continue
        yield float(value)


def write_csv(path: str, iso_dates: Iterable[str]) -> None:
    with open(path, "w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle)
        for iso in iso_dates:
            writer.writerow([iso])


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Export ISO-8601 creation dates of favorite images from Photos.sqlite."
    )
    parser.add_argument(
        "--db",
        default=None,
        help="Path to Photos.sqlite (default: hardcoded in script).",
    )
    parser.add_argument(
        "--out",
        default="fav_dates.csv",
        help="Output CSV path (default: fav_dates.csv).",
    )
    parser.add_argument(
        "--include-videos",
        action="store_true",
        help="Include favorites that are videos (skip ZKIND filter).",
    )
    args = parser.parse_args()

    db_path = args.db or DEFAULT_DB_PATH

    conn = sqlite3.connect(db_path)
    try:
        iso_dates = (apple_time_to_iso(v) for v in fetch_dates(conn, args.include_videos))
        write_csv(args.out, iso_dates)
    finally:
        conn.close()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
