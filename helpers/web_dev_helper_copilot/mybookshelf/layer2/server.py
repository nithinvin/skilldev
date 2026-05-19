"""
=============================================================================
Level 2.2 — Flask: The Minimal Backend
=============================================================================

QUESTIONS (answer these BEFORE reading the code):

  1. What is Flask?
     - A "micro" web framework for Python
     - "Micro" = minimal core, no opinions on DB or auth (you choose)
     - Compare to Django (batteries-included) or FastAPI (async-first)
     - Flask handles: routing, request parsing, response building, templating

  2. What is a route?
     - A URL pattern mapped to a Python function
     - @app.route('/books') → when someone visits /books, run this function
     - The function returns what the browser receives (HTML, JSON, redirect)

  3. What's the difference between GET and POST?
     - GET: "give me data" (idempotent, safe, cacheable, bookmarkable)
     - POST: "process this data" (side effects, not cacheable, has a body)
     - GET /books → list books. POST /books → create a new book.
     - Rule: NEVER modify data on GET (search bots will trigger it!)

  4. What is a template?
     - HTML with placeholders that get filled in by the server
     - Static HTML: same for everyone
     - Template: server fills in {{ book.title }} with actual data per request
     - Jinja2 auto-escapes HTML → prevents XSS attacks

  5. What is url_for()?
     - Generates a URL for a given function name
     - url_for('index') → '/'
     - Why not hardcode? If you rename a route, url_for still works.
     - Also handles static files: url_for('static', filename='style.css')

  6. What is request.args vs request.form?
     - request.args = query parameters from URL (?search=python)
     - request.form = form data from POST body (the form fields)
     - request.json = JSON body from API requests (Layer 3)

=============================================================================
HOW TO RUN:
  cd mybookshelf/layer2
  python3 -m venv venv
  source venv/bin/activate
  pip install flask psycopg2-binary
  python3 server.py

  Then open: http://localhost:5000
=============================================================================
"""

from flask import Flask, render_template, request, redirect, url_for, flash
import os

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "dev-secret-change-in-production")
# Q: What is secret_key for?
# Flask uses it to sign session cookies and flash messages.
# In production, this MUST be a random secret (not hardcoded).
# We'll handle this properly in Layer 3 (environment variables).


# =============================================================================
# DATABASE OR IN-MEMORY MODE
# =============================================================================
# Try to import the DB module. If PostgreSQL isn't set up yet,
# fall back to in-memory storage so you can still learn Flask.

try:
    from db import get_all_books, add_book, delete_book, update_book, get_book_by_id
    USE_DB = True
    print("✅ Connected to PostgreSQL database")
except Exception as e:
    USE_DB = False
    print(f"⚠️  Database not available ({e}). Using in-memory storage.")
    print("   Set up PostgreSQL (see schema.sql) to enable persistent storage.")

# In-memory fallback (same as Level 2.2 plan — data lost on restart!)
if not USE_DB:
    _books = [
        {"id": 1, "title": "Code", "author": "Charles Petzold", "year": 1999, "rating": 5},
        {"id": 2, "title": "The C Programming Language", "author": "K&R", "year": 1978, "rating": 5},
        {"id": 3, "title": "SICP", "author": "Abelson & Sussman", "year": 1996, "rating": 4},
        {"id": 4, "title": "Clean Code", "author": "Robert Martin", "year": 2008, "rating": 3},
        {"id": 5, "title": "Introduction to Algorithms", "author": "Cormen et al.", "year": 2009, "rating": 4},
    ]
    _next_id = 6

    def get_all_books(search=None):
        if search:
            s = search.lower()
            return [b for b in _books
                    if s in b["title"].lower() or s in b["author"].lower()]
        return _books[:]

    def add_book(title, author, year, rating):
        global _next_id
        book = {"id": _next_id, "title": title, "author": author,
                "year": year, "rating": rating}
        _next_id += 1
        _books.append(book)
        return book["id"]

    def delete_book(book_id):
        global _books
        _books = [b for b in _books if b["id"] != book_id]

    def update_book(book_id, title, author, year, rating):
        for b in _books:
            if b["id"] == book_id:
                b["title"] = title
                b["author"] = author
                b["year"] = year
                b["rating"] = rating
                return True
        return False

    def get_book_by_id(book_id):
        for b in _books:
            if b["id"] == book_id:
                return b
        return None


# =============================================================================
# ROUTES
# =============================================================================

@app.route("/")
def index():
    """
    Home page — list all books with optional search.
    
    Q: Why request.args and not request.form?
       Because search comes from the URL: /?search=python
       GET requests put data in the URL (query params).
       POST requests put data in the body (form fields).
    """
    search = request.args.get("search", "").strip()
    books = get_all_books(search=search if search else None)
    return render_template("index.html", books=books, search=search)


