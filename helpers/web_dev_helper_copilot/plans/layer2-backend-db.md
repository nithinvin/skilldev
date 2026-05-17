# Layer 2: Backend Server & Databases

> **Goal**: Make MyBookShelf dynamic — server generates pages, data lives in a database.
> **Pre-req**: Layer 1 complete — you can build and serve static HTML/CSS/JS pages.
> **Why?** Static pages can't remember anything. Every user sees the same data. To add books, edit them, delete them — you need a server and persistent storage.

---

## Level 2.1 — Why a Backend? The Request-Response Cycle Revisited

### Questions to Answer First
1. What's the difference between a static server (nginx) and an application server?
2. In Layer 0, you built an HTTP server in Python. What was missing to make it "dynamic"?
3. What does a web framework give you that raw sockets don't?
4. Why Python for the backend? (hint: you already know it, plus Flask/FastAPI are minimal)
5. What is WSGI/ASGI? How does it relate to your raw socket server from Layer 0?

### Theory (Concise)
```
Static server:
  Client → GET /index.html → Server reads file from disk → sends it back

Application server:
  Client → GET /books?author=Petzold → Server runs code → queries DB → builds response

The framework handles:
  - Routing (URL → function mapping)
  - Request parsing (headers, body, query params)
  - Response building (status codes, headers, body)
  - You write the logic
```

---

## Level 2.2 — Flask: The Minimal Backend

### Questions to Answer First
1. What is a route? What is a route decorator?
2. What's the difference between `GET` and `POST`? When do you use each?
3. What is a template? How is it different from serving a static HTML file?
4. What is Jinja2? How does it embed Python logic into HTML?

### Hands-On: Flask Backend for MyBookShelf
```bash
# Setup
cd ~/skilldev/mybookshelf
python3 -m venv venv
source venv/bin/activate
pip install flask
```

```python
# file: mybookshelf/server.py
from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

# In-memory storage (replaced by DB in Level 2.4)
books = [
    {"id": 1, "title": "Code", "author": "Charles Petzold", "year": 1999, "rating": 5},
    {"id": 2, "title": "The C Programming Language", "author": "K&R", "year": 1978, "rating": 5},
    {"id": 3, "title": "SICP", "author": "Abelson & Sussman", "year": 1996, "rating": 4},
]
next_id = 4

@app.route('/')
def index():
    """Q: What HTTP method does this handle by default?"""
    search = request.args.get('search', '')  # Q: What are query parameters?
    if search:
        filtered = [b for b in books if search.lower() in b['title'].lower()
                    or search.lower() in b['author'].lower()]
    else:
        filtered = books
    return render_template('index.html', books=filtered, search=search)

@app.route('/books/add', methods=['GET', 'POST'])
def add_book():
    """Q: Why does this handle both GET and POST?"""
    if request.method == 'POST':
        global next_id
        book = {
            "id": next_id,
            "title": request.form['title'],      # Q: Where does request.form data come from?
            "author": request.form['author'],
            "year": int(request.form['year']),
            "rating": int(request.form['rating']),
        }
        next_id += 1
        books.append(book)
        return redirect(url_for('index'))         # Q: What is url_for? Why not hardcode '/'?
    return render_template('add_book.html')

@app.route('/books/<int:book_id>/delete', methods=['POST'])
def delete_book(book_id):
    """Q: Why is this POST and not GET?"""
    global books
    books = [b for b in books if b['id'] != book_id]
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

### Templates (Jinja2)
```html
<!-- file: mybookshelf/templates/index.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>MyBookShelf</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <header>
        <h1>📚 MyBookShelf</h1>
        <nav>
            <a href="{{ url_for('index') }}">Home</a>
            <a href="{{ url_for('add_book') }}">Add Book</a>
        </nav>
    </header>

    <main>
        <form method="GET" action="{{ url_for('index') }}">
            <input type="text" name="search" value="{{ search }}"
                   placeholder="Search books..." id="search">
            <button type="submit">Search</button>
        </form>

        <table>
            <thead>
                <tr>
                    <th>Title</th>
                    <th>Author</th>
                    <th>Year</th>
                    <th>Rating</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                {% for book in books %}
                <tr>
                    <td>{{ book.title }}</td>
                    <td>{{ book.author }}</td>
                    <td>{{ book.year }}</td>
                    <td>{{ '⭐' * book.rating }}</td>
                    <td>
                        <form method="POST" action="{{ url_for('delete_book', book_id=book.id) }}"
                              style="display:inline;">
                            <button type="submit" onclick="return confirm('Delete this book?')">🗑️</button>
                        </form>
                    </td>
                </tr>
                {% endfor %}
            </tbody>
        </table>

        {% if not books %}
            <p style="text-align:center; padding: 20px;">No books found.</p>
        {% endif %}
    </main>
