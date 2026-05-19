"""
=============================================================================
Level 2.5 — Database Access Layer
=============================================================================

QUESTIONS (answer these BEFORE reading the code):

  1. Why separate DB code from server code?
     - Single Responsibility: server.py handles HTTP, db.py handles data
     - Testability: you can test DB functions without running a web server
     - Swappability: change from PostgreSQL to MySQL by editing only this file
     - This is the "repository pattern" — a data access layer

  2. What is psycopg2?
     - PostgreSQL adapter for Python
     - Translates Python calls → PostgreSQL wire protocol
     - Supports parameterized queries (prevents SQL injection!)
     - RealDictCursor: returns rows as dictionaries (not tuples)

  3. What is SQL injection?
     VULNERABLE:
       f"SELECT * FROM books WHERE title = '{user_input}'"
       If user_input = "'; DROP TABLE books; --"
       SQL becomes: SELECT * FROM books WHERE title = ''; DROP TABLE books; --'
       → TABLE DELETED!

     SAFE (parameterized):
       cur.execute("SELECT * FROM books WHERE title = %s", (user_input,))
       psycopg2 handles escaping. The input is NEVER part of the SQL structure.

  4. What is a connection? Why close it?
     - A connection = TCP socket to the PostgreSQL server
     - Each connection uses server memory (~10MB)
     - Max connections is limited (default: 100)
     - Not closing = connection leak → server runs out → all new requests fail
     - In production: use connection pooling (Level 3)

  5. What does conn.commit() do?
     - PostgreSQL groups operations into transactions
     - Nothing is permanent until you COMMIT
     - If you crash before commit → changes are rolled back (ACID!)
     - SELECT doesn't need commit (read-only)
     - INSERT/UPDATE/DELETE MUST commit

=============================================================================
SETUP:
  1. Install PostgreSQL:
     sudo apt install postgresql postgresql-client -y
     sudo systemctl start postgresql

  2. Create database:
     sudo -u postgres psql -f setup_db.sql

  3. Create tables:
     psql -U bookshelf_user -d mybookshelf -h localhost -f schema.sql

  4. Install Python package:
     pip install psycopg2-binary
=============================================================================
"""

import os
import psycopg2
from psycopg2.extras import RealDictCursor

# Q: Why use an environment variable instead of hardcoding?
# 1. Security: credentials don't end up in git
# 2. Flexibility: different values for dev/staging/production
# 3. We'll use .env files in Layer 3
DATABASE_URL = os.environ.get(
    "DATABASE_URL",
    "postgresql://bookshelf_user:bookshelf_pass@localhost/mybookshelf"
)


def get_db():
    """
    Get a database connection.
    
    Q: Why cursor_factory=RealDictCursor?
       Default cursor returns tuples: (1, 'Clean Code', 'Robert Martin', 2008)
       RealDictCursor returns dicts: {'id': 1, 'title': 'Clean Code', ...}
       Dicts are easier to work with in templates: {{ book.title }}
    """
    conn = psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)
    return conn


# =============================================================================
# CRUD OPERATIONS
# =============================================================================
# Q: What is CRUD? Create, Read, Update, Delete.
# These 4 operations map to SQL: INSERT, SELECT, UPDATE, DELETE
# And to HTTP methods: POST, GET, PUT/PATCH, DELETE


def get_all_books(search=None):
    """
    Read all books, optionally filtered by search query.
    
    Q: What does ILIKE do?
       LIKE = pattern matching (% = wildcard)
       ILIKE = case-Insensitive LIKE (PostgreSQL extension)
       '%python%' matches 'Python', 'PYTHON', 'Learning Python', etc.
    """
    conn = get_db()
    cur = conn.cursor()
    try:
        if search:
            cur.execute(
                """SELECT * FROM books 
                   WHERE title ILIKE %s OR author ILIKE %s 
                   ORDER BY created_at DESC""",
                (f"%{search}%", f"%{search}%")
            )
            # Q: Why %s and not f-string or .format()?
            # %s is a PARAMETERIZED PLACEHOLDER — psycopg2 escapes the value.
            # f-string would insert raw text → SQL injection vulnerability!
        else:
            cur.execute("SELECT * FROM books ORDER BY created_at DESC")
        return cur.fetchall()
    finally:
        # Q: Why finally? Ensures connection closes even if query throws an error.
        # Without it: error → connection leak → DB runs out of connections.
        cur.close()
        conn.close()


def get_book_by_id(book_id):
    """Read a single book by its primary key."""
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("SELECT * FROM books WHERE id = %s", (book_id,))
        # Q: Why (book_id,) with a trailing comma?
        # psycopg2 expects a TUPLE for parameters. (book_id) without comma = just parentheses.
        # (book_id,) = a tuple with one element.
        return cur.fetchone()  # Returns one row or None
    finally:
        cur.close()
        conn.close()


def add_book(title, author, year, rating):
    """
    Create a new book. Returns the new book's ID.
    
    Q: What does RETURNING id do?
       Normally INSERT returns nothing. RETURNING makes PostgreSQL send back
       the auto-generated ID so we don't need a separate SELECT query.
    """
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute(
            """INSERT INTO books (title, author, year, rating) 
               VALUES (%s, %s, %s, %s) 
               RETURNING id""",
            (title, author, year, rating)
        )
        book_id = cur.fetchone()["id"]
        conn.commit()
        # Q: What happens without commit?
        # The INSERT exists in a transaction but is NOT saved to disk.
        # When the connection closes, uncommitted work is ROLLED BACK.
        # The book appears to vanish!
        return book_id
    except Exception:
        conn.rollback()  # Undo partial transaction on error
        raise
    finally:
        cur.close()
        conn.close()


def update_book(book_id, title, author, year, rating):
    """Update an existing book."""
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute(
            """UPDATE books 
               SET title = %s, author = %s, year = %s, rating = %s, 
                   updated_at = NOW()
               WHERE id = %s""",
            (title, author, year, rating, book_id)
        )
        # Q: What does cur.rowcount tell us?
        # Number of rows affected. If 0, the book_id didn't exist.
        updated = cur.rowcount > 0
        conn.commit()
        return updated
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()


def delete_book(book_id):
    """Delete a book by ID."""
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("DELETE FROM books WHERE id = %s", (book_id,))
        deleted = cur.rowcount > 0
        conn.commit()
        return deleted
    except Exception:
        conn.rollback()
        raise
    finally:
        cur.close()
        conn.close()


# =============================================================================
# TEST IT STANDALONE
# =============================================================================
# Run: python3 db.py
# This lets you test DB functions without the web server.

if __name__ == "__main__":
    print("Testing database connection...")
    try:
        books = get_all_books()
        print(f"✅ Connected! Found {len(books)} books:")
        for b in books:
            print(f"   [{b['id']}] {b['title']} by {b['author']} ({b['year']}) {'⭐' * b['rating']}")

        # Test add
        print("\nAdding test book...")
        new_id = add_book("Test Book", "Test Author", 2024, 3)
        print(f"   Created book with ID: {new_id}")

        # Test delete
        print(f"   Deleting test book (ID: {new_id})...")
        delete_book(new_id)
        print("   Deleted.")

        print("\n✅ All DB operations working!")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("   Make sure PostgreSQL is running and schema.sql has been applied.")
        print("   See README.md for setup instructions.")
