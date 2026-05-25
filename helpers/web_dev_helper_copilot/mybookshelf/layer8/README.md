# Layer 8: Data Analytics & Visualization

## What You'll Learn
- SQL analytics (window functions, CTEs, cohort analysis, funnels)
- Python data analysis (statistics, correlations, distributions — from scratch)
- ETL pipelines (Extract, Transform, Load — data engineering)
- Dashboard design (KPIs, visualization, actionable insights)

## File Structure

```
mybookshelf/layer8/
├── queries.sql             ← Advanced SQL: window functions, CTEs, funnels
├── analyze.py              ← Statistics from scratch: mean, std, correlation
├── etl_pipeline.py         ← Data pipeline: extract → transform → load
├── dashboard.py            ← Terminal-based analytics dashboard
├── README.md               ← This file
└── checkpoint_quiz.py      ← Self-test: 15 questions
```

## Study Order

1. **queries.sql** — learn window functions, CTEs, cohort analysis
2. **analyze.py** — understand statistics and correlations from scratch
3. **etl_pipeline.py** — understand how data moves between systems
4. **dashboard.py** — see how data becomes actionable insights

## Key Concepts

### Data Roles in Tech

| Role | Focus | Tools |
|------|-------|-------|
| Data Analyst | Answer business questions | SQL, Excel, Tableau |
| Data Engineer | Build pipelines, move data | Python, Airflow, Spark |
| Data Scientist | Build ML models | Python, R, sklearn |
| Analytics Engineer | Transform data (dbt) | SQL, dbt, git |

### The Analytics Stack

```
Sources          →   Pipeline    →   Warehouse    →   Visualization
─────────────────────────────────────────────────────────────────
Production DB         Airflow         BigQuery         Grafana
API logs              dbt             Snowflake        Metabase
User events           Spark           PostgreSQL       Streamlit
Third-party APIs      Kafka           Redshift         Custom dashboards
```

## Running the Files

```bash
cd mybookshelf/layer8

# SQL queries (need PostgreSQL)
psql -d mybookshelf -f queries.sql

# Python analysis (no dependencies!)
python3 analyze.py
python3 etl_pipeline.py
python3 dashboard.py
python3 checkpoint_quiz.py
```

## Connection to All Layers
- **Layer 0** → Linux/networking fundamentals for server management
- **Layer 1** → Dashboard could be a web frontend
- **Layer 2** → PostgreSQL stores the data we analyze
- **Layer 3** → APIs serve analytics results
- **Layer 4** → Pipelines run in Docker containers
- **Layer 5** → Deployed to cloud, monitoring production
- **Layer 6** → Data privacy, access control on analytics
- **Layer 7** → ML models consume analyzed/cleaned data