</body>
</html>
```

```html
<!-- file: mybookshelf/templates/add_book.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Add Book - MyBookShelf</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='style.css') }}">
</head>
<body>
    <header>
        <h1>📚 Add a Book</h1>
        <nav><a href="{{ url_for('index') }}">← Back to list</a></nav>
    </header>

    <main>
        <form method="POST" action="{{ url_for('add_book') }}">
            <label>Title: <input type="text" name="title" required></label><br><br>
            <label>Author: <input type="text" name="author" required></label><br><br>
            <label>Year: <input type="number" name="year" min="1800" max="2030" required></label><br><br>
            <label>Rating (1-5): <input type="number" name="rating" min="1" max="5" required></label><br><br>
            <button type="submit">Add Book</button>
        </form>
    </main>
</body>
</html>
```

### Break It
- Restart the server — all added books are gone. Why?
- Add a book with `<script>alert('XSS')</script>` as the title. Does Jinja2 escape it?
- Delete using GET instead of POST — what's the security risk? (hint: CSRF, prefetch bots)
- Send a POST to `/books/add` with missing fields — what happens?

---

## Level 2.3 — Understanding Databases: Why Not Just Files?

### Questions to Answer First
1. Why not store books in a JSON file? What breaks at scale?
2. What is ACID? Why does it matter for a database but not a JSON file?
3. What is SQL? How is it different from a programming language?
4. What's the difference between a relational DB (PostgreSQL) and a document DB (MongoDB)?
5. What is a primary key? A foreign key? Why do they exist?

### Theory (Concise)
```
File storage problems:
  - No concurrent access control (two writes = corruption)
  - No querying without reading entire file
  - No relationships between data
  - No transactions (partial writes leave broken state)

ACID:
  Atomicity    → All or nothing (no partial operations)
  Consistency  → Data follows rules (constraints)
  Isolation    → Concurrent operations don't interfere
  Durability   → Once committed, data survives crashes
```

---

## Level 2.4 — PostgreSQL: Hands-On

### Questions to Answer First
1. What is PostgreSQL? How does it differ from SQLite?
2. What is a schema? A table? A column? A row?
3. What does `CREATE TABLE` actually do on disk?
4. What is an index? Why does it make queries faster? (hint: B-tree from your DSA course)
5. What is SQL injection? How does it work?

### Setup PostgreSQL
```bash
# On Ubuntu (WSL or Hetzner)
sudo apt update
sudo apt install postgresql postgresql-client -y
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create a database and user
sudo -u postgres psql << 'EOF'
CREATE USER bookshelf_user WITH PASSWORD 'bookshelf_pass';
CREATE DATABASE mybookshelf OWNER bookshelf_user;
GRANT ALL PRIVILEGES ON DATABASE mybookshelf TO bookshelf_user;
EOF

# Connect
psql -U bookshelf_user -d mybookshelf -h localhost
```

### Hands-On: SQL from Scratch
```sql
-- file: mybookshelf/schema.sql

-- Create the books table
CREATE TABLE books (
    id          SERIAL PRIMARY KEY,     -- Q: What does SERIAL do?
    title       VARCHAR(200) NOT NULL,  -- Q: Why NOT NULL?
    author      VARCHAR(200) NOT NULL,
    year        INTEGER CHECK (year >= 1800 AND year <= 2100),  -- Q: What is a CHECK constraint?
    rating      INTEGER CHECK (rating >= 1 AND rating <= 5),
    created_at  TIMESTAMP DEFAULT NOW(),  -- Q: Why track creation time?
    updated_at  TIMESTAMP DEFAULT NOW()
);

