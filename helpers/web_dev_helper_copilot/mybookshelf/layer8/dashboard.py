#!/usr/bin/env python3
"""
=============================================================================
Layer 8.4 — Dashboard: Text-based Data Visualization
=============================================================================
PURPOSE: Create a terminal-based analytics dashboard for MyBookShelf.
Shows how to visualize data without external libraries (matplotlib/plotly).

QUESTIONS:
  1. Why visualize data?
     Humans are visual. A chart reveals patterns that tables of numbers hide.
     "A picture is worth a thousand rows."

  2. What makes a good dashboard?
     - Shows the MOST IMPORTANT metrics first (KPIs)
     - Updates in real-time (or near real-time)
     - Actionable: looking at it tells you what to DO next
     - Simple: 5-7 key metrics, not 50

  3. What are KPIs (Key Performance Indicators)?
     Metrics that matter most to the business:
     - Daily Active Users (DAU)
     - Books added per week
     - Average session duration
     - Completion rate (started → finished)
     - User retention (% coming back next week)

RUN:
  python3 dashboard.py
=============================================================================
"""

import random
import math
from datetime import datetime, timedelta


# =============================================================================
# VISUALIZATION HELPERS
# =============================================================================
def bar_chart(data, title, max_width=40):
    """Horizontal bar chart in terminal."""
    print(f"\n  ┌{'─' * (max_width + 20)}┐")
    print(f"  │ {title:<{max_width + 18}} │")
    print(f"  ├{'─' * (max_width + 20)}┤")

    if not data:
        print(f"  │ {'(no data)':<{max_width + 18}} │")
        print(f"  └{'─' * (max_width + 20)}┘")
        return

    max_val = max(v for _, v in data)
    for label, value in data:
        bar_len = int((value / max_val) * max_width) if max_val > 0 else 0
        bar = "█" * bar_len
        line = f"  {label:>12} │{bar} {value}"
        print(f"  │ {line:<{max_width + 18}} │")

    print(f"  └{'─' * (max_width + 20)}┘")