@app.route("/books/add", methods=["GET", "POST"])
def add_book_route():
    """
    Add a new book.
    
    Q: Why does this handle both GET and POST?
       GET /books/add → show the empty form
       POST /books/add → process the submitted form data
       Same URL, different actions based on HTTP method.
    """
    if request.method == "POST":
        # Validate input
        # Q: Why validate on the server? Can't we just use HTML5 'required'?
        # Client-side validation is for UX (instant feedback).
        # Server-side validation is for SECURITY (anyone can bypass client checks with curl).
        title = request.form.get("title", "").strip()
        author = request.form.get("author", "").strip()
        year_str = request.form.get("year", "").strip()
        rating_str = request.form.get("rating", "").strip()

        errors = []
        if not title:
            errors.append("Title is required.")
        if not author:
            errors.append("Author is required.")

        try:
            year = int(year_str)
            if year < 1800 or year > 2100:
                errors.append("Year must be between 1800 and 2100.")
        except ValueError:
            errors.append("Year must be a number.")
            year = None

        try:
            rating = int(rating_str)
            if rating < 1 or rating > 5:
                errors.append("Rating must be between 1 and 5.")
        except ValueError:
            errors.append("Rating must be a number (1-5).")
            rating = None

        if errors:
            # Q: What is flash()? Shows a one-time message on the next page load.
            # It's stored in the session cookie and cleared after display.
            for err in errors:
                flash(err, "error")
            return render_template("add_book.html",
                                   title=title, author=author,
                                   year=year_str, rating=rating_str)

        add_book(title=title, author=author, year=year, rating=rating)
        flash(f'Added "{title}" to your bookshelf!', "success")
        return redirect(url_for("index"))
        # Q: Why redirect after POST? (Post/Redirect/Get pattern)
        # Without redirect: refreshing the page re-submits the form (duplicate entry!)
        # With redirect: browser does a GET → safe to refresh.

    return render_template("add_book.html",
                           title="", author="", year="", rating="")


@app.route("/books/<int:book_id>/edit", methods=["GET", "POST"])
def edit_book_route(book_id):
    """
    Edit an existing book.
    
    Q: What is <int:book_id> in the route?
       A URL parameter. Flask extracts it and passes as an argument.
       <int:...> also validates it's an integer (returns 404 if not).
    """
    book = get_book_by_id(book_id)
    if not book:
        flash("Book not found.", "error")
        return redirect(url_for("index"))

    if request.method == "POST":
        title = request.form.get("title", "").strip()
        author = request.form.get("author", "").strip()
        year = int(request.form.get("year", 0))
        rating = int(request.form.get("rating", 0))

        if title and author and 1800 <= year <= 2100 and 1 <= rating <= 5:
            update_book(book_id, title=title, author=author, year=year, rating=rating)
            flash(f'Updated "{title}".', "success")
            return redirect(url_for("index"))
        else:
            flash("Invalid input. Check all fields.", "error")

    return render_template("edit_book.html", book=book)


@app.route("/books/<int:book_id>/delete", methods=["POST"])
def delete_book_route(book_id):
    """
    Delete a book.
    
    Q: Why is this POST and not GET?
       GET requests should be SAFE (no side effects).
       If delete were GET: a bot crawling links, a browser prefetching,
       or an <img src="/books/1/delete"> could delete your data!
       POST requires an intentional form submission.
    """
    delete_book(book_id)
    flash("Book deleted.", "success")
    return redirect(url_for("index"))


# =============================================================================
# ERROR HANDLERS
# =============================================================================

@app.errorhandler(404)
def not_found(e):
    """Custom 404 page. Q: What status code does the browser receive here?"""
    return render_template("404.html"), 404


@app.errorhandler(500)
def server_error(e):
    """Q: When does a 500 happen? Unhandled exceptions in your code."""
    return render_template("500.html"), 500


# =============================================================================
# RUN
# =============================================================================

if __name__ == "__main__":
    print("\n📚 MyBookShelf Server (Layer 2)")
    print(f"   Storage: {'PostgreSQL' if USE_DB else 'In-Memory (data lost on restart!)'}")
    print(f"   Open: http://localhost:5000\n")
    app.run(debug=True, port=5000)
    # Q: What does debug=True do?
    #   1. Auto-reloads when you edit code (no restart needed!)
    #   2. Shows detailed error pages in the browser
    #   NEVER use debug=True in production — exposes internals!


# =============================================================================
# BREAK IT EXERCISES:
# =============================================================================
# 1. Remove app.secret_key. Try to use flash(). What error do you get?
# 2. Change delete route to methods=["GET"]. Now visit /books/1/delete in browser.
#    The book is deleted just by visiting the URL! (That's why POST matters)
# 3. Remove the redirect in add_book_route. Add a book, then press F5. What happens?
# 4. Remove .strip() from form inputs. Try adding a book with title "  " (spaces only).
# 5. Try submitting the form with curl:
#    curl -X POST http://localhost:5000/books/add -d "title=Test&author=Me&year=2020&rating=3"
#    This bypasses ALL client-side validation. Server validation catches it.