-- Insert some books
INSERT INTO books (title, author, year, rating) VALUES
    ('Code', 'Charles Petzold', 1999, 5),
    ('The C Programming Language', 'Kernighan & Ritchie', 1978, 5),
    ('SICP', 'Abelson & Sussman', 1996, 4),
    ('Clean Code', 'Robert Martin', 2008, 3),
    ('CLRS Introduction to Algorithms', 'Cormen et al.', 2009, 4);

-- Basic queries
SELECT * FROM books;
SELECT title, author FROM books WHERE rating >= 4 ORDER BY year;
SELECT author, COUNT(*) as book_count FROM books GROUP BY author;

-- Update
UPDATE books SET rating = 4 WHERE title = 'Clean Code';

-- Delete
DELETE FROM books WHERE id = 4;

-- Q: What happens if you INSERT a book with rating = 6?
-- Q: What happens if you INSERT without a title?
```

### Run the SQL
```bash
psql -U bookshelf_user -d mybookshelf -h localhost -f schema.sql
```

---

## Level 2.5 — Connect Flask to PostgreSQL

### Questions to Answer First
1. What is an ORM? Why use one instead of raw SQL? What are the tradeoffs?
2. What is a database connection pool? Why not open a new connection per request?
3. What is a migration? Why not just change the schema directly?
4. What is SQL injection? How do parameterized queries prevent it?

### Hands-On: Flask + psycopg2 (Raw SQL First)
```bash
pip install psycopg2-binary
```

```python
# file: mybookshelf/db.py
import psycopg2
from psycopg2.extras import RealDictCursor

DATABASE_URL = "postgresql://bookshelf_user:bookshelf_pass@localhost/mybookshelf"

def get_db():
    """Get a database connection."""
    conn = psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)
    return conn

def get_all_books(search=None):
    conn = get_db()
    cur = conn.cursor()
    if search:
        # Q: Why %s and not f-string? SECURITY!
        cur.execute(
            "SELECT * FROM books WHERE title ILIKE %s OR author ILIKE %s ORDER BY created_at DESC",
            (f'%{search}%', f'%{search}%')
        )
    else:
        cur.execute("SELECT * FROM books ORDER BY created_at DESC")
    books = cur.fetchall()
    cur.close()
    conn.close()
    return books

def add_book(title, author, year, rating):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO books (title, author, year, rating) VALUES (%s, %s, %s, %s) RETURNING id",
        (title, author, year, rating)
    )
    book_id = cur.fetchone()['id']
    conn.commit()   # Q: What happens without commit? The insert is LOST.
    cur.close()
    conn.close()
    return book_id

def delete_book(book_id):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("DELETE FROM books WHERE id = %s", (book_id,))
    conn.commit()
    cur.close()
    conn.close()
```

```python
# file: mybookshelf/server.py (updated)
from flask import Flask, render_template, request, redirect, url_for
from db import get_all_books, add_book, delete_book

app = Flask(__name__)

@app.route('/')
def index():
    search = request.args.get('search', '')
    books = get_all_books(search=search if search else None)
    return render_template('index.html', books=books, search=search)

@app.route('/books/add', methods=['GET', 'POST'])
def add_book_route():
    if request.method == 'POST':
        add_book(
            title=request.form['title'],
            author=request.form['author'],
            year=int(request.form['year']),
            rating=int(request.form['rating']),
        )
        return redirect(url_for('index'))
    return render_template('add_book.html')

@app.route('/books/<int:book_id>/delete', methods=['POST'])
def delete_book_route(book_id):
    delete_book(book_id)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

### Break It
- Try SQL injection: add a book with title `'; DROP TABLE books; --` — does psycopg2 prevent it?
- Remove `conn.commit()` after INSERT — add a book, then check the DB. It's not there!
- Open two browser tabs, add books rapidly — any race conditions?

---

## Level 2.6 — Database Design: Normalization & Relationships

