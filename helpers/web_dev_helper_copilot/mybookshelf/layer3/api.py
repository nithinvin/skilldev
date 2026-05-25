"""
=============================================================================
Level 3.2 — REST API with Flask
=============================================================================

QUESTIONS (answer before reading):

  1. What is a REST API?
     - A server that returns DATA (JSON) instead of HTML pages
     - Any client can consume it: browser, mobile app, CLI, another server
     - Uses HTTP verbs meaningfully: GET=read, POST=create, PUT=update, DELETE=delete

  2. What is JSON?
     - JavaScript Object Notation — universal data format
     - {"key": "value", "num": 42, "list": [1,2,3]}
     - Language-agnostic (Python, Go, Java all use it)

  3. HTTP Status Codes:
     - 200 OK          → Success (read/update)
     - 201 Created     → Success (new resource created)
     - 204 No Content  → Success (deleted, nothing to return)
     - 400 Bad Request → Client sent invalid data
     - 401 Unauthorized→ Not logged in (who are you?)
     - 403 Forbidden   → Logged in but not allowed (you can't do this)
     - 404 Not Found   → Resource doesn't exist
     - 500 Server Error→ Bug in server code

  4. Why separate API from HTML rendering?
     - Layer 2: Flask returns HTML (tightly coupled to one frontend)
     - Layer 3: Flask returns JSON (ANY frontend can use it)
     - Same data, different presentations: web, mobile, CLI

=============================================================================
HOW TO RUN:
  cd mybookshelf/layer3
  python3 -m venv venv && source venv/bin/activate
  pip install -r requirements.txt
  python3 api.py

  Test: curl http://localhost:5000/api/books | python3 -m json.tool
  Docs: http://localhost:5000/api/docs (if using FastAPI alternative)
=============================================================================
"""

from flask import Flask, jsonify, request, abort
from functools import wraps
import os

app = Flask(__name__)
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "dev-secret-change-in-production")

# =============================================================================
# DATABASE (try PostgreSQL, fallback to in-memory)
# =============================================================================
try:
    from db import get_all_books, get_book_by_id, add_book, update_book, delete_book
    USE_DB = True
    print("✅ Connected to PostgreSQL")
except Exception as e:
    USE_DB = False
    print(f"⚠️  No database ({e}). Using in-memory storage.")

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
            return [b for b in _books if s in b["title"].lower() or s in b["author"].lower()]
        return _books[:]

    def get_book_by_id(book_id):
        return next((b for b in _books if b["id"] == book_id), None)

    def add_book(title, author, year, rating):
        global _next_id
        book = {"id": _next_id, "title": title, "author": author, "year": year, "rating": rating}
        _next_id += 1
        _books.append(book)
        return book["id"]

    def update_book(book_id, title, author, year, rating):
        for b in _books:
            if b["id"] == book_id:
                b.update({"title": title, "author": author, "year": year, "rating": rating})
                return True
        return False

    def delete_book(book_id):
        global _books
        before = len(_books)
        _books = [b for b in _books if b["id"] != book_id]
        return len(_books) < before


# =============================================================================
# AUTH (import from auth module)
# =============================================================================
try:
    from auth import hash_password, verify_password, create_token, require_auth, require_role
    AUTH_AVAILABLE = True
    print("✅ Auth module loaded")
