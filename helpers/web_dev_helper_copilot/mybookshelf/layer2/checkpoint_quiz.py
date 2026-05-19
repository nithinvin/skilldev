#!/usr/bin/env python3
"""
=============================================================================
Layer 2 Checkpoint Quiz — Backend & Database
=============================================================================
Score 12/15 to proceed to Layer 3.

Run: python3 checkpoint_quiz.py
=============================================================================
"""

import random

QUESTIONS = [
    {
        "q": "What does @app.route('/books') do in Flask?",
        "options": [
            "Creates a new file called 'books'",
            "Maps the URL /books to the decorated function (routing)",
            "Redirects all traffic to /books",
            "Imports the books module"
        ],
        "answer": 1,
        "explanation": "A route decorator tells Flask: when a request comes in for /books, "
                       "call this function and return its result as the HTTP response."
    },
    {
        "q": "Why should DELETE operations use POST (not GET)?",
        "options": [
            "GET is slower than POST",
            "POST data is encrypted",
            "GET should be safe/idempotent — bots, prefetchers, and back buttons trigger GET requests",
            "GET can't send data to the server"
        ],
        "answer": 2,
        "explanation": "GET requests must be safe (no side effects). Browser prefetching, "
                       "search engine crawlers, and 'open in new tab' all make GET requests. "
                       "If delete were GET, visiting a link could delete data!"
    },
    {
        "q": "What is the Post/Redirect/Get (PRG) pattern?",
        "options": [
            "A JavaScript design pattern for forms",
            "After POST succeeds, redirect to a GET page — prevents duplicate submission on refresh",
            "A way to combine POST and GET into one request",
            "A pattern for handling GET parameters"
        ],
        "answer": 1,
        "explanation": "Without redirect: user refreshes after POST → browser asks 'resubmit form?' "
                       "→ duplicate entry! With redirect: refresh just re-GETs the page (safe)."
    },
    {
        "q": "What does conn.commit() do in psycopg2?",
        "options": [
            "Closes the database connection",
            "Makes INSERT/UPDATE/DELETE changes permanent (saves to disk)",
            "Commits the code to git",
            "Refreshes the database cache"
        ],
        "answer": 1,
        "explanation": "PostgreSQL groups operations into transactions. Nothing is permanent "
                       "until COMMIT. If you crash before commit, changes are rolled back (ACID!)."
    },
    {
        "q": "What is SQL injection?",
        "options": [
            "A way to speed up SQL queries",
            "Inserting user input directly into SQL strings, allowing attackers to execute arbitrary SQL",
            "A method for creating database indexes",
            "A PostgreSQL extension for full-text search"
        ],
        "answer": 1,
        "explanation": "If you write f\"SELECT * FROM books WHERE title = '{user_input}'\" "
                       "and user_input = \"'; DROP TABLE books; --\", the table is deleted! "
                       "Always use parameterized queries (%s placeholders)."
    },
    {
        "q": "What does SERIAL PRIMARY KEY do in PostgreSQL?",
        "options": [
            "Creates a text column that must be unique",
            "Auto-incrementing integer (1,2,3...) that uniquely identifies each row",
            "Creates a random UUID for each row",
            "Makes the column optional"
        ],
        "answer": 1,
        "explanation": "SERIAL = auto-increment counter managed by PostgreSQL. "
                       "PRIMARY KEY = UNIQUE + NOT NULL + automatically indexed. "
                       "Every table should have a primary key."
    },
    {
        "q": "What is a foreign key?",
        "options": [
            "A key stored on a different server",
            "A column that references a row in another table, enforcing referential integrity",
            "A primary key from a different programming language",
            "An encrypted primary key"
        ],
        "answer": 1,
        "explanation": "books.author_id REFERENCES authors(id) — the DB ensures you can't "
                       "insert a book with a non-existent author. This is referential integrity."
    },
    {
        "q": "What's the difference between JOIN and LEFT JOIN?",
        "options": [
            "JOIN is faster, LEFT JOIN is more accurate",
            "JOIN returns only matching rows from both tables; LEFT JOIN returns ALL rows from the left table (NULL if no match)",
            "LEFT JOIN only works with foreign keys",
            "They do the same thing"
        ],
        "answer": 1,
        "explanation": "JOIN (INNER): books without an author disappear from results. "
                       "LEFT JOIN: books without an author still appear, with NULL for author columns. "
                       "Use LEFT JOIN when you want to keep all rows from one side."
    },
    {
        "q": "Why use a virtual environment (venv)?",
        "options": [
            "It makes Python run faster",
            "It isolates project dependencies — different projects can use different package versions without conflict",
            "It encrypts your source code",
            "It's required by Flask"
        ],
        "answer": 1,
        "explanation": "Without venv: pip install flask affects your entire system. "
                       "Project A needs Flask 2.x, Project B needs Flask 3.x → conflict! "
                       "venv gives each project its own isolated set of packages."
    },
    {
        "q": "What does Jinja2's auto-escape do?",
        "options": [
            "Automatically closes HTML tags",
            "Converts special characters (<, >, &, quotes) to HTML entities, preventing XSS attacks",
            "Escapes from the template rendering loop",
            "Removes all HTML from the output"
        ],
        "answer": 1,
        "explanation": "If book.title = '<script>alert(1)</script>', Jinja2 renders it as "
                       "'&lt;script&gt;...' — displayed as text, not executed. "
                       "This is on by default in Flask's Jinja2 environment."
    },
    {
        "q": "What is the purpose of CHECK constraints in PostgreSQL?",
        "options": [
            "They check if the database is running",
            "They validate data at the database level — rejecting invalid values regardless of application bugs",
            "They check for duplicate rows",
            "They verify SQL syntax"
        ],
        "answer": 1,
        "explanation": "CHECK (rating >= 1 AND rating <= 5) means the DB REJECTS rating=6 "
                       "even if your code has a bug. Defense in depth: validate in app AND in DB."
    },
    {
        "q": "What is template inheritance ({% extends %})?",
        "options": [
            "Copying code from one template to another",
            "A base template defines the structure; child templates fill in specific blocks, avoiding repetition",
            "Using JavaScript to modify templates at runtime",
            "Including CSS files in templates"
        ],
        "answer": 1,
        "explanation": "base.html defines header/footer/layout. Every page extends it and only "
                       "overrides {% block content %}. Change the header once → all pages update. DRY principle."
    },
    {
        "q": "What does request.args vs request.form give you in Flask?",
        "options": [
            "args = command line arguments, form = HTML forms",
            "args = URL query parameters (?key=value), form = POST body data (form fields)",
            "args = function arguments, form = form validation results",
            "They're the same thing"
        ],
        "answer": 1,
        "explanation": "GET /?search=python → request.args['search'] = 'python'. "
                       "POST with form data → request.form['title'] = 'Clean Code'. "
                       "Different HTTP mechanisms for passing data to the server."
    },
    {
        "q": "What is ACID in databases?",
        "options": [
            "A PostgreSQL extension for chemistry databases",
            "Atomicity, Consistency, Isolation, Durability — guarantees for reliable transactions",
            "A naming convention for SQL queries",
            "A type of database index"
        ],
        "answer": 1,
        "explanation": "Atomicity: all or nothing. Consistency: data follows rules. "
                       "Isolation: concurrent operations don't interfere. "
                       "Durability: committed data survives crashes."
    },
    {
        "q": "Why validate on the server even when HTML forms have 'required' and 'min/max'?",
        "options": [
            "HTML validation is unreliable",
            "Server-side validation is the only real protection — anyone can bypass client-side with curl, DevTools, or disabled JS",
            "It makes the server faster",
            "It's a Flask requirement"
        ],
        "answer": 1,
        "explanation": "curl -X POST /books/add -d 'title=&year=99999' bypasses ALL HTML validation. "
                       "Client validation is for UX (user convenience). "
                       "Server validation is for SECURITY (the actual gate)."
    },
]


