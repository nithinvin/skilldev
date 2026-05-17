# Layer 8: Data Analytics

> **Goal**: Extract insights from MyBookShelf data. Build ETL pipelines, dashboards, and think statistically.
> **Pre-req**: Layer 7 complete — ML models, LLM integration, MCP server.
> **Why?** Every system generates data. Knowing how to collect, transform, analyze, and visualize it is what separates "it works" from "we understand our users."

---

## Level 8.1 — What Is Data Analytics?

### Questions to Answer First
1. What's the difference between data analytics and data science?
2. What is ETL (Extract, Transform, Load)? Why is it a pipeline?
3. What is a data warehouse? How is it different from an operational database?
4. What is the difference between descriptive, diagnostic, predictive, and prescriptive analytics?
5. What is a metric? What is a KPI?

### Theory (Concise)
```
Data Flow:
  Source (PostgreSQL, APIs, logs) → Extract → Transform → Load → Warehouse → Analyze → Visualize

Types of Analytics:
  Descriptive:  What happened?     (dashboards, reports)
  Diagnostic:   Why did it happen? (drill-down, root cause)
  Predictive:   What will happen?  (ML models, forecasting)
  Prescriptive: What should we do? (optimization, recommendations)
```

---

## Level 8.2 — SQL Analytics: Querying for Insights

### Questions to Answer First
1. What are window functions in SQL? Why are they powerful?
2. What is a CTE (Common Table Expression)? When do you use it?
3. What is GROUP BY + HAVING vs WHERE? When to use each?

### Hands-On: Analytics Queries on MyBookShelf
```sql
-- file: mybookshelf/analytics/queries.sql

-- 1. Basic stats
SELECT
    COUNT(*) as total_books,
    ROUND(AVG(rating), 2) as avg_rating,
    MIN(year) as oldest_book,
    MAX(year) as newest_book
FROM books;

-- 2. Rating distribution
SELECT
    rating,
    COUNT(*) as count,
    ROUND(COUNT(*)::numeric / (SELECT COUNT(*) FROM books) * 100, 1) as percentage
FROM books
GROUP BY rating
ORDER BY rating DESC;

-- 3. Books per decade
SELECT
    (year / 10) * 10 as decade,
    COUNT(*) as book_count,
    ROUND(AVG(rating), 2) as avg_rating
FROM books
GROUP BY decade
ORDER BY decade;

-- 4. Window function: rank books by rating within each decade
SELECT
    title,
    year,
    rating,
    (year / 10) * 10 as decade,
    RANK() OVER (PARTITION BY (year / 10) * 10 ORDER BY rating DESC) as rank_in_decade
FROM books;

-- 5. CTE: Find authors with above-average ratings
WITH author_stats AS (
    SELECT
        a.name as author,
        COUNT(b.id) as book_count,
        ROUND(AVG(b.rating), 2) as avg_rating
    FROM authors a
    JOIN books b ON a.id = b.author_id
    GROUP BY a.name
),
overall_avg AS (
    SELECT AVG(rating) as avg FROM books
)
SELECT
    author,
    book_count,
    avg_rating
FROM author_stats, overall_avg
WHERE avg_rating > overall_avg.avg
ORDER BY avg_rating DESC;

-- 6. Running total: cumulative books added over time
SELECT
    DATE(created_at) as date_added,
    COUNT(*) as books_added,
    SUM(COUNT(*)) OVER (ORDER BY DATE(created_at)) as cumulative_total
FROM books
GROUP BY DATE(created_at)
ORDER BY date_added;

-- 7. User activity: most active readers/reviewers
SELECT
    u.username,
    COUNT(DISTINCT b.id) as books_added,
    ROUND(AVG(b.rating), 2) as avg_rating_given,
    MAX(b.created_at) as last_active
FROM users u
JOIN books b ON b.added_by = u.id   -- (add this column to your schema!)
GROUP BY u.username
ORDER BY books_added DESC;
```

---

## Level 8.3 — Python Analytics: Pandas & Visualization