### Questions to Answer First
1. What is normalization? What are 1NF, 2NF, 3NF?
2. What is a one-to-many relationship? Many-to-many?
3. What is a JOIN? Why can't you store everything in one table?
4. Draw an ER diagram: Books, Authors, Genres, Users, Reviews

### Hands-On: Expand the Schema
```sql
-- file: mybookshelf/schema_v2.sql

-- Authors table (1 author → many books)
CREATE TABLE authors (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(200) NOT NULL UNIQUE,
    bio     TEXT
);

-- Genres table
CREATE TABLE genres (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(100) NOT NULL UNIQUE
);

-- Books (now references authors)
CREATE TABLE books (
    id          SERIAL PRIMARY KEY,
    title       VARCHAR(200) NOT NULL,
    author_id   INTEGER REFERENCES authors(id),  -- Q: What is this? A foreign key!
    year        INTEGER CHECK (year >= 1800 AND year <= 2100),
    rating      INTEGER CHECK (rating >= 1 AND rating <= 5),
    created_at  TIMESTAMP DEFAULT NOW()
);

-- Book-Genre (many-to-many via junction table)
CREATE TABLE book_genres (
    book_id     INTEGER REFERENCES books(id) ON DELETE CASCADE,
    genre_id    INTEGER REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, genre_id)  -- Q: Why a composite primary key?
);

-- JOINs
-- Get all books with author names:
SELECT b.title, a.name AS author, b.year, b.rating
FROM books b
JOIN authors a ON b.author_id = a.id
ORDER BY b.year;

-- Get books with their genres:
SELECT b.title, STRING_AGG(g.name, ', ') AS genres
FROM books b
JOIN book_genres bg ON b.id = bg.book_id
JOIN genres g ON bg.genre_id = g.id
GROUP BY b.title;

-- Q: What does ON DELETE CASCADE do? What happens to book_genres if a book is deleted?
```

### Indexing Exercise
```sql
-- Q: Why is this query slow on a million rows?
SELECT * FROM books WHERE title ILIKE '%algorithms%';

-- Create an index
CREATE INDEX idx_books_title ON books (title);

-- For ILIKE, you need a special index:
CREATE EXTENSION pg_trgm;
CREATE INDEX idx_books_title_trgm ON books USING gin (title gin_trgm_ops);

-- Use EXPLAIN ANALYZE to see the difference
EXPLAIN ANALYZE SELECT * FROM books WHERE title ILIKE '%algorithms%';
```

---

## Level 2.7 — Migrations: Evolving Your Schema Safely

### Questions to Answer First
1. What happens when you need to add a column to a table with 1 million rows?
2. Why can't you just edit the CREATE TABLE statement and re-run it?
3. What is a migration tool? Why do teams use them?

### Hands-On: Alembic (Python Migration Tool)
```bash
pip install alembic sqlalchemy
alembic init migrations
# Edit alembic.ini: sqlalchemy.url = postgresql://bookshelf_user:bookshelf_pass@localhost/mybookshelf
```

This is the *awareness* level — you'll use this more in Layer 3.

---

## Checkpoint Questions (Answer Before Moving to Layer 3)

1. Trace a full request: browser → Flask → SQL query → response → rendered page.
2. What is ACID? Give an example of what breaks without each property.
3. Write a JOIN query from memory: get books with their author names and genres.
4. What is SQL injection? Show a vulnerable query and a safe query.
5. Why is `DELETE` via GET dangerous? What is CSRF?
6. What's the difference between `conn.commit()` and not committing? What is autocommit?
7. Design a schema: a blog with posts, comments, and tags (many-to-many). Draw the ER diagram.

---

## Files Created in This Layer

```
mybookshelf/
├── server.py                # Flask application
├── db.py                    # Database access layer
├── schema.sql               # Initial schema
├── schema_v2.sql            # Normalized schema with relations
├── templates/
│   ├── index.html           # Book list (Jinja2 template)
│   └── add_book.html        # Add book form
├── static/
│   └── style.css            # Styles (moved to static/)
└── venv/                    # Python virtual environment
```

---

**Previous**: [Layer 1 — Static Web](layer1-static-web.md)
**Next**: [Layer 3 — APIs, Auth & Authorization](layer3-apis-auth.md)
