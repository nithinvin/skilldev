-- =============================================================================
-- Layer 8.1 — SQL Analytics Queries for MyBookShelf
-- =============================================================================
--
-- QUESTIONS:
--   1. What is the difference between OLTP and OLAP?
--      OLTP (Online Transaction Processing): INSERT one book, GET one book.
--        Fast for individual operations. Your Layer 2-3 API queries.
--      OLAP (Online Analytical Processing): "What genre grew fastest last year?"
--        Scans millions of rows. Slow for single queries but answers BIG questions.
--
--   2. What is a window function?
--      A function that computes a value across a SET of rows related to the current row.
--      Unlike GROUP BY (which collapses rows), window functions KEEP every row.
--      Example: "rank each book within its genre by rating"
--
--   3. What is a CTE (Common Table Expression)?
--      WITH clause — like a temporary named subquery. Makes complex queries readable.
--      Think of it as a variable for SQL queries.
--
-- RUN: psql -d mybookshelf -f queries.sql
-- Or copy individual queries into psql/pgAdmin.
-- =============================================================================

-- === SETUP: Create analytics tables ===
-- These extend our basic books table with user activity data.

CREATE TABLE IF NOT EXISTS reading_log (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL REFERENCES books(id),
    started_at DATE,
    finished_at DATE,
    pages_read INTEGER DEFAULT 0,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5)
);

CREATE TABLE IF NOT EXISTS user_activity (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    action VARCHAR(50) NOT NULL,  -- 'search', 'view', 'add_to_list', 'rate'
    book_id INTEGER REFERENCES books(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed some analytics data
INSERT INTO reading_log (user_id, book_id, started_at, finished_at, pages_read, rating)
VALUES
    (1, 1, '2024-01-15', '2024-01-30', 464, 5),
    (1, 2, '2024-02-01', '2024-02-20', 352, 5),
    (1, 3, '2024-03-01', NULL, 200, NULL),  -- Still reading
    (2, 1, '2024-01-10', '2024-02-15', 464, 4),
    (2, 4, '2024-02-20', '2024-03-01', 180, 4),
    (3, 2, '2024-01-05', '2024-01-25', 352, 5),
    (3, 3, '2024-02-01', '2024-03-15', 616, 5),
    (3, 5, '2024-03-20', '2024-04-05', 328, 4);


-- =============================================================================
-- QUERY 1: Basic Aggregation — Reading Statistics
-- =============================================================================
-- Q: GROUP BY collapses rows. COUNT, AVG, SUM are aggregate functions.

SELECT
    b.genre,
    COUNT(*) AS books_read,
    ROUND(AVG(rl.rating), 2) AS avg_rating,
    SUM(rl.pages_read) AS total_pages,
    ROUND(AVG(rl.finished_at - rl.started_at), 1) AS avg_days_to_finish
FROM reading_log rl
JOIN books b ON rl.book_id = b.id
WHERE rl.finished_at IS NOT NULL  -- Only completed books
GROUP BY b.genre
ORDER BY avg_rating DESC;

-- Q: What does this tell us?
-- Which genres are rated highest, read fastest, and most popular.


-- =============================================================================
-- QUERY 2: Window Functions — Ranking Books Within Genre
-- =============================================================================
-- Q: RANK() OVER (PARTITION BY ...) = rank within each group WITHOUT collapsing rows.

SELECT
    b.title,
    b.genre,
    b.rating,
    RANK() OVER (PARTITION BY b.genre ORDER BY b.rating DESC) AS genre_rank,
    -- Q: PARTITION BY = "within each genre". ORDER BY = "rank by rating descending"
    ROUND(b.rating - AVG(b.rating) OVER (PARTITION BY b.genre), 2) AS vs_genre_avg
    -- Q: How much better/worse than the genre average?
FROM books b
ORDER BY b.genre, genre_rank;


-- =============================================================================
-- QUERY 3: CTE — Monthly Reading Trends
-- =============================================================================
-- Q: WITH creates a temporary named result set. Much more readable than subqueries.

WITH monthly_stats AS (
    SELECT
        DATE_TRUNC('month', rl.finished_at) AS month,
        COUNT(*) AS books_finished,
        ROUND(AVG(rl.rating), 2) AS avg_rating,
        SUM(rl.pages_read) AS pages_read
    FROM reading_log rl
    WHERE rl.finished_at IS NOT NULL
    GROUP BY DATE_TRUNC('month', rl.finished_at)
)
SELECT
    month,
    books_finished,
    avg_rating,
    pages_read,
    -- Running total (cumulative sum)
    SUM(books_finished) OVER (ORDER BY month) AS cumulative_books,
    -- Q: Window function WITHOUT PARTITION BY = across all rows
    -- Month-over-month change
    books_finished - LAG(books_finished) OVER (ORDER BY month) AS mom_change
    -- Q: LAG() = previous row's value. Useful for comparisons.
FROM monthly_stats
ORDER BY month;


-- =============================================================================
-- QUERY 4: Cohort Analysis — User Retention
-- =============================================================================
-- Q: Cohort = group of users who started at the same time.
-- "Of users who joined in January, how many were still active in February?"

WITH user_first_activity AS (
    -- Find each user's first activity month (their "cohort")
    SELECT
        user_id,
        DATE_TRUNC('month', MIN(created_at)) AS cohort_month
    FROM user_activity
    GROUP BY user_id
),
user_monthly_activity AS (
    -- Find which months each user was active
    SELECT DISTINCT
        ua.user_id,
        DATE_TRUNC('month', ua.created_at) AS activity_month
    FROM user_activity ua
)
SELECT
    ufa.cohort_month,
    COUNT(DISTINCT ufa.user_id) AS cohort_size,
    COUNT(DISTINCT CASE
        WHEN uma.activity_month = ufa.cohort_month + INTERVAL '1 month'
        THEN ufa.user_id
    END) AS retained_month_1,
    -- Q: What percentage came back the next month?
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN uma.activity_month = ufa.cohort_month + INTERVAL '1 month'
            THEN ufa.user_id END
        ) / COUNT(DISTINCT ufa.user_id), 1
    ) AS retention_pct