except ImportError:
    AUTH_AVAILABLE = False
    print("⚠️  Auth module not available. All routes are public.")

    def require_auth(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            return f(*args, **kwargs)
        return decorated

    def require_role(role):
        def decorator(f):
            @wraps(f)
            def decorated(*args, **kwargs):
                return f(*args, **kwargs)
            return decorated
        return decorator


# =============================================================================
# API ROUTES — BOOKS
# =============================================================================

@app.route("/api/books", methods=["GET"])
def list_books():
    """
    GET /api/books?search=python&sort=year&order=desc

    Q: Why return JSON and not HTML?
       JSON is data. The CLIENT decides how to display it.
       A web app renders a table. A mobile app renders a list.
       A CLI prints text. Same API, different presentations.
    """
    search = request.args.get("search")
    books = get_all_books(search=search)

    # Sorting (API-level, not DB-level for in-memory mode)
    sort_by = request.args.get("sort", "id")
    order = request.args.get("order", "asc")

    allowed_sorts = {"id", "title", "author", "year", "rating"}
    if sort_by in allowed_sorts:
        reverse = (order == "desc")
        books = sorted(books, key=lambda b: b.get(sort_by, ""), reverse=reverse)

    return jsonify({
        "books": books,
        "count": len(books),
        "search": search,
    })


@app.route("/api/books/<int:book_id>", methods=["GET"])
def get_book(book_id):
    """
    GET /api/books/42

    Q: What is <int:book_id>?
       A path parameter. Flask extracts it from the URL.
       <int:...> also validates it's an integer → 404 if not.
    """
    book = get_book_by_id(book_id)
    if not book:
        abort(404, description="Book not found")
    return jsonify(book)


@app.route("/api/books", methods=["POST"])
@require_auth
def create_book():
    """
    POST /api/books
    Body: {"title": "...", "author": "...", "year": 2024, "rating": 5}
    Header: Authorization: Bearer <token>

    Q: Why require_auth here?
       Anyone can READ books (GET). But CREATING requires you to be logged in.
       This is authorization — controlling who can do what.
    """
    data = request.get_json()

    # Validate
    if not data:
        abort(400, description="Request body must be JSON (set Content-Type: application/json)")

    errors = []
    title = data.get("title", "").strip() if isinstance(data.get("title"), str) else ""
    author = data.get("author", "").strip() if isinstance(data.get("author"), str) else ""

    if not title:
        errors.append("title is required")
    if not author:
        errors.append("author is required")

    try:
        year = int(data.get("year", 0))
        if year < 1800 or year > 2100:
            errors.append("year must be between 1800 and 2100")
    except (TypeError, ValueError):
        errors.append("year must be an integer")
        year = None

    try:
        rating = int(data.get("rating", 0))
        if rating < 1 or rating > 5:
            errors.append("rating must be between 1 and 5")
    except (TypeError, ValueError):
        errors.append("rating must be an integer (1-5)")
        rating = None

    if errors:
        return jsonify({"error": "Validation failed", "details": errors}), 400

    book_id = add_book(title=title, author=author, year=year, rating=rating)
    book = get_book_by_id(book_id) or {"id": book_id, "title": title, "author": author, "year": year, "rating": rating}

    return jsonify(book), 201
    # Q: Why 201 and not 200?
    # 201 Created = "I made a new resource for you."
    # 200 OK = "Here's what you asked for" (reads/updates).


@app.route("/api/books/<int:book_id>", methods=["PUT"])
@require_auth
def update_book_route(book_id):
    """
    PUT /api/books/42
    Body: {"title": "...", "author": "...", "year": 2024, "rating": 5}

    Q: PUT vs PATCH?
       PUT = replace the ENTIRE resource (send all fields)
       PATCH = partial update (send only changed fields)
       We use PUT here for simplicity. Real APIs often support both.
    """
    data = request.get_json()
    if not data:
        abort(400, description="Request body must be JSON")

    book = get_book_by_id(book_id)
    if not book:
        abort(404, description="Book not found")

    title = data.get("title", book["title"])
    author = data.get("author", book["author"])
    year = data.get("year", book["year"])
    rating = data.get("rating", book["rating"])

    update_book(book_id, title=title, author=author, year=int(year), rating=int(rating))
    updated = get_book_by_id(book_id) or {"id": book_id, "title": title, "author": author, "year": year, "rating": rating}
    return jsonify(updated)


@app.route("/api/books/<int:book_id>", methods=["DELETE"])
@require_auth
@require_role("admin")
def delete_book_route(book_id):
    """
    DELETE /api/books/42

    Q: Why require admin role?
       Anyone can add books (authenticated).
       Only admins can DELETE — destructive action needs higher privilege.
       This is Role-Based Access Control (RBAC).
    """
    book = get_book_by_id(book_id)
    if not book:
        abort(404, description="Book not found")

    delete_book(book_id)
    return "", 204
    # Q: Why 204 No Content?
    # The resource is gone. There's nothing to return.
    # Returning 200 with a body also works, but 204 is more RESTful.


# =============================================================================
# AUTH ROUTES
# =============================================================================

if AUTH_AVAILABLE:
    from auth import _users, _next_user_id

    @app.route("/api/auth/register", methods=["POST"])
    def register():
        """
        POST /api/auth/register
        Body: {"username": "nithin", "email": "n@example.com", "password": "secure123"}
        """
        data = request.get_json()
        if not data:
            abort(400, description="Request body must be JSON")

        username = data.get("username", "").strip()
        email = data.get("email", "").strip()
        password = data.get("password", "")

        if not username or not email or not password:
            return jsonify({"error": "username, email, and password are required"}), 400
        if len(password) < 8:
            return jsonify({"error": "Password must be at least 8 characters"}), 400

        from auth import register_user
        result = register_user(username, email, password)
        if "error" in result:
            return jsonify(result), 409

        return jsonify(result), 201

    @app.route("/api/auth/login", methods=["POST"])
    def login():
        """
        POST /api/auth/login
        Body: {"username": "nithin", "password": "secure123"}
        Returns: {"token": "eyJ...", "user": {...}}
        """
        data = request.get_json()
        if not data:
            abort(400, description="Request body must be JSON")

        from auth import login_user
        result = login_user(data.get("username", ""), data.get("password", ""))
        if "error" in result:
            return jsonify(result), 401

        return jsonify(result)


# =============================================================================
# HEALTH CHECK
# =============================================================================

@app.route("/health")
def health():
    """
    Q: Why a health endpoint?
       Docker, load balancers, and monitoring tools ping this to check if the app is alive.
       Return 200 = healthy. Any other code = something is wrong.
    """
    return jsonify({"status": "ok", "db": USE_DB, "auth": AUTH_AVAILABLE})


# =============================================================================
# ERROR HANDLERS
# =============================================================================

@app.errorhandler(400)
@app.errorhandler(401)
@app.errorhandler(403)
@app.errorhandler(404)
@app.errorhandler(500)
def handle_error(error):
    """
    Q: Why return JSON errors instead of HTML?
       This is an API — clients expect JSON responses for everything,
       including errors. HTML error pages are useless to a mobile app.
    """
    response = {"error": getattr(error, "description", "Internal server error")}
    return jsonify(response), error.code


# =============================================================================
# RUN
# =============================================================================

if __name__ == "__main__":
    print("\n📚 MyBookShelf API (Layer 3)")
    print(f"   Storage: {'PostgreSQL' if USE_DB else 'In-Memory'}")
    print(f"   Auth: {'Enabled' if AUTH_AVAILABLE else 'Disabled (all routes public)'}")
    print(f"   Endpoints:")
    print(f"     GET    /api/books          — List all books")
    print(f"     GET    /api/books/<id>     — Get one book")
    print(f"     POST   /api/books          — Create (auth required)")
    print(f"     PUT    /api/books/<id>     — Update (auth required)")
    print(f"     DELETE /api/books/<id>     — Delete (admin only)")
    if AUTH_AVAILABLE:
        print(f"     POST   /api/auth/register  — Create account")
        print(f"     POST   /api/auth/login     — Get token")
    print(f"     GET    /health             — Health check")
    print(f"\n   Open: http://localhost:5000/api/books\n")
    app.run(debug=True, port=5000)
