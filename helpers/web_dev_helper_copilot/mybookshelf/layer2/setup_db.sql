-- =============================================================================
-- Database Setup Script
-- =============================================================================
-- Run this as the postgres superuser to create the database and user:
--   sudo -u postgres psql -f setup_db.sql
--
-- Q: Why a separate user for the app?
--    Principle of Least Privilege. The app user can only access ONE database.
--    If the app gets hacked, the attacker can't touch other databases.
-- =============================================================================

-- Create the application user
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'bookshelf_user') THEN
        CREATE ROLE bookshelf_user WITH LOGIN PASSWORD 'bookshelf_pass';
    END IF;
END
$$;

-- Create the database
SELECT 'CREATE DATABASE mybookshelf OWNER bookshelf_user'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'mybookshelf')\gexec

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE mybookshelf TO bookshelf_user;
