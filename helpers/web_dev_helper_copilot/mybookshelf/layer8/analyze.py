#!/usr/bin/env python3
"""
=============================================================================
Layer 8.2 — Data Analysis with Python (No External Libraries!)
=============================================================================
PURPOSE: Analyze the MyBookShelf dataset. Statistics, trends, correlations.
Built from scratch to understand what pandas/numpy do under the hood.

QUESTIONS:
  1. What is data analysis?
     Extracting insights from data: patterns, trends, anomalies.
     "Which books get abandoned?" "Do longer books get lower ratings?"
     "What reading patterns predict 5-star reviews?"

  2. What are descriptive statistics?
     Numbers that SUMMARIZE a dataset: mean, median, mode, std dev, percentiles.
     They answer: "What does the data look like?" before any modeling.

  3. What is correlation?
     Measures how two variables move together.
     +1 = perfect positive (more pages → higher rating)
     -1 = perfect negative (more pages → lower rating)
      0 = no relationship

  4. What is the difference between correlation and causation?
     Correlation: ice cream sales and drowning deaths both increase in summer.
     Causation: ice cream does NOT cause drowning. Summer (heat) causes both.
     NEVER say "X causes Y" from correlation alone. Need experiments.

RUN:
  python3 analyze.py
=============================================================================
"""

import math
import random
from collections import Counter


# =============================================================================
# PART 1: Generate Rich Dataset
# =============================================================================
def generate_dataset(n=500):
    """Generate a rich book reading dataset for analysis."""
    random.seed(42)
    genres = ["programming", "fiction", "science", "history", "self-help"]
    data = []

    for i in range(n):
        genre = random.choice(genres)
        pages = {
            "programming": random.gauss(400, 100),
            "fiction": random.gauss(300, 80),
            "science": random.gauss(500, 120),
            "history": random.gauss(450, 100),
            "self-help": random.gauss(250, 60),
        }[genre]
        pages = max(100, int(pages))

        year = int(random.gauss(2010, 10))
        year = max(1980, min(2024, year))

        # Rating is influenced by genre, pages, and year (with noise)
        base_rating = {
            "programming": 4.0, "fiction": 3.8, "science": 4.2,
            "history": 3.7, "self-help": 3.5,
        }[genre]
        rating = base_rating + random.gauss(0, 0.5) - 0.001 * (pages - 300)
        rating = max(1.0, min(5.0, round(rating, 1)))

        # Reading time (days) — longer books take longer
        days_to_read = pages / random.gauss(30, 10) + random.gauss(0, 3)
        days_to_read = max(1, int(days_to_read))

        # Completion rate — longer books get abandoned more
        completion = min(1.0, max(0.0, 1.0 - 0.0005 * (pages - 200) + random.gauss(0, 0.15)))

        data.append({
            "id": i + 1,
            "genre": genre,
            "pages": pages,
            "year": year,
            "rating": rating,
            "days_to_read": days_to_read,
            "completion_rate": round(completion, 2),
        })

    return data


# =============================================================================
# PART 2: Descriptive Statistics (from scratch)
# =============================================================================
def mean(values):
    """Arithmetic mean."""
    return sum(values) / len(values) if values else 0