### Questions to Answer First
1. What is Pandas? How does a DataFrame relate to a SQL table?
2. What is matplotlib? What is seaborn? When to use which?
3. What makes a good visualization? (Tufte's principles)

### Hands-On: Analyze MyBookShelf Data
```python
# file: mybookshelf/analytics/analyze.py
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from db import get_db

# Extract data
conn = get_db()
books_df = pd.read_sql("SELECT * FROM books", conn)
conn.close()

print(books_df.describe())
print(books_df.info())

# --- Rating Distribution ---
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# 1. Rating histogram
axes[0,0].hist(books_df['rating'], bins=5, edgecolor='black', color='#3498db')
axes[0,0].set_title('Rating Distribution')
axes[0,0].set_xlabel('Rating')
axes[0,0].set_ylabel('Count')

# 2. Books by decade
books_df['decade'] = (books_df['year'] // 10) * 10
decade_counts = books_df.groupby('decade').size()
axes[0,1].bar(decade_counts.index.astype(str), decade_counts.values, color='#2ecc71')
axes[0,1].set_title('Books by Decade')
axes[0,1].set_xlabel('Decade')
axes[0,1].tick_params(axis='x', rotation=45)

# 3. Rating vs Year scatter
axes[1,0].scatter(books_df['year'], books_df['rating'], alpha=0.6, color='#e74c3c')
axes[1,0].set_title('Rating vs Publication Year')
axes[1,0].set_xlabel('Year')
axes[1,0].set_ylabel('Rating')

# 4. Top authors
if 'author' in books_df.columns:
    top_authors = books_df['author'].value_counts().head(10)
    axes[1,1].barh(top_authors.index, top_authors.values, color='#9b59b6')
    axes[1,1].set_title('Top 10 Authors by Book Count')
    axes[1,1].invert_yaxis()

plt.tight_layout()
plt.savefig('analytics_dashboard.png', dpi=150)
plt.show()

# --- Interesting Questions ---
# Q: Is there a correlation between publication year and rating?
correlation = books_df['year'].corr(books_df['rating'])
print(f"\nYear-Rating correlation: {correlation:.3f}")

# Q: Which decade has the highest average rating?
print("\nAverage rating by decade:")
print(books_df.groupby('decade')['rating'].mean().sort_values(ascending=False))
```

---

## Level 8.4 — ETL Pipeline: Extract, Transform, Load

### Questions to Answer First
1. Why not just query the production database for analytics?
2. What is the difference between batch and stream processing?
3. What is data cleaning? Why does it take 80% of a data engineer's time?

### Hands-On: Simple ETL Pipeline
```python
# file: mybookshelf/analytics/etl.py
"""ETL pipeline: Extract from DB, Transform, Load into analytics tables."""
import pandas as pd
from db import get_db
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def extract():
    """Extract raw data from operational database."""
    logger.info("Extracting data...")
    conn = get_db()

    books = pd.read_sql("SELECT * FROM books", conn)
    users = pd.read_sql("SELECT * FROM users", conn)

    conn.close()
    logger.info(f"Extracted {len(books)} books, {len(users)} users")
    return books, users

def transform(books, users):
    """Clean and transform data for analytics."""
    logger.info("Transforming data...")

    # Clean: handle nulls
    books['rating'] = books['rating'].fillna(0)
    books['year'] = books['year'].fillna(0).astype(int)

    # Enrich: add computed columns
    books['decade'] = (books['year'] // 10) * 10
    books['rating_category'] = pd.cut(books['rating'],
        bins=[0, 2, 3, 4, 5],
        labels=['Poor', 'Average', 'Good', 'Excellent']
    )
    books['age'] = datetime.now().year - books['year']

    # Aggregate: create summary tables
    rating_summary = books.groupby('rating_category').agg(
        count=('id', 'count'),
        avg_year=('year', 'mean')
    ).reset_index()

    decade_summary = books.groupby('decade').agg(
        count=('id', 'count'),
        avg_rating=('rating', 'mean'),
        min_rating=('rating', 'min'),
        max_rating=('rating', 'max')
    ).reset_index()

    logger.info(f"Created {len(rating_summary)} rating categories, {len(decade_summary)} decades")
    return books, rating_summary, decade_summary

def load(books, rating_summary, decade_summary):
    """Load transformed data into analytics tables."""
    logger.info("Loading data...")
    conn = get_db()
    cur = conn.cursor()

    # Create analytics schema
    cur.execute("CREATE SCHEMA IF NOT EXISTS analytics")

    # Load using pandas to_sql (or raw SQL)
    books.to_sql('books_enriched', conn, schema='analytics', if_exists='replace', index=False)
    rating_summary.to_sql('rating_summary', conn, schema='analytics', if_exists='replace', index=False)
    decade_summary.to_sql('decade_summary', conn, schema='analytics', if_exists='replace', index=False)

    # Record ETL run
    cur.execute("""
        CREATE TABLE IF NOT EXISTS analytics.etl_runs (
            id SERIAL PRIMARY KEY,
            run_at TIMESTAMP DEFAULT NOW(),
            books_processed INTEGER,
            status VARCHAR(20)
        )
    """)
    cur.execute(
        "INSERT INTO analytics.etl_runs (books_processed, status) VALUES (%s, %s)",
        (len(books), 'success')
    )

    conn.commit()
    cur.close()
    conn.close()
    logger.info("ETL complete!")

def run_etl():
    """Execute full ETL pipeline."""
    try:
        books, users = extract()
        books, rating_summary, decade_summary = transform(books, users)
        load(books, rating_summary, decade_summary)
    except Exception as e:
        logger.error(f"ETL failed: {e}")
        raise

if __name__ == '__main__':
    run_etl()
```

### Schedule ETL with Cron
```bash
# Run ETL every hour
crontab -e
# Add: 0 * * * * cd /home/user/mybookshelf && /home/user/mybookshelf/venv/bin/python analytics/etl.py >> /tmp/etl.log 2>&1
```

---

## Level 8.5 — Dashboard: Analytics API + Visualization

### Hands-On: Analytics API Endpoints
```python
# file: mybookshelf/analytics/api.py
from flask import Blueprint, jsonify
from db import get_db

analytics_bp = Blueprint('analytics', __name__, url_prefix='/api/analytics')

@analytics_bp.route('/overview')
def overview():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT
            COUNT(*) as total_books,
            ROUND(AVG(rating)::numeric, 2) as avg_rating,
            COUNT(DISTINCT author) as unique_authors,
            MIN(year) as oldest_year,
            MAX(year) as newest_year
        FROM books
    """)
    stats = dict(cur.fetchone())
    cur.close()
    conn.close()
    return jsonify(stats)

@analytics_bp.route('/trends')
def trends():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT
            (year / 10) * 10 as decade,
            COUNT(*) as count,
            ROUND(AVG(rating)::numeric, 2) as avg_rating
        FROM books
        WHERE year IS NOT NULL
        GROUP BY decade
        ORDER BY decade
    """)
    trends = [dict(row) for row in cur.fetchall()]
    cur.close()
    conn.close()
    return jsonify(trends)

@analytics_bp.route('/top-rated')
def top_rated():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT title, author, year, rating FROM books ORDER BY rating DESC, year DESC LIMIT 10")
    books = [dict(row) for row in cur.fetchall()]
    cur.close()
    conn.close()
    return jsonify(books)
```

### Simple Dashboard (HTML + Chart.js)
```html
<!-- file: mybookshelf/templates/dashboard.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>MyBookShelf Analytics</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { font-family: sans-serif; max-width: 1200px; margin: 0 auto; padding: 20px; }
        .stats { display: flex; gap: 20px; margin: 20px 0; }
        .stat-card { background: #f8f9fa; border-radius: 8px; padding: 20px; flex: 1; text-align: center; }
        .stat-card h3 { color: #666; margin: 0; }
        .stat-card .value { font-size: 2rem; font-weight: bold; color: #2c3e50; }
        .charts { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .chart-container { background: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <h1>📊 MyBookShelf Analytics</h1>

    <div class="stats" id="stats"></div>

    <div class="charts">
        <div class="chart-container">
            <canvas id="trendsChart"></canvas>
        </div>
        <div class="chart-container">
            <canvas id="ratingChart"></canvas>
        </div>
    </div>

    <script>
        // Fetch and render overview stats
        fetch('/api/analytics/overview')
            .then(r => r.json())
            .then(data => {
                document.getElementById('stats').innerHTML = `
                    <div class="stat-card"><h3>Total Books</h3><div class="value">${data.total_books}</div></div>
                    <div class="stat-card"><h3>Avg Rating</h3><div class="value">${data.avg_rating}⭐</div></div>
                    <div class="stat-card"><h3>Authors</h3><div class="value">${data.unique_authors}</div></div>
                    <div class="stat-card"><h3>Year Range</h3><div class="value">${data.oldest_year}–${data.newest_year}</div></div>
                `;
            });

        // Fetch and render trends chart
        fetch('/api/analytics/trends')
            .then(r => r.json())
            .then(data => {
                new Chart(document.getElementById('trendsChart'), {
                    type: 'bar',
                    data: {
                        labels: data.map(d => d.decade + 's'),
                        datasets: [{
                            label: 'Books per Decade',
                            data: data.map(d => d.count),
                            backgroundColor: '#3498db'
                        }]
                    },
                    options: { plugins: { title: { display: true, text: 'Books by Decade' } } }
                });
            });

        // Rating distribution
        fetch('/api/analytics/top-rated')
            .then(r => r.json())
            .then(data => {
                new Chart(document.getElementById('ratingChart'), {
                    type: 'horizontalBar' in Chart.defaults ? 'horizontalBar' : 'bar',
                    data: {
                        labels: data.map(d => d.title.substring(0, 25)),
                        datasets: [{
                            label: 'Rating',
                            data: data.map(d => d.rating),
                            backgroundColor: '#2ecc71'
                        }]
                    },
                    options: {
                        indexAxis: 'y',
                        plugins: { title: { display: true, text: 'Top Rated Books' } },
                        scales: { x: { min: 0, max: 5 } }
                    }
                });
            });
    </script>
</body>
</html>
```

---

## Level 8.6 — Statistical Thinking

### Questions to Answer First
1. What is the difference between correlation and causation?
2. What is a p-value? What does "statistically significant" mean?
3. What is sampling bias? Selection bias?
4. What is A/B testing? How do you determine if a change is actually better?

### Hands-On: Basic Statistics
```python
# file: mybookshelf/analytics/statistics.py
import numpy as np
from scipy import stats

# Simulated data: reading time vs rating
np.random.seed(42)
reading_time = np.random.normal(10, 3, 100)   # hours
ratings = 0.3 * reading_time + np.random.normal(3, 0.5, 100)
ratings = np.clip(ratings, 1, 5)

# Correlation
r, p_value = stats.pearsonr(reading_time, ratings)
print(f"Correlation: r={r:.3f}, p-value={p_value:.6f}")
print(f"Statistically significant? {'Yes' if p_value < 0.05 else 'No'}")
# Q: Does correlation prove that longer reading → higher rating?

# A/B test: Does the new recommendation algorithm increase engagement?
group_a = np.random.normal(5.2, 1.5, 50)   # Control: avg 5.2 books/month
group_b = np.random.normal(5.8, 1.5, 50)   # Treatment: avg 5.8 books/month

t_stat, p_value = stats.ttest_ind(group_a, group_b)
print(f"\nA/B Test: t={t_stat:.3f}, p-value={p_value:.4f}")
print(f"New algorithm better? {'Yes (significant)' if p_value < 0.05 else 'Not enough evidence'}")
```

---

## Checkpoint Questions (Final)

1. What is ETL? Draw a pipeline for MyBookShelf data.
2. Write a SQL window function query and explain what it does.
3. What is the difference between a data warehouse and an operational database?
4. Create a Pandas DataFrame from a SQL query and compute 3 meaningful statistics.
5. What is the difference between correlation and causation? Give an example.
6. What is A/B testing? Design an A/B test for a new feature in MyBookShelf.
7. Build the analytics dashboard and explain each chart's insight.

---

## What's Next?

Congratulations — you've built a full-stack application from the ground up:

```
Layer 0: You understand the machine (Linux, networking, TCP/IP)
Layer 1: You can build what users see (HTML, CSS, JS)
Layer 2: You can store and serve data (Flask, PostgreSQL)
Layer 3: You can expose APIs and control access (REST, JWT, OAuth)
Layer 4: You can package and automate (Docker, CI/CD)
Layer 5: You can deploy and scale (Cloud, Kubernetes, microservices)
Layer 6: You can protect it (crypto, TLS, OWASP)
Layer 7: You can make it intelligent (ML, LLMs, MCP)
Layer 8: You can understand your data (analytics, statistics, dashboards)
```

### Keep Going
- **Contribute to open source** — find projects on GitHub that interest you
- **Build something real** — a project YOU want to use
- **Read code** — study how PostgreSQL, Redis, Flask are implemented
- **Teach someone** — explaining forces you to truly understand

---

**Previous**: [Layer 7 — ML, Deep Learning & LLMs](layer7-ml-dl-llms.md)
**Back to**: [Roadmap](../ROADMAP.md)
