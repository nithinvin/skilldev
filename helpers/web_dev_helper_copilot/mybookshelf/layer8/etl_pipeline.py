#!/usr/bin/env python3
"""
=============================================================================
Layer 8.3 — ETL Pipeline (Extract, Transform, Load)
=============================================================================
PURPOSE: Build a data pipeline that processes raw data into analytics-ready format.
This is what data engineers do: move data between systems, clean it, transform it.

QUESTIONS:
  1. What is ETL?
     Extract: pull data from sources (APIs, databases, files, logs)
     Transform: clean, normalize, enrich, aggregate
     Load: store processed data in a destination (data warehouse, DB, file)

  2. Why not just query the production database directly?
     - Production DB is optimized for writes (OLTP), not analytics (OLAP)
     - Heavy analytics queries slow down the production app
     - Analytics needs data from MULTIPLE sources combined
     - Historical data (production might only keep recent data)

  3. What is a data pipeline?
     Automated, scheduled process: source → transform → destination.
     Runs on a schedule (every hour, daily) or triggered by events.
     Must handle: failures, retries, partial data, schema changes.

  4. What is idempotency?
     Running the pipeline TWICE produces the same result as running it once.
     Critical for reliability: if pipeline crashes halfway, restart safely.

RUN:
  python3 etl_pipeline.py
=============================================================================
"""

import json
import os
import time
import hashlib
from datetime import datetime, timedelta
import random


# =============================================================================
# PART 1: Data Sources (Extract)
# =============================================================================
class BookAPISource:
    """
    Simulates extracting data from an external book API.
    Q: In real ETL, this would call the Google Books API, Open Library, etc.
    """

    def __init__(self):
        self.name = "BookAPI"

    def extract(self, since=None):
        """Extract new/updated books since last run."""
        print(f"    [{self.name}] Extracting books...")
        # Simulated API response
        books = [
            {"isbn": "978-0132350884", "title": "Clean Code", "author": "Robert Martin",
             "pages": 464, "published": "2008-08-01", "categories": ["programming", "software"]},
            {"isbn": "978-1491950357", "title": "DDIA", "author": "Martin Kleppmann",
             "pages": 616, "published": "2017-03-16", "categories": ["systems", "databases"]},
            {"isbn": "978-0596007126", "title": "Head First Design Patterns",
             "author": "Eric Freeman", "pages": 694, "published": "2004-10-25",
             "categories": ["programming", "patterns"]},
            {"isbn": "978-0134685991", "title": "Effective Java", "author": "Joshua Bloch",
             "pages": 416, "published": "2017-12-27", "categories": ["programming", "java"]},
            {"isbn": "978-0201633610", "title": "Design Patterns", "author": "Gang of Four",
             "pages": 395, "published": "1994-10-31", "categories": ["programming", "patterns"]},
        ]
        print(f"    [{self.name}] Extracted {len(books)} books")
        return books


class UserActivitySource:
    """Simulates extracting user activity logs."""

    def __init__(self):
        self.name = "UserActivity"

    def extract(self, since=None):
        """Extract user activity events."""
        print(f"    [{self.name}] Extracting activity logs...")
        random.seed(int(time.time()) % 100)
        activities = []
        actions = ["search", "view", "add_to_list", "start_reading", "finish", "rate"]

        for _ in range(20):
            activities.append({
                "user_id": random.randint(1, 10),
                "action": random.choice(actions),
                "book_isbn": random.choice(["978-0132350884", "978-1491950357", "978-0596007126"]),
                "timestamp": (datetime.now() - timedelta(hours=random.randint(0, 48))).isoformat(),
                "metadata": {"source": random.choice(["web", "mobile", "api"])},
            })

        print(f"    [{self.name}] Extracted {len(activities)} events")
        return activities


