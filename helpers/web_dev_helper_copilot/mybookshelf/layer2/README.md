# Layer 2: Backend Server & Database

## What You'll Learn
- How web frameworks work (Flask — routing, templates, forms)
- The request-response cycle for dynamic pages
- SQL and relational databases (PostgreSQL)
- CRUD operations (Create, Read, Update, Delete)
- Database schema design, normalization, relationships
- SQL injection prevention (parameterized queries)
- Server-side validation (never trust the client!)

## File Structure

```
mybookshelf/layer2/
├── server.py               ← Flask application (routes, request handling)
├── db.py                   ← Database access layer (all SQL queries)
├── setup_db.sql            ← Creates PostgreSQL user & database
├── schema.sql              ← Initial schema (single books table)
├── schema_v2.sql           ← Normalized schema (authors, genres, JOINs)
├── requirements.txt        ← Python dependencies
├── templates/
│   ├── base.html           ← Layout template (inherited by all pages)
│   ├── index.html          ← Book list with search
│   ├── add_book.html       ← Add book form
│   ├── edit_book.html      ← Edit book form
│   ├── 404.html            ← Custom 404 page
│   └── 500.html            ← Custom error page
├── static/
│   └── style.css           ← Styles (served by Flask from /static/)
├── README.md               ← This file
└── checkpoint_quiz.py      ← Self-test: 15 questions
```

## How to Work Through This Layer

### Prerequisites
- Complete Layer 1 (you should understand HTML forms, JS fetch, DOM)
- PostgreSQL installed (or use in-memory mode first)

### Quick Start (No Database Required!)

```bash
cd mybookshelf/layer2

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Run the server (starts in-memory mode if no DB)
python3 server.py
```

Open http://localhost:5000 — the app works with in-memory storage!
(Data is lost on restart — that's the motivation for Level 2.4+)

### Full Setup (With PostgreSQL)

```bash
# 1. Install PostgreSQL
sudo apt install postgresql postgresql-client -y
sudo systemctl start postgresql

# 2. Create database and user
sudo -u postgres psql -f setup_db.sql

# 3. Apply schema
psql -U bookshelf_user -d mybookshelf -h localhost -f schema.sql

# 4. Run with DB connected
export DATABASE_URL="postgresql://bookshelf_user:bookshelf_pass@localhost/mybookshelf"
python3 server.py
```

### Study Order

1. **Run server.py first** (no DB needed!) — explore the app in your browser.
   Add books, search, edit, delete. See how it works as a user.

2. **Read server.py** — understand routes, GET vs POST, redirect, flash.
   Map each URL you visited to the code that handled it.

3. **Read templates/base.html** — understand template inheritance.
   Then read index.html — see how {% extends %}, {% block %}, {% for %} work.

4. **Set up PostgreSQL** — follow the setup steps above.
   Run schema.sql. Connect with psql and run the practice queries.

5. **Read db.py** — understand parameterized queries vs SQL injection.
   Run `python3 db.py` to test the DB functions standalone.

6. **Read schema_v2.sql** — understand normalization, foreign keys, JOINs.
   Run the practice queries at the bottom.

7. **Do all "BREAK IT" exercises** in server.py and db.py.

8. **Run checkpoint_quiz.py** — score 12/15 to proceed.

### Key Differences from Layer 1

| Layer 1 (Static) | Layer 2 (Dynamic) |
|---|---|
| HTML files served as-is | Server generates HTML per request |
| Data hardcoded in JS | Data stored in PostgreSQL |
| Adding a book = editing code | Adding a book = filling a form |
| Same page for everyone | Different results per search query |
| No persistence | Data survives restarts |
| python3 -m http.server | Flask development server |

### Connection to Other Layers

- **Layer 0** → The HTTP protocol you saw at the socket level — Flask handles it for you now
- **Layer 1** → Your static CSS and responsive design carry over to templates
- **Layer 3** → We'll convert this to a REST API (JSON instead of HTML) + add auth
- **Layer 4** → We'll Dockerize this Flask app + PostgreSQL + nginx
