-- =============================================================================
-- Level 2.6 — Normalized Schema: Relationships
-- =============================================================================
--
-- QUESTIONS (answer before reading):
--   1. What is normalization?
--      Organizing tables to reduce redundancy and prevent anomalies.
--      1NF: No repeating groups (each cell has one value)
--      2NF: No partial dependencies (every non-key column depends on the WHOLE key)
--      3NF: No transitive dependencies (non-key columns don't depend on each other)
--
--   2. What is a foreign key?
--      A column that REFERENCES a row in another table.
--      books.author_id → authors.id
--      The DB enforces this: you can't insert a book with a nonexistent author_id.
--
--   3. What is a one-to-many relationship?
--      One author → many books. One genre can have many books.
--      Implemented: put a foreign key in the "many" table.
--
--   4. What is a many-to-many relationship?
--      One book can have many genres. One genre can have many books.
--      Implemented: a JUNCTION TABLE (book_genres) with two foreign keys.
--
--   5. What does ON DELETE CASCADE do?
--      When you delete a book, automatically delete its entries in book_genres.
--      Without it: deleting a book leaves orphan rows in book_genres → error!
--
-- =============================================================================
-- NOTE: This is the EVOLVED schema. In a real project, you'd use migrations
-- (Alembic) to go from schema.sql → schema_v2.sql without losing data.
-- For learning, you can run this on a fresh database.
--
-- RUN:
--   psql -U bookshelf_user -d mybookshelf -h localhost -f schema_v2.sql
-- =============================================================================

-- Clean slate (for learning only — NEVER do this in production!)
DROP TABLE IF EXISTS book_genres CASCADE;
DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS genres CASCADE;

-- =============================================================================
-- AUTHORS TABLE
-- =============================================================================
CREATE TABLE authors (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(200) NOT NULL UNIQUE,
    -- Q: Why UNIQUE? Two authors with the same name would be confusing.
    -- In reality, you might use a compound key or separate first/last name.
    bio     TEXT,
    -- TEXT = unlimited length (good for bios, descriptions, etc.)
    created_at TIMESTAMP DEFAULT NOW()
);

-- =============================================================================
-- GENRES TABLE
-- =============================================================================
CREATE TABLE genres (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL UNIQUE
);

-- =============================================================================
-- BOOKS TABLE (with foreign key to authors)
-- =============================================================================
CREATE TABLE books (
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    author_id   INTEGER NOT NULL REFERENCES authors(id) ON DELETE RESTRICT,
    -- Q: What does REFERENCES mean? 
    -- This column MUST contain a value that exists in authors.id.
    -- The DB enforces this — you can't insert a book with a fake author_id.
    
    -- Q: ON DELETE RESTRICT vs CASCADE?
    -- RESTRICT: prevent deleting an author who has books (error!)
    -- CASCADE: deleting an author deletes ALL their books (dangerous!)
    -- RESTRICT is safer — force explicit handling.
    
    year        INTEGER CHECK (year >= 1800 AND year <= 2100),
    rating      INTEGER CHECK (rating >= 1 AND rating <= 5),
    description TEXT,
    created_at  TIMESTAMP DEFAULT NOW(),
    updated_at  TIMESTAMP DEFAULT NOW()
);

-- =============================================================================
-- JUNCTION TABLE: book_genres (many-to-many)
-- =============================================================================
CREATE TABLE book_genres (
    book_id     INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    genre_id    INTEGER NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, genre_id)
    -- Q: What is a composite primary key?
    -- The combination of (book_id, genre_id) must be unique.
    -- This prevents assigning the same genre to a book twice.
    -- It also creates an index on both columns automatically.
);

-- =============================================================================
-- SEED DATA
-- =============================================================================

-- Authors
INSERT INTO authors (name, bio) VALUES
    ('Charles Petzold', 'Writer on computer science and Windows programming'),
    ('Kernighan & Ritchie', 'Creators of the C programming language'),
    ('Abelson & Sussman', 'MIT professors, creators of the SICP course'),
    ('Robert C. Martin', 'Software craftsman, Clean Code advocate'),
    ('Cormen, Leiserson, Rivest, Stein', 'Authors of the famous CLRS algorithms textbook'),
    ('Gang of Four', 'Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides'),
    ('Hunt & Thomas', 'Pragmatic Programmers founders'),
    ('Kyle Simpson', 'JavaScript educator and author');

-- Genres
INSERT INTO genres (name) VALUES
    ('Programming'),
    ('Computer Science'),
    ('Software Engineering'),
    ('JavaScript'),
    ('Systems');

-- Books (referencing author IDs)
INSERT INTO books (title, author_id, year, rating, description) VALUES
    ('Code: The Hidden Language', 1, 1999, 5, 'How computers work from first principles'),
    ('The C Programming Language', 2, 1978, 5, 'The definitive C reference'),
    ('Structure and Interpretation of Computer Programs', 3, 1996, 4, 'Computational thinking with Scheme'),
    ('Clean Code', 4, 2008, 3, 'Writing readable, maintainable code'),
    ('Introduction to Algorithms', 5, 2009, 4, 'Comprehensive algorithms textbook (CLRS)'),
    ('Design Patterns', 6, 1994, 4, 'Classic patterns for object-oriented design'),
    ('The Pragmatic Programmer', 7, 1999, 5, 'Career wisdom for software developers'),
    ('You Don''t Know JS', 8, 2014, 4, 'Deep dive into JavaScript internals');

-- Book-Genre relationships (many-to-many)
INSERT INTO book_genres (book_id, genre_id) VALUES
    (1, 2), (1, 5),        -- Code: CS, Systems
    (2, 1), (2, 5),        -- K&R: Programming, Systems
    (3, 2),                 -- SICP: CS
    (4, 3),                 -- Clean Code: Software Engineering
    (5, 2),                 -- CLRS: CS
    (6, 3),                 -- Design Patterns: Software Engineering
    (7, 3),                 -- Pragmatic: Software Engineering
    (8, 1), (8, 4);        -- YDKJS: Programming, JavaScript

-- =============================================================================
-- PRACTICE QUERIES (try these!)
-- =============================================================================

-- Get all books with author names (JOIN):
-- SELECT b.title, a.name AS author, b.year, b.rating
-- FROM books b
-- JOIN authors a ON b.author_id = a.id
-- ORDER BY b.year;

-- Get books with their genres (many-to-many JOIN):
-- SELECT b.title, STRING_AGG(g.name, ', ') AS genres
-- FROM books b
-- JOIN book_genres bg ON b.id = bg.book_id
-- JOIN genres g ON bg.genre_id = g.id
-- GROUP BY b.id, b.title
-- ORDER BY b.title;

-- Find all books in the 'Computer Science' genre:
-- SELECT b.title, b.year
-- FROM books b
-- JOIN book_genres bg ON b.id = bg.book_id
-- JOIN genres g ON bg.genre_id = g.id
-- WHERE g.name = 'Computer Science';

-- Count books per genre:
-- SELECT g.name, COUNT(bg.book_id) AS book_count
-- FROM genres g
-- LEFT JOIN book_genres bg ON g.id = bg.genre_id
-- GROUP BY g.name
-- ORDER BY book_count DESC;

-- Q: What's the difference between JOIN and LEFT JOIN?
-- JOIN: only returns rows where BOTH sides have a match
-- LEFT JOIN: returns ALL rows from left table, NULL if no match on right
-- A genre with 0 books would disappear with JOIN but show with LEFT JOIN.
