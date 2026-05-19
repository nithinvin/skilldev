-- =============================================================================
-- Level 2.4 — PostgreSQL Schema: MyBookShelf
-- =============================================================================
--
-- QUESTIONS (answer before reading):
--   1. What does SERIAL do? Auto-incrementing integer (1, 2, 3, ...)
--      PostgreSQL manages the sequence — you never set the ID manually.
--
--   2. Why NOT NULL? Prevents inserting rows with missing data.
--      Without it: INSERT INTO books (title) VALUES (NULL) → broken data.
--
--   3. What is CHECK? A constraint that validates data ON INSERT/UPDATE.
--      Enforced by the DATABASE — even if your code has bugs, bad data can't enter.
--
--   4. What is DEFAULT NOW()? If you don't provide a value, use current timestamp.
--      Useful for created_at — you never need to set it manually.
--
--   5. What happens if you run this file twice?
--      ERROR: relation "books" already exists.
--      That's why we use IF NOT EXISTS (or migrations in production).
--
-- RUN:
--   psql -U bookshelf_user -d mybookshelf -h localhost -f schema.sql
-- =============================================================================

-- Drop table if starting fresh (remove this line in production!)
DROP TABLE IF EXISTS books;

-- Create the books table
CREATE TABLE books (
    id          SERIAL PRIMARY KEY,
    -- Q: PRIMARY KEY = UNIQUE + NOT NULL + creates an index for fast lookups
    -- SERIAL = auto-increment integer (PostgreSQL manages the counter)

    title       VARCHAR(200) NOT NULL,
    -- Q: Why VARCHAR(200) and not TEXT?
    -- VARCHAR(n) = enforces max length (extra validation)
    -- TEXT = unlimited length (fine too, but no length check)
    -- For book titles, 200 chars is reasonable

    author      VARCHAR(200) NOT NULL,

    year        INTEGER CHECK (year >= 1800 AND year <= 2100),
    -- Q: What if someone inserts year = 99999?
    -- CHECK constraint REJECTS it with an error. Data integrity!

    rating      INTEGER CHECK (rating >= 1 AND rating <= 5),
    -- Q: Why integer 1-5 and not stars?
    -- Integers are sortable, averageable, and compact.
    -- Display logic (stars) belongs in the frontend.

    created_at  TIMESTAMP DEFAULT NOW(),
    -- Q: Why track creation time?
    -- Debugging, sorting by "recently added", audit trails.

    updated_at  TIMESTAMP DEFAULT NOW()
    -- Q: Does this auto-update? NO! You must set it in UPDATE queries.
    -- Some DBs have ON UPDATE triggers. We'll do it in db.py.
);

-- =============================================================================
-- SEED DATA
-- =============================================================================
-- Q: What is "seed data"? Initial data to populate a fresh database.
-- Without it, the app starts with an empty table (boring for development).

INSERT INTO books (title, author, year, rating) VALUES
    ('Code: The Hidden Language', 'Charles Petzold', 1999, 5),
    ('The C Programming Language', 'Kernighan & Ritchie', 1978, 5),
    ('Structure and Interpretation of Computer Programs', 'Abelson & Sussman', 1996, 4),
    ('Clean Code', 'Robert C. Martin', 2008, 3),
    ('Introduction to Algorithms', 'Cormen, Leiserson, Rivest, Stein', 2009, 4),
    ('Design Patterns', 'Gang of Four', 1994, 4),
    ('The Pragmatic Programmer', 'Hunt & Thomas', 1999, 5),
    ('You Don''t Know JS', 'Kyle Simpson', 2014, 4);
    -- Q: Why two single quotes in "Don''t"?
    -- In SQL, single quote is the string delimiter.
    -- To include a literal quote IN a string, you escape it by doubling: ''

-- =============================================================================
-- USEFUL QUERIES TO TRY
-- =============================================================================

-- Select all books, most recent first
-- SELECT * FROM books ORDER BY created_at DESC;

-- Search (case-insensitive)
-- SELECT * FROM books WHERE title ILIKE '%code%';

-- Aggregate: average rating
-- SELECT ROUND(AVG(rating), 2) AS avg_rating FROM books;

-- Count by decade
-- SELECT (year / 10) * 10 AS decade, COUNT(*) FROM books GROUP BY decade ORDER BY decade;

-- =============================================================================
-- INDEXES
-- =============================================================================
-- Q: What is an index? A data structure (B-tree) that makes lookups fast.
-- Without index: SELECT WHERE title = 'X' → scans ALL rows (O(n))
-- With index: same query → B-tree lookup (O(log n))
-- Tradeoff: indexes speed up reads but slow down writes (must update the index too)

CREATE INDEX IF NOT EXISTS idx_books_title ON books (title);
CREATE INDEX IF NOT EXISTS idx_books_author ON books (author);

-- For ILIKE (case-insensitive pattern matching), you need a special index:
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX idx_books_title_trgm ON books USING gin (title gin_trgm_ops);
-- (Uncomment above if you want fast ILIKE searches on large datasets)

-- =============================================================================
-- EXERCISE: Run EXPLAIN ANALYZE on these queries to see execution plans
-- =============================================================================
-- EXPLAIN ANALYZE SELECT * FROM books WHERE title = 'Clean Code';
-- EXPLAIN ANALYZE SELECT * FROM books WHERE title ILIKE '%code%';
-- Compare: which uses the index? Which does a sequential scan?