def sparkline(values, width=20):
    """Tiny inline chart using Unicode blocks."""
    if not values:
        return ""
    min_val = min(values)
    max_val = max(values)
    range_val = max_val - min_val if max_val != min_val else 1
    blocks = " ▁▂▃▄▅▆▇█"

    result = ""
    step = max(1, len(values) // width)
    for i in range(0, len(values), step):
        chunk = values[i:i+step]
        avg = sum(chunk) / len(chunk)
        idx = int((avg - min_val) / range_val * 8)
        result += blocks[idx]

    return result


def line_chart(data_points, title, height=10, width=50):
    """ASCII line chart."""
    print(f"\n  {title}")
    print(f"  {'─' * (width + 8)}")

    if not data_points:
        print("  (no data)")
        return

    values = [v for _, v in data_points]
    min_val = min(values)
    max_val = max(values)
    range_val = max_val - min_val if max_val != min_val else 1

    # Create grid
    grid = [[" " for _ in range(width)] for _ in range(height)]

    # Plot points
    for i, (_, val) in enumerate(data_points):
        x = int(i / len(data_points) * (width - 1))
        y = int((val - min_val) / range_val * (height - 1))
        y = height - 1 - y  # Flip (row 0 = top)
        grid[y][x] = "●"

    # Connect points (simple)
    for row_idx, row in enumerate(grid):
        y_val = max_val - (row_idx / (height - 1)) * range_val
        print(f"  {y_val:6.1f} │{''.join(row)}│")

    print(f"  {'':>6} └{'─' * width}┘")
    if data_points:
        print(f"  {'':>7}{data_points[0][0]:<{width//2}}{data_points[-1][0]:>{width//2}}")


def table(headers, rows, title=None):
    """Pretty-print a table."""
    if title:
        print(f"\n  {title}")

    # Calculate column widths
    col_widths = [len(h) for h in headers]
    for row in rows:
        for i, cell in enumerate(row):
            col_widths[i] = max(col_widths[i], len(str(cell)))

    # Header
    header_line = "  │ " + " │ ".join(h.ljust(col_widths[i]) for i, h in enumerate(headers)) + " │"
    separator = "  ├─" + "─┼─".join("─" * w for w in col_widths) + "─┤"
    top_border = "  ┌─" + "─┬─".join("─" * w for w in col_widths) + "─┐"
    bottom_border = "  └─" + "─┴─".join("─" * w for w in col_widths) + "─┘"

    print(top_border)
    print(header_line)
    print(separator)
    for row in rows:
        line = "  │ " + " │ ".join(str(cell).ljust(col_widths[i]) for i, cell in enumerate(row)) + " │"
        print(line)
    print(bottom_border)


# =============================================================================
# GENERATE DASHBOARD DATA
# =============================================================================
def generate_dashboard_data():
    """Generate realistic dashboard metrics."""
    random.seed(42)
    now = datetime.now()

    # Daily metrics for last 14 days
    daily_metrics = []
    base_dau = 150
    for i in range(14):
        day = now - timedelta(days=13 - i)
        # Weekends have more activity
        weekend_boost = 1.3 if day.weekday() >= 5 else 1.0
        dau = int(base_dau * weekend_boost + random.gauss(0, 20))
        books_added = random.randint(5, 25)
        searches = int(dau * random.gauss(3, 0.5))
        ratings = random.randint(10, 50)

        daily_metrics.append({
            "date": day.strftime("%m/%d"),
            "dau": dau,
            "books_added": books_added,
            "searches": searches,
            "ratings_given": ratings,
        })
        base_dau += random.gauss(2, 1)  # Slight growth trend

    # Genre distribution
    genre_data = [
        ("programming", 342),
        ("fiction", 289),
        ("science", 201),
        ("history", 178),
        ("self-help", 156),
        ("biography", 134),
        ("philosophy", 89),
    ]

    # User retention cohorts
    retention = {
        "Week 1": 100,
        "Week 2": 68,
        "Week 3": 52,
        "Week 4": 41,
        "Week 8": 28,
        "Week 12": 22,
    }

    # Reading speed distribution
    reading_speeds = [random.gauss(30, 10) for _ in range(200)]  # pages/day

    return {
        "daily": daily_metrics,
        "genres": genre_data,
        "retention": retention,
        "reading_speeds": reading_speeds,
        "total_users": 1847,
        "total_books": 12453,
        "total_ratings": 45672,
        "avg_rating": 3.94,
    }


# =============================================================================
# RENDER DASHBOARD
# =============================================================================
def render_dashboard():
    """Render the full analytics dashboard."""
    data = generate_dashboard_data()
    now = datetime.now().strftime("%Y-%m-%d %H:%M")

    # === HEADER ===
    print("\n")
    print("  ╔══════════════════════════════════════════════════════════════╗")
    print("  ║           📚 MyBookShelf Analytics Dashboard                ║")
    print(f"  ║           Last updated: {now}                  ║")
    print("  ╠══════════════════════════════════════════════════════════════╣")

    # === KPI SUMMARY ===
    daily = data["daily"]
    today = daily[-1]
    yesterday = daily[-2]
    dau_change = today["dau"] - yesterday["dau"]
    dau_arrow = "↑" if dau_change > 0 else "↓" if dau_change < 0 else "→"

    print(f"  ║  Users: {data['total_users']:,}  │  Books: {data['total_books']:,}  "
          f"│  Ratings: {data['total_ratings']:,}  │  Avg: {data['avg_rating']:.2f}★  ║")
    print(f"  ║  Today: DAU={today['dau']} ({dau_arrow}{abs(dau_change)})  "
          f"│  Searches={today['searches']}  │  New ratings={today['ratings_given']}     ║")
    print("  ╚══════════════════════════════════════════════════════════════╝")

    # === DAU TREND (sparkline) ===
    dau_values = [d["dau"] for d in daily]
    spark = sparkline(dau_values, width=14)
    print(f"\n  DAU Trend (14 days): {spark}  "
          f"[min={min(dau_values)}, max={max(dau_values)}, avg={sum(dau_values)//len(dau_values)}]")

    # === GENRE DISTRIBUTION (bar chart) ===
    bar_chart(data["genres"], "Books by Genre")

    # === DAU LINE CHART ===
    dau_points = [(d["date"], d["dau"]) for d in daily]
    line_chart(dau_points, "Daily Active Users (14 days)")

    # === RETENTION FUNNEL ===
    retention_data = [(k, v) for k, v in data["retention"].items()]
    bar_chart(retention_data, "User Retention (% of cohort still active)")

    # === TOP METRICS TABLE ===
    table_rows = [
        [d["date"], str(d["dau"]), str(d["books_added"]),
         str(d["searches"]), str(d["ratings_given"])]
        for d in daily[-7:]  # Last 7 days
    ]
    table(
        ["Date", "DAU", "Books+", "Searches", "Ratings"],
        table_rows,
        title="Last 7 Days Detail"
    )

    # === READING SPEED DISTRIBUTION ===
    speeds = data["reading_speeds"]
    print(f"\n  Reading Speed Distribution (pages/day):")
    print(f"  Mean: {sum(speeds)/len(speeds):.1f}  |  "
          f"Median: {sorted(speeds)[len(speeds)//2]:.1f}  |  "
          f"P90: {sorted(speeds)[int(len(speeds)*0.9)]:.1f}")

    # Histogram
    buckets = [0] * 10
    for s in speeds:
        idx = min(9, max(0, int(s / 10)))
        buckets[idx] += 1
    max_bucket = max(buckets)
    print(f"  {'0':>3} {'10':>3} {'20':>3} {'30':>3} {'40':>3} {'50':>3} {'60':>3} {'70':>3} {'80':>3} {'90+':>3}")
    bars = " ".join("█" * max(1, int(b / max_bucket * 5)) if b > 0 else "·" for b in buckets)
    print(f"   {bars}")

    # === INSIGHTS ===
    print(f"""
  ┌────────────────────────────────────────────────────────────────┐
  │ INSIGHTS & RECOMMENDATIONS                                     │
  ├────────────────────────────────────────────────────────────────┤
  │ 1. DAU is trending UP (+{dau_change}/day) — growth is healthy        │
  │ 2. Weekend DAU is ~30% higher — consider weekend promotions    │
  │ 3. Retention drops 32% in Week 2 — focus on onboarding        │
  │ 4. Programming is top genre — feature it on homepage           │
  │ 5. Avg reading speed: 30 pages/day — set realistic goals      │
  └────────────────────────────────────────────────────────────────┘
    """)


# =============================================================================
# MAIN
# =============================================================================
def main():
    render_dashboard()

    print("""
  ─── DASHBOARD DESIGN PRINCIPLES ───
  1. KPIs at the top (what matters most?)
  2. Trends over time (is it getting better or worse?)
  3. Comparisons (vs yesterday, vs last week, vs goal)
  4. Actionable insights (so what? what should we DO?)
  5. Drill-down capability (click for details)

  ─── REAL TOOLS ───
  • Grafana: time-series dashboards (server metrics)
  • Metabase: SQL-based business dashboards
  • Streamlit: Python dashboards (data science)
  • Apache Superset: open-source BI platform
  • Custom: React + D3.js / Chart.js for web dashboards
    """)


if __name__ == "__main__":
    main()
