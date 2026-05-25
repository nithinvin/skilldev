-- =============================================================================
-- Layer 4: Database Schema for Docker Init
-- =============================================================================
-- This file is mounted into postgres container at:
--   /docker-entrypoint-initdb.d/01-schema.sql
-- It runs automatically on FIRST container creation only.
-- To re-run: docker compose down -v && docker compose up -d
-- =============================================================================

CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    year INTEGER,
    genre VARCHAR(50),
    rating REAL CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed data so the app isn't empty on first run
INSERT INTO books (title, author, year, genre, rating) VALUES
    ('The Pragmatic Programmer', 'David Thomas & Andrew Hunt', 1999, 'programming', 4.8),
    ('Clean Code', 'Robert C. Martin', 2008, 'programming', 4.5),
    ('Designing Data-Intensive Applications', 'Martin Kleppmann', 2017, 'systems', 4.9),
    ('The Art of War', 'Sun Tzu', -500, 'strategy', 4.3),
    ('Thinking, Fast and Slow', 'Daniel Kahneman', 2011, 'psychology', 4.4);

-- Index for common queries
CREATE INDEX IF NOT EXISTS idx_books_author ON books(author);
CREATE INDEX IF NOT EXISTS idx_books_genre ON books(genre);