def run_quiz():
    print("=" * 60)
    print("  LAYER 2 CHECKPOINT: Backend & Database")
    print("  Score 12/15 to proceed to Layer 3")
    print("=" * 60)
    print()

    shuffled = random.sample(QUESTIONS, len(QUESTIONS))
    score = 0

    for i, q in enumerate(shuffled, 1):
        print(f"Question {i}/15")
        print(f"  {q['q']}")
        print()

        for j, opt in enumerate(q["options"]):
            print(f"    {j + 1}. {opt}")

        print()
        while True:
            try:
                ans = input("  Your answer (1-4): ").strip()
                if ans in ("1", "2", "3", "4"):
                    break
                print("  Please enter 1, 2, 3, or 4.")
            except (EOFError, KeyboardInterrupt):
                print("\n\nQuiz aborted.")
                return

        chosen = int(ans) - 1
        if chosen == q["answer"]:
            print("  ✅ Correct!")
            score += 1
        else:
            correct_text = q["options"][q["answer"]]
            print(f"  ❌ Wrong. Answer: {correct_text}")

        print(f"  💡 {q['explanation']}")
        print()
        print("-" * 60)
        print()

    # Results
    print("=" * 60)
    print(f"  FINAL SCORE: {score}/15")
    print("=" * 60)

    if score >= 12:
        print()
        print("  🎉 PASSED! You're ready for Layer 3 (REST APIs & Auth).")
        print("  Next: mybookshelf/layer3/")
    else:
        print()
        print(f"  📚 Need {12 - score} more correct. Review the files and try again.")
        print("  Focus areas: SQL injection, CRUD operations, Flask routing.")
    print()


if __name__ == "__main__":
    run_quiz()