FROM user_first_activity ufa
LEFT JOIN user_monthly_activity uma ON ufa.user_id = uma.user_id
GROUP BY ufa.cohort_month
ORDER BY ufa.cohort_month;


-- =============================================================================
-- QUERY 5: Funnel Analysis — From Search to Rating
-- =============================================================================
-- Q: A funnel shows where users drop off.
-- search → view → add_to_list → read → rate
-- If 1000 search but only 10 rate, where do we lose them?

WITH funnel AS (
    SELECT
        action,
        COUNT(DISTINCT user_id) AS unique_users,
        COUNT(*) AS total_events
    FROM user_activity
    GROUP BY action
)
SELECT
    action,
    unique_users,
    total_events,
    -- Conversion from first step
    ROUND(100.0 * unique_users / FIRST_VALUE(unique_users) OVER (ORDER BY
        CASE action
            WHEN 'search' THEN 1
            WHEN 'view' THEN 2
            WHEN 'add_to_list' THEN 3
            WHEN 'rate' THEN 4
        END
    ), 1) AS conversion_from_search_pct
FROM funnel
ORDER BY
    CASE action
        WHEN 'search' THEN 1
        WHEN 'view' THEN 2
        WHEN 'add_to_list' THEN 3
        WHEN 'rate' THEN 4
    END;


-- =============================================================================
-- QUERY 6: Recommendation Quality — Did Users Like What We Recommended?
-- =============================================================================

WITH recommendations AS (
    -- Simulated: books we recommended vs. what users actually rated
    SELECT
        rl.user_id,
        rl.book_id,
        rl.rating AS actual_rating,
        b.genre,
        CASE WHEN rl.rating >= 4 THEN 'liked' ELSE 'disliked' END AS outcome
    FROM reading_log rl
    JOIN books b ON rl.book_id = b.id
    WHERE rl.rating IS NOT NULL
)
SELECT
    genre,
    COUNT(*) AS total_rated,
    COUNT(*) FILTER (WHERE outcome = 'liked') AS liked,
    -- Q: FILTER is PostgreSQL-specific. Cleaner than CASE WHEN in COUNT.
    ROUND(100.0 * COUNT(*) FILTER (WHERE outcome = 'liked') / COUNT(*), 1) AS like_pct,
    ROUND(AVG(actual_rating), 2) AS avg_rating
FROM recommendations
GROUP BY genre
ORDER BY like_pct DESC;
