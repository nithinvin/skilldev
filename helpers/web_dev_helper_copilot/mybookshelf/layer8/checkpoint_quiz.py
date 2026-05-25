#!/usr/bin/env python3
"""
=============================================================================
Layer 8 Checkpoint Quiz — Data Analytics & Visualization
=============================================================================
Score 12/15 to complete the entire MyBookShelf learning roadmap!
Run: python3 checkpoint_quiz.py
=============================================================================
"""

QUESTIONS = [
    {
        "q": "What is the difference between OLTP and OLAP?",
        "options": [
            "A) OLTP is faster than OLAP",
            "B) OLTP handles individual transactions (INSERT/GET). OLAP handles analytical queries (aggregations over millions of rows).",
            "C) OLAP is a newer version of OLTP",
            "D) They are the same thing with different names",
        ],
        "answer": "B",
        "explain": "OLTP: 'Get book #42' (fast, single row). OLAP: 'Average rating by genre over 5 years' "
                   "(slow, scans millions of rows). Different optimization goals.",
    },
    {
        "q": "What does a SQL window function do?",
        "options": [
            "A) Opens a new window in the database tool",
            "B) Computes a value across a set of rows related to the current row WITHOUT collapsing them",
            "C) Filters rows like WHERE",
            "D) Joins two tables together",
        ],
        "answer": "B",
        "explain": "RANK() OVER (PARTITION BY genre ORDER BY rating DESC): ranks each book within its genre. "
                   "Unlike GROUP BY, every row is kept in the result.",
    },
    {
        "q": "What is a CTE (Common Table Expression)?",
        "options": [
            "A) A permanent database table",
            "B) A named temporary result set (WITH clause) that makes complex queries readable",
            "C) A type of index",
            "D) A stored procedure",
        ],
        "answer": "B",
        "explain": "WITH monthly AS (SELECT ...) SELECT * FROM monthly. Like a variable for SQL. "
                   "Makes nested subqueries readable and reusable within the query.",
    },
    {
        "q": "What is ETL?",
        "options": [
            "A) A programming language",
            "B) Extract (pull data from sources), Transform (clean/enrich), Load (write to destination)",
            "C) A type of database",
            "D) A testing framework",
        ],
        "answer": "B",
        "explain": "Data pipeline pattern: API/DB/logs → clean, validate, aggregate → data warehouse. "
                   "Runs on schedule (hourly/daily). Airflow, dbt, Spark are common tools.",
    },
    {
        "q": "Why is idempotency important in data pipelines?",
        "options": [
            "A) It makes pipelines faster",
            "B) Running the pipeline twice produces the same result as once (safe to retry on failure)",
            "C) It reduces storage costs",
            "D) It improves data quality",
        ],
        "answer": "B",
        "explain": "Pipeline crashes at step 3 of 5. Restart → steps 1-2 rerun. Without idempotency: "
                   "duplicate records. With: same data, no duplicates. Critical for reliability.",
    },
    {
        "q": "What does Pearson correlation coefficient (r) measure?",
        "options": [
            "A) The average of two variables",
            "B) The strength and direction of LINEAR relationship between two variables",
            "C) Whether one variable causes another",
            "D) The distance between data points",
        ],
        "answer": "B",
        "explain": "r=+1: perfect positive linear relationship. r=-1: perfect negative. r=0: no linear relationship. "
                   "Does NOT measure causation or non-linear relationships!",
    },
    {
        "q": "What is the difference between mean and median?",
        "options": [
            "A) They are always the same",
            "B) Mean = average (sensitive to outliers). Median = middle value (robust to outliers).",
            "C) Median is more accurate",
            "D) Mean only works with integers",
        ],
        "answer": "B",
        "explain": "Salaries: [30k, 35k, 40k, 45k, 10M]. Mean = 2M (misleading!). "
                   "Median = 40k (representative). Use median when outliers exist.",
    },
    {
        "q": "What is cohort analysis?",
        "options": [
            "A) Analyzing the total user base",
            "B) Grouping users by when they joined and tracking their behavior over time",
            "C) Comparing different products",
            "D) A/B testing",
        ],
        "answer": "B",
        "explain": "Cohort = users who started in the same week. Track: of Jan users, how many "
                   "are still active in Feb? Mar? Shows true retention, not just total users.",
    },
    {
        "q": "What is a funnel analysis?",
        "options": [
            "A) A visualization shaped like a funnel",
            "B) Tracking where users drop off in a sequence of steps (search→view→add→rate)",
            "C) Filtering data through multiple criteria",
            "D) A type of JOIN",
        ],
        "answer": "B",
        "explain": "1000 search → 500 view → 100 add → 20 rate. Where's the biggest drop? "
                   "search→view (50% stay) vs view→add (20% stay). Fix the biggest drop first.",
    },
    {
        "q": "What makes a good KPI (Key Performance Indicator)?",
        "options": [
            "A) Any metric that can be measured",
            "B) A metric that is actionable, relevant to business goals, and can be influenced",
            "C) The most complex metric available",
            "D) A metric that always goes up",
        ],
        "answer": "B",
        "explain": "Good KPI: 'Weekly active users' (actionable: improve onboarding to increase it). "
                   "Bad KPI: 'Total page views ever' (vanity metric, always increases, not actionable).",
    },
    {
        "q": "What is the IQR method for detecting outliers?",
        "options": [
            "A) Remove any value > 100",
            "B) Values below Q1-1.5×IQR or above Q3+1.5×IQR are outliers (IQR = Q3 - Q1)",
            "C) Any value more than 2× the average",
            "D) The top and bottom 10% of values",
        ],
        "answer": "B",
        "explain": "IQR = interquartile range (middle 50% of data). Values far outside this range "
                   "are statistical outliers. Could be errors (fix) or genuine extremes (investigate).",
    },
    {
        "q": "Why should you NOT query the production database for analytics?",
        "options": [
            "A) Production databases don't support SQL",
            "B) Heavy analytics queries can slow down the production app (affect real users)",
            "C) Analytics data is always inaccurate",
            "D) It's against company policy",
        ],
        "answer": "B",
        "explain": "Production DB is optimized for fast INSERT/SELECT of single rows (OLTP). "
                   "Analytics query scanning millions of rows = locks, slowdowns, timeouts for real users.",
    },
    {
        "q": "What does 'correlation does not imply causation' mean?",
        "options": [
            "A) Correlations are unreliable",
            "B) Two variables moving together doesn't prove one CAUSES the other (could be a third factor)",
            "C) You need more data for causation",
            "D) Causation is stronger than correlation",
        ],
        "answer": "B",
        "explain": "Ice cream sales ↑ and drowning ↑ correlate. Does ice cream cause drowning? No! "
                   "Summer (heat) causes both. Need controlled experiments to prove causation.",
    },
    {
        "q": "What is the purpose of data validation in an ETL pipeline?",
        "options": [
            "A) To make the pipeline faster",
            "B) To catch bad/missing/incorrect data BEFORE it enters the warehouse (garbage in → garbage out)",
            "C) To compress the data",
            "D) To encrypt sensitive data",
        ],
        "answer": "B",
        "explain": "Raw data is messy: missing fields, wrong types, invalid values. "
                   "Validate at each stage. Reject bad records with logging. Bad data → wrong insights → bad decisions.",
    },
    {
        "q": "What is standard deviation?",
        "options": [
            "A) The middle value in a dataset",
            "B) The average distance of data points from the mean (measures spread/variability)",
            "C) The most common value",
            "D) The range between min and max",
        ],
        "answer": "B",
        "explain": "Low std dev: data clustered near the mean (consistent). "
                   "High std dev: data spread out (variable). Ratings with std=0.1 → everyone agrees. Std=1.5 → polarizing book.",
    },
]