# =============================================================================
# PART 2: Transformations
# =============================================================================
class Transformer:
    """
    Data transformations: clean, normalize, enrich, validate.
    Q: Raw data is MESSY. Transformations make it usable for analytics.
    """

    @staticmethod
    def clean_book(raw_book):
        """
        Clean and normalize a raw book record.
        Q: Real data has: missing fields, wrong types, inconsistent formats,
        duplicates, invalid values. Cleaning handles all of these.
        """
        # Normalize author name
        author = raw_book.get("author", "Unknown").strip()

        # Parse and validate publication date
        pub_date = raw_book.get("published", "")
        try:
            year = int(pub_date[:4]) if pub_date else None
        except (ValueError, IndexError):
            year = None

        # Validate pages
        pages = raw_book.get("pages", 0)
        if not isinstance(pages, int) or pages < 1:
            pages = None  # Mark as missing, don't guess

        # Normalize categories (lowercase, deduplicate)
        categories = raw_book.get("categories", [])
        categories = list(set(c.lower().strip() for c in categories))

        # Generate a consistent ID from ISBN
        isbn = raw_book.get("isbn", "")
        record_id = hashlib.md5(isbn.encode()).hexdigest()[:12] if isbn else None
        # Q: Why hash the ISBN? Creates a consistent, short ID.
        # Same ISBN always produces the same ID (idempotent!).

        return {
            "id": record_id,
            "isbn": isbn,
            "title": raw_book.get("title", "").strip(),
            "author": author,
            "year": year,
            "pages": pages,
            "categories": categories,
            "extracted_at": datetime.now().isoformat(),
        }

    @staticmethod
    def clean_activity(raw_event):
        """Clean a user activity event."""
        return {
            "user_id": raw_event["user_id"],
            "action": raw_event["action"].lower().strip(),
            "book_isbn": raw_event.get("book_isbn"),
            "timestamp": raw_event["timestamp"],
            "source": raw_event.get("metadata", {}).get("source", "unknown"),
        }

    @staticmethod
    def compute_aggregates(activities):
        """
        Compute summary statistics from activity data.
        Q: This is the "T" in ETL — transforming raw events into useful metrics.
        """
        from collections import Counter

        # Action counts
        action_counts = Counter(a["action"] for a in activities)

        # Active users
        active_users = len(set(a["user_id"] for a in activities))

        # Source breakdown
        source_counts = Counter(a["source"] for a in activities)

        # Most viewed books
        views = [a["book_isbn"] for a in activities if a["action"] == "view"]
        popular_books = Counter(views).most_common(5)

        return {
            "period": datetime.now().strftime("%Y-%m-%d"),
            "total_events": len(activities),
            "active_users": active_users,
            "action_breakdown": dict(action_counts),
            "source_breakdown": dict(source_counts),
            "top_books": popular_books,
            "computed_at": datetime.now().isoformat(),
        }

    @staticmethod
    def validate(record, schema):
        """
        Validate a record against a schema.
        Q: Bad data in → bad insights out. Validate BEFORE loading!
        """
        errors = []
        for field, rules in schema.items():
            value = record.get(field)
            if rules.get("required") and value is None:
                errors.append(f"Missing required field: {field}")
            if value is not None and "type" in rules:
                if not isinstance(value, rules["type"]):
                    errors.append(f"Wrong type for {field}: expected {rules['type'].__name__}")
            if value is not None and "min" in rules:
                if value < rules["min"]:
                    errors.append(f"{field} below minimum ({value} < {rules['min']})")
        return errors


# =============================================================================
# PART 3: Load (Write to destination)
# =============================================================================
class JSONFileLoader:
    """
    Load processed data to JSON files (simulating a data warehouse).
    Q: In production, this would be: PostgreSQL, BigQuery, Snowflake, S3, etc.
    """

    def __init__(self, output_dir="etl_output"):
        self.output_dir = output_dir

    def load(self, data, table_name):
        """Write data to a JSON file (simulating database insert)."""
        # Create output directory
        os.makedirs(self.output_dir, exist_ok=True)

        filepath = os.path.join(self.output_dir, f"{table_name}.json")

        # Append mode — don't overwrite previous data
        existing = []
        if os.path.exists(filepath):
            with open(filepath, "r") as f:
                existing = json.load(f)

        # Deduplicate by ID (idempotency!)
        # Q: If pipeline runs twice, don't insert duplicates.
        existing_ids = {r.get("id") or r.get("isbn") for r in existing}
        new_records = [r for r in data if (r.get("id") or r.get("isbn")) not in existing_ids]

        all_records = existing + new_records
        with open(filepath, "w") as f:
            json.dump(all_records, f, indent=2, default=str)

        print(f"    [Loader] Wrote {len(new_records)} new records to {filepath} "
              f"(total: {len(all_records)})")
        return len(new_records)