def median(values):
    """
    Middle value when sorted.
    Q: Why median? Mean is sensitive to outliers.
    Mean salary in a room with Jeff Bezos = billions. Median = normal salary.
    """
    sorted_vals = sorted(values)
    n = len(sorted_vals)
    if n % 2 == 1:
        return sorted_vals[n // 2]
    return (sorted_vals[n // 2 - 1] + sorted_vals[n // 2]) / 2


def mode(values):
    """Most frequent value."""
    counter = Counter(values)
    return counter.most_common(1)[0][0] if counter else None


def std_dev(values):
    """
    Standard deviation — average distance from the mean.
    Q: Low std = data clustered near mean. High std = data spread out.
    """
    avg = mean(values)
    variance = sum((x - avg) ** 2 for x in values) / len(values)
    return math.sqrt(variance)


def percentile(values, p):
    """P-th percentile (0-100)."""
    sorted_vals = sorted(values)
    idx = (p / 100) * (len(sorted_vals) - 1)
    lower = int(idx)
    frac = idx - lower
    if lower + 1 < len(sorted_vals):
        return sorted_vals[lower] * (1 - frac) + sorted_vals[lower + 1] * frac
    return sorted_vals[lower]


def correlation(x_values, y_values):
    """
    Pearson correlation coefficient.
    Q: Measures LINEAR relationship between two variables.
    +1 = perfect positive, -1 = perfect negative, 0 = no linear relationship.
    """
    n = len(x_values)
    mean_x = mean(x_values)
    mean_y = mean(y_values)

    numerator = sum((x - mean_x) * (y - mean_y) for x, y in zip(x_values, y_values))
    denom_x = math.sqrt(sum((x - mean_x) ** 2 for x in x_values))
    denom_y = math.sqrt(sum((y - mean_y) ** 2 for y in y_values))

    if denom_x == 0 or denom_y == 0:
        return 0
    return numerator / (denom_x * denom_y)


# =============================================================================
# PART 3: Analysis Functions
# =============================================================================
def analyze_by_genre(data):
    """Group-by analysis: statistics per genre."""
    print("\n  === ANALYSIS BY GENRE ===\n")
    print(f"  {'Genre':<12} {'Count':>6} {'Avg Rating':>11} {'Avg Pages':>10} "
          f"{'Avg Days':>9} {'Completion':>11}")
    print("  " + "-" * 65)

    genres = sorted(set(d["genre"] for d in data))
    for genre in genres:
        genre_data = [d for d in data if d["genre"] == genre]
        ratings = [d["rating"] for d in genre_data]
        pages = [d["pages"] for d in genre_data]
        days = [d["days_to_read"] for d in genre_data]
        completion = [d["completion_rate"] for d in genre_data]

        print(f"  {genre:<12} {len(genre_data):>6} {mean(ratings):>11.2f} "
              f"{mean(pages):>10.0f} {mean(days):>9.1f} {mean(completion):>10.1%}")


def analyze_correlations(data):
    """Find correlations between variables."""
    print("\n  === CORRELATIONS ===\n")
    print("  Q: Correlation ≠ causation! These show relationships, not causes.\n")

    pages = [d["pages"] for d in data]
    ratings = [d["rating"] for d in data]
    days = [d["days_to_read"] for d in data]
    completion = [d["completion_rate"] for d in data]
    years = [d["year"] for d in data]

    pairs = [
        ("Pages", "Rating", pages, ratings),
        ("Pages", "Days to Read", pages, days),
        ("Pages", "Completion Rate", pages, completion),
        ("Year", "Rating", years, ratings),
        ("Days to Read", "Rating", days, ratings),
    ]

    for name_x, name_y, x, y in pairs:
        r = correlation(x, y)
        strength = "strong" if abs(r) > 0.5 else "moderate" if abs(r) > 0.3 else "weak"
        direction = "positive" if r > 0 else "negative"
        bar = "█" * int(abs(r) * 20)
        print(f"  {name_x:>15} vs {name_y:<17}: r={r:+.3f} ({strength} {direction}) {bar}")


def analyze_distribution(data, field, title):
    """Show distribution of a field (text histogram)."""
    values = [d[field] for d in data]

    print(f"\n  === DISTRIBUTION: {title} ===\n")
    print(f"  Count:  {len(values)}")
    print(f"  Mean:   {mean(values):.2f}")
    print(f"  Median: {median(values):.2f}")
    print(f"  Std:    {std_dev(values):.2f}")
    print(f"  Min:    {min(values):.2f}")
    print(f"  Max:    {max(values):.2f}")
    print(f"  P25:    {percentile(values, 25):.2f}")
    print(f"  P75:    {percentile(values, 75):.2f}")

    # Text histogram
    print(f"\n  Histogram:")
    n_bins = 10
    min_val = min(values)
    max_val = max(values)
    bin_width = (max_val - min_val) / n_bins if max_val > min_val else 1

    bins = [0] * n_bins
    for v in values:
        idx = min(int((v - min_val) / bin_width), n_bins - 1)
        bins[idx] += 1

    max_count = max(bins)
    for i, count in enumerate(bins):
        left = min_val + i * bin_width
        right = left + bin_width
        bar = "█" * int(count / max_count * 30) if max_count > 0 else ""
        print(f"  [{left:6.1f}-{right:6.1f}] {bar} ({count})")


def find_anomalies(data):
    """Find outliers using IQR method."""
    print("\n  === ANOMALY DETECTION ===\n")
    print("  Q: Outliers = data points far from the norm. Could be errors OR insights.\n")

    for field in ["rating", "pages", "days_to_read"]:
        values = [d[field] for d in data]
        q1 = percentile(values, 25)
        q3 = percentile(values, 75)
        iqr = q3 - q1
        # Q: IQR method — standard way to detect outliers.
        # Below Q1 - 1.5×IQR or above Q3 + 1.5×IQR = outlier.
        lower_bound = q1 - 1.5 * iqr
        upper_bound = q3 + 1.5 * iqr

        outliers = [d for d in data if d[field] < lower_bound or d[field] > upper_bound]
        print(f"  {field}: {len(outliers)} outliers "
              f"(bounds: [{lower_bound:.1f}, {upper_bound:.1f}])")
        if outliers[:3]:
            for o in outliers[:3]:
                print(f"    → id={o['id']}, {field}={o[field]}, genre={o['genre']}")


def top_n_analysis(data, n=5):
    """Find interesting extremes."""
    print(f"\n  === TOP/BOTTOM {n} ===\n")

    # Highest rated
    by_rating = sorted(data, key=lambda d: d["rating"], reverse=True)
    print(f"  Highest rated books:")
    for d in by_rating[:n]:
        print(f"    #{d['id']:3d}: rating={d['rating']:.1f}, "
              f"genre={d['genre']}, pages={d['pages']}")

    # Fastest reads (pages per day)
    for d in data:
        d["pages_per_day"] = d["pages"] / d["days_to_read"] if d["days_to_read"] > 0 else 0

    by_speed = sorted(data, key=lambda d: d["pages_per_day"], reverse=True)
    print(f"\n  Fastest reads (pages/day):")
    for d in by_speed[:n]:
        print(f"    #{d['id']:3d}: {d['pages_per_day']:.1f} pages/day, "
              f"{d['pages']} pages in {d['days_to_read']} days")

    # Most abandoned (lowest completion)
    by_completion = sorted(data, key=lambda d: d["completion_rate"])
    print(f"\n  Most abandoned books:")
    for d in by_completion[:n]:
        print(f"    #{d['id']:3d}: {d['completion_rate']:.0%} completed, "
              f"{d['pages']} pages, genre={d['genre']}")


# =============================================================================
# MAIN
# =============================================================================
def main():
    print("\n" + "=" * 60)
    print("  DATA ANALYSIS: MyBookShelf Reading Patterns")
    print("  All from scratch — no pandas, no numpy!")
    print("=" * 60)

    data = generate_dataset(500)
    print(f"\n  Dataset: {len(data)} books")
    print(f"  Fields: genre, pages, year, rating, days_to_read, completion_rate")

    analyze_by_genre(data)
    analyze_correlations(data)
    analyze_distribution(data, "rating", "Book Ratings")
    analyze_distribution(data, "pages", "Page Count")
    find_anomalies(data)
    top_n_analysis(data)

    print("\n" + "=" * 60)
    print("  KEY INSIGHTS")
    print("=" * 60)
    print("""
  From this analysis, we can tell the product team:
  1. Science books are rated highest but take longest to read
  2. Longer books have lower completion rates (consider splitting?)
  3. Self-help books are shortest but have lowest ratings
  4. There's a negative correlation between pages and completion
  5. Year of publication barely affects rating (readers like old AND new)

  ─── WHAT YOU'D DO IN THE REAL WORLD ───
  • Use pandas for DataFrames (df.groupby('genre').mean())
  • Use matplotlib/seaborn for visualizations
  • Use scipy for statistical tests (is this correlation significant?)
  • Use jupyter notebooks for interactive exploration
  • Present findings to stakeholders with clear visualizations
    """)


if __name__ == "__main__":
    main()