def run_quiz():
    print("\n" + "=" * 60)
    print("  LAYER 8 CHECKPOINT: Data Analytics & Visualization")
    print("  Score 12/15 to COMPLETE the MyBookShelf roadmap!")
    print("=" * 60)

    score = 0
    for i, q in enumerate(QUESTIONS, 1):
        print(f"\nQ{i}. {q['q']}")
        for opt in q["options"]:
            print(f"    {opt}")

        while True:
            ans = input(f"\n  Your answer (A/B/C/D): ").strip().upper()
            if ans in ("A", "B", "C", "D"):
                break
            print("  Please enter A, B, C, or D.")

        if ans == q["answer"]:
            score += 1
            print(f"  ✓ Correct!")
        else:
            print(f"  ✗ Wrong. Answer: {q['answer']}")
        print(f"  → {q['explain']}")

    print("\n" + "=" * 60)
    print(f"  SCORE: {score}/15")
    if score >= 12:
        print("  ✓ CONGRATULATIONS! You've completed all 9 layers!")
        print("  ")
        print("  Layer 0: Linux & Networking         ✓")
        print("  Layer 1: HTML, CSS, JavaScript      ✓")
        print("  Layer 2: Backend & Databases         ✓")
        print("  Layer 3: APIs & Authentication       ✓")
        print("  Layer 4: Docker & CI/CD              ✓")
        print("  Layer 5: Cloud & Microservices       ✓")
        print("  Layer 6: Security & Cryptography     ✓")
        print("  Layer 7: ML, DL & LLMs              ✓")
        print("  Layer 8: Data Analytics              ✓")
        print("  ")
        print("  You now have a COMPLETE mental model of modern software.")
        print("  Next: go deeper in any layer that excites you!")
    else:
        print("  ✗ Review the material and try again.")
        print("  Focus on: ETL concepts, window functions, statistics basics")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    run_quiz()