# =============================================================================
# PART 4: Pipeline Orchestration
# =============================================================================
class ETLPipeline:
    """
    Orchestrates the full ETL process.
    Q: A pipeline = sequence of steps with error handling, logging, and state.
    """

    def __init__(self):
        self.sources = {
            "books": BookAPISource(),
            "activity": UserActivitySource(),
        }
        self.transformer = Transformer()
        self.loader = JSONFileLoader()
        self.stats = {"extracted": 0, "transformed": 0, "loaded": 0, "errors": 0}

    def run(self):
        """Execute the full pipeline."""
        start_time = time.time()
        print("\n" + "=" * 60)
        print("  ETL PIPELINE: Starting run")
        print(f"  Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 60)

        try:
            # === EXTRACT ===
            print("\n  [EXTRACT] Pulling data from sources...")
            raw_books = self.sources["books"].extract()
            raw_activities = self.sources["activity"].extract()
            self.stats["extracted"] = len(raw_books) + len(raw_activities)

            # === TRANSFORM ===
            print("\n  [TRANSFORM] Cleaning and enriching data...")

            # Transform books
            clean_books = []
            book_schema = {
                "title": {"required": True, "type": str},
                "author": {"required": True, "type": str},
                "year": {"type": int, "min": 1800},
            }
            for raw in raw_books:
                cleaned = self.transformer.clean_book(raw)
                errors = self.transformer.validate(cleaned, book_schema)
                if errors:
                    print(f"    ⚠ Validation errors for '{raw.get('title')}': {errors}")
                    self.stats["errors"] += 1
                else:
                    clean_books.append(cleaned)

            # Transform activities
            clean_activities = [self.transformer.clean_activity(a) for a in raw_activities]

            # Compute aggregates
            daily_stats = self.transformer.compute_aggregates(clean_activities)

            self.stats["transformed"] = len(clean_books) + len(clean_activities)
            print(f"    Transformed: {len(clean_books)} books, {len(clean_activities)} activities")

            # === LOAD ===
            print("\n  [LOAD] Writing to destination...")
            loaded_books = self.loader.load(clean_books, "books")
            loaded_activities = self.loader.load(clean_activities, "activities")
            self.loader.load([daily_stats], "daily_stats")
            self.stats["loaded"] = loaded_books + loaded_activities

            # === SUMMARY ===
            elapsed = time.time() - start_time
            print("\n" + "=" * 60)
            print("  ETL PIPELINE: Complete!")
            print(f"  Duration: {elapsed:.2f}s")
            print(f"  Extracted: {self.stats['extracted']} records")
            print(f"  Transformed: {self.stats['transformed']} records")
            print(f"  Loaded: {self.stats['loaded']} new records")
            print(f"  Errors: {self.stats['errors']}")
            print("=" * 60)

            return True

        except Exception as e:
            print(f"\n  ✗ PIPELINE FAILED: {e}")
            # Q: In production: send alert, log error, enable retry.
            # Never silently fail — you'll have stale data and not know it.
            return False


# =============================================================================
# MAIN
# =============================================================================
def main():
    print("""
  ─── ETL PIPELINE CONCEPTS ───

  EXTRACT         TRANSFORM           LOAD
  ┌─────────┐    ┌─────────────┐    ┌─────────────┐
  │ Book API │──→ │ Clean       │──→ │ Data        │
  │ User Logs│    │ Validate    │    │ Warehouse   │
  │ Database │    │ Enrich      │    │ (analytics) │
  │ CSV files│    │ Aggregate   │    │             │
  └─────────┘    └─────────────┘    └─────────────┘

  KEY PRINCIPLES:
  • Idempotent: run twice = same result (no duplicates)
  • Observable: log everything, alert on failures
  • Testable: validate at each stage
  • Recoverable: crash → restart from last checkpoint
    """)

    pipeline = ETLPipeline()
    success = pipeline.run()

    if success:
        # Show what was produced
        output_dir = "etl_output"
        if os.path.exists(output_dir):
            print(f"\n  Output files in ./{output_dir}/:")
            for f in sorted(os.listdir(output_dir)):
                filepath = os.path.join(output_dir, f)
                size = os.path.getsize(filepath)
                print(f"    {f} ({size} bytes)")

    print("""
  ─── REAL-WORLD ETL TOOLS ───
  • Apache Airflow: schedule and monitor pipelines (DAGs)
  • dbt: SQL-based transformations (ELT pattern)
  • Apache Spark: distributed processing for BIG data
  • Luigi / Prefect / Dagster: Python pipeline orchestration
  • AWS Glue / GCP Dataflow: managed cloud ETL

  ─── ELT vs ETL ───
  ETL: Transform before loading (traditional)
  ELT: Load raw data first, transform in the warehouse (modern)
  Why ELT? Cloud warehouses (BigQuery, Snowflake) are powerful.
  Store everything raw → transform with SQL later → more flexible.
    """)


if __name__ == "__main__":
    main()
