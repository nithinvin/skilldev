# Layer 3: APIs, Authentication & Authorization

> **Goal**: Separate frontend from backend with a REST API. Add user login, JWT tokens, OAuth, and role-based access.
> **Pre-req**: Layer 2 complete — Flask app with PostgreSQL, SQL queries, Jinja2 templates.
> **Why?** Your Flask app tightly couples HTML rendering to data logic. What if you want a mobile app? A CLI tool? Another frontend? APIs let any client consume your data. Auth controls *who* can do *what*.

---

## Level 3.1 — What Is an API? REST Principles

### Questions to Answer First
1. What is an API? How is it different from a website?
2. What does REST stand for? What are its constraints?
3. What are HTTP methods (verbs) and how do they map to CRUD?
   - `GET` → Read, `POST` → Create, `PUT/PATCH` → Update, `DELETE` → Delete
4. What is JSON? Why did it replace XML for most APIs?
5. What are HTTP status codes? What do 200, 201, 400, 401, 403, 404, 500 mean?
6. What is the difference between a query parameter (`?search=foo`) and a path parameter (`/books/42`)?

### Theory (Concise)
```
REST API = HTTP + JSON + conventions

Resource: /books
  GET    /books          → List all books    → 200 OK + [...]
  POST   /books          → Create a book     → 201 Created + {...}
  GET    /books/42       → Get one book      → 200 OK + {...}
  PUT    /books/42       → Replace a book    → 200 OK + {...}
  PATCH  /books/42       → Partial update    → 200 OK + {...}
  DELETE /books/42       → Delete a book     → 204 No Content

Not REST: POST /getBooks, POST /deleteBook?id=42 (verbs in URL = anti-pattern)
```

---

## Level 3.2 — Build a REST API with Flask

### Hands-On: Convert MyBookShelf to an API

```python
# file: mybookshelf/api.py
from flask import Flask, jsonify, request, abort
from db import get_db

app = Flask(__name__)

@app.route('/api/books', methods=['GET'])
def list_books():
    """GET /api/books?search=python&sort=year&order=desc"""
    conn = get_db()
    cur = conn.cursor()

    search = request.args.get('search')
    sort = request.args.get('sort', 'created_at')
    order = request.args.get('order', 'desc')

    # Q: Why whitelist sort columns instead of using user input directly?
    allowed_sorts = {'title', 'author', 'year', 'rating', 'created_at'}
    if sort not in allowed_sorts:
        sort = 'created_at'
    if order not in ('asc', 'desc'):
        order = 'desc'

    if search:
        cur.execute(
            f"SELECT * FROM books WHERE title ILIKE %s OR author ILIKE %s ORDER BY {sort} {order}",
            (f'%{search}%', f'%{search}%')
        )
    else:
        cur.execute(f"SELECT * FROM books ORDER BY {sort} {order}")

    books = cur.fetchall()
    cur.close()
    conn.close()

    return jsonify({"books": [dict(b) for b in books], "count": len(books)})

@app.route('/api/books', methods=['POST'])
def create_book():
    """POST /api/books  Body: {"title": "...", "author": "...", "year": 2024, "rating": 5}"""
    data = request.get_json()

    # Validation — Q: Why validate on the server even if the frontend validates too?
    if not data:
        abort(400, description="Request body must be JSON")
    required = ['title', 'author', 'year', 'rating']
    for field in required:
        if field not in data:
            abort(400, description=f"Missing field: {field}")

    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO books (title, author, year, rating) VALUES (%s, %s, %s, %s) RETURNING *",
        (data['title'], data['author'], data['year'], data['rating'])
    )
    book = dict(cur.fetchone())
    conn.commit()
    cur.close()
    conn.close()

    return jsonify(book), 201  # Q: Why 201 and not 200?

@app.route('/api/books/<int:book_id>', methods=['GET'])
def get_book(book_id):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM books WHERE id = %s", (book_id,))
    book = cur.fetchone()
    cur.close()
    conn.close()

    if not book:
        abort(404, description="Book not found")
    return jsonify(dict(book))

@app.route('/api/books/<int:book_id>', methods=['PUT'])
def update_book(book_id):
    data = request.get_json()
    if not data:
        abort(400, description="Request body must be JSON")

    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        """UPDATE books SET title = %s, author = %s, year = %s, rating = %s, updated_at = NOW()
           WHERE id = %s RETURNING *""",
        (data['title'], data['author'], data['year'], data['rating'], book_id)
    )
    book = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()

    if not book:
        abort(404, description="Book not found")
    return jsonify(dict(book))

@app.route('/api/books/<int:book_id>', methods=['DELETE'])
def delete_book(book_id):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("DELETE FROM books WHERE id = %s RETURNING id", (book_id,))
    deleted = cur.fetchone()
    conn.commit()
    cur.close()
    conn.close()

    if not deleted:
        abort(404, description="Book not found")
    return '', 204  # Q: Why 204 No Content?

@app.errorhandler(400)
@app.errorhandler(404)
@app.errorhandler(500)
def handle_error(error):
    return jsonify({"error": error.description}), error.code

if __name__ == '__main__':
    app.run(debug=True, port=5000)
```

### Test Your API with curl
```bash
# List all books
curl http://localhost:5000/api/books | python3 -m json.tool

# Create a book
curl -X POST http://localhost:5000/api/books \
  -H "Content-Type: application/json" \
  -d '{"title": "Designing Data-Intensive Applications", "author": "Martin Kleppmann", "year": 2017, "rating": 5}'

# Get one book
curl http://localhost:5000/api/books/1 | python3 -m json.tool

# Update a book
curl -X PUT http://localhost:5000/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{"title": "Code (Updated)", "author": "Charles Petzold", "year": 1999, "rating": 5}'

# Delete a book
curl -X DELETE http://localhost:5000/api/books/3

# Search
curl "http://localhost:5000/api/books?search=python&sort=year&order=asc"
```

### Break It
- Send POST without Content-Type header — what happens?
- Send invalid JSON — what error do you get?
- Send a rating of 99 — does the DB constraint catch it?
- Try to GET `/api/books/999` — do you get a proper 404?

---

## Level 3.3 — FastAPI: The Modern Alternative

### Questions to Answer First
1. What is type hinting in Python? How does FastAPI use it?
2. What is automatic documentation (Swagger/OpenAPI)? Why is it valuable?
3. What is async/await in Python? How does it differ from JS async/await?
4. What is Pydantic? How does it validate data?

### Hands-On: Same API in FastAPI
```bash
pip install fastapi uvicorn pydantic
```

```python
# file: mybookshelf/api_fastapi.py
from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
from typing import Optional
from db import get_db

app = FastAPI(title="MyBookShelf API", version="1.0")

# Pydantic models — Q: How is this different from Flask's manual validation?
class BookCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    author: str = Field(..., min_length=1, max_length=200)
    year: int = Field(..., ge=1800, le=2100)
    rating: int = Field(..., ge=1, le=5)

class BookResponse(BookCreate):
    id: int
    created_at: Optional[str] = None

@app.get("/api/books")
def list_books(search: Optional[str] = None, sort: str = "created_at", order: str = "desc"):
    # FastAPI auto-parses query params from function args — Q: How?
    conn = get_db()
    cur = conn.cursor()

    allowed_sorts = {'title', 'author', 'year', 'rating', 'created_at'}
    sort = sort if sort in allowed_sorts else 'created_at'
    order = order if order in ('asc', 'desc') else 'desc'

    if search:
        cur.execute(
            f"SELECT * FROM books WHERE title ILIKE %s OR author ILIKE %s ORDER BY {sort} {order}",
            (f'%{search}%', f'%{search}%')
        )
    else:
        cur.execute(f"SELECT * FROM books ORDER BY {sort} {order}")

    books = [dict(b) for b in cur.fetchall()]
    cur.close()
    conn.close()
    return {"books": books, "count": len(books)}

@app.post("/api/books", status_code=201)
def create_book(book: BookCreate):
    # Pydantic already validated! Q: What happens if rating=99?
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO books (title, author, year, rating) VALUES (%s, %s, %s, %s) RETURNING *",
        (book.title, book.author, book.year, book.rating)
    )
    new_book = dict(cur.fetchone())
    conn.commit()
    cur.close()
    conn.close()
    return new_book

# Run: uvicorn api_fastapi:app --reload --port 5000
# Open: http://localhost:5000/docs  ← Automatic Swagger UI!
```

---

## Level 3.4 — Authentication: Who Are You?

### Questions to Answer First
1. HTTP is stateless — so how does a server "remember" you're logged in?
2. What are cookies? What is a session?
3. What is a JWT (JSON Web Token)? How is it different from a session cookie?
4. What does "hashing a password" mean? Why bcrypt and not SHA-256?
5. Why must passwords NEVER be stored in plaintext?

### Theory (Concise)
```
Session-based auth:
  Login → Server creates session → Stores session ID in cookie → Every request sends cookie
  Pro: Server controls sessions (can revoke). Con: Server stores state.

Token-based auth (JWT):
  Login → Server creates JWT (signed, not encrypted) → Client stores it → Sends in header
  Pro: Stateless (server doesn't store sessions). Con: Can't revoke until expiry.

JWT structure:
  header.payload.signature
  eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxfQ.signature_here

  Header:  {"alg": "HS256", "typ": "JWT"}
  Payload: {"user_id": 1, "role": "admin", "exp": 1700000000}
  Signature: HMAC-SHA256(header + "." + payload, SECRET_KEY)
```

### Hands-On: Add User Auth to MyBookShelf

```sql
-- file: mybookshelf/schema_auth.sql
CREATE TABLE users (
    id              SERIAL PRIMARY KEY,
    username        VARCHAR(50) UNIQUE NOT NULL,
    email           VARCHAR(200) UNIQUE NOT NULL,
    password_hash   VARCHAR(200) NOT NULL,     -- Q: Why "hash" and not "password"?
    role            VARCHAR(20) DEFAULT 'reader' CHECK (role IN ('reader', 'admin')),
    created_at      TIMESTAMP DEFAULT NOW()
);
```

```python
# file: mybookshelf/auth.py
import bcrypt
import jwt
import datetime
from functools import wraps
from flask import request, jsonify

SECRET_KEY = "change-this-to-a-real-secret"  # Q: Where should this actually live?

def hash_password(password: str) -> str:
    """Hash a password using bcrypt."""
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()

def verify_password(password: str, password_hash: str) -> bool:
    """Verify a password against its hash."""
    return bcrypt.checkpw(password.encode(), password_hash.encode())

def create_token(user_id: int, role: str) -> str:
    """Create a JWT token."""
    payload = {
        "user_id": user_id,
        "role": role,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(hours=24),
        "iat": datetime.datetime.utcnow(),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")

def decode_token(token: str) -> dict:
    """Decode and verify a JWT token."""
    return jwt.decode(token, SECRET_KEY, algorithms=["HS256"])

def require_auth(f):
    """Decorator: require a valid JWT to access this route."""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        if not token:
            return jsonify({"error": "Missing token"}), 401
        try:
            payload = decode_token(token)
            request.user = payload  # Attach user info to request
        except jwt.ExpiredSignatureError:
            return jsonify({"error": "Token expired"}), 401
        except jwt.InvalidTokenError:
            return jsonify({"error": "Invalid token"}), 401
        return f(*args, **kwargs)
    return decorated

def require_role(role):
    """Decorator: require a specific role."""
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if request.user.get('role') != role:
                return jsonify({"error": "Insufficient permissions"}), 403  # Q: 401 vs 403?
            return f(*args, **kwargs)
        return decorated
    return decorator
```

```python
# Auth routes (add to api.py)
@app.route('/api/auth/register', methods=['POST'])
def register():
    data = request.get_json()
    password_hash = hash_password(data['password'])
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute(
            "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s) RETURNING id, username, role",
            (data['username'], data['email'], password_hash)
        )
        user = dict(cur.fetchone())
        conn.commit()
    except Exception as e:
        conn.rollback()
        return jsonify({"error": "Username or email already exists"}), 409
    finally:
        cur.close()
        conn.close()

    token = create_token(user['id'], user['role'])
    return jsonify({"token": token, "user": user}), 201

@app.route('/api/auth/login', methods=['POST'])
def login():
    data = request.get_json()
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM users WHERE username = %s", (data['username'],))
    user = cur.fetchone()
    cur.close()
    conn.close()

    if not user or not verify_password(data['password'], user['password_hash']):
        return jsonify({"error": "Invalid credentials"}), 401  # Q: Why same error for both?
    
    token = create_token(user['id'], user['role'])
    return jsonify({"token": token, "user": {"id": user['id'], "username": user['username'], "role": user['role']}})

# Protected routes
@app.route('/api/books', methods=['POST'])
@require_auth
def create_book():
    # ... only logged-in users can add books

@app.route('/api/books/<int:book_id>', methods=['DELETE'])
@require_auth
@require_role('admin')
def delete_book(book_id):
    # ... only admins can delete books
```

### Test Auth Flow
```bash
# Register
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "nithin", "email": "nithin@example.com", "password": "secure123"}'

# Login (save the token)
TOKEN=$(curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "nithin", "password": "secure123"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

echo $TOKEN

# Use token to add a book
curl -X POST http://localhost:5000/api/books \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title": "New Book", "author": "Author", "year": 2024, "rating": 4}'

# Try without token — should get 401
curl -X POST http://localhost:5000/api/books \
  -H "Content-Type: application/json" \
  -d '{"title": "New Book", "author": "Author", "year": 2024, "rating": 4}'
```

### Break It
- Decode a JWT at https://jwt.io — can you see the payload? Is the data secret?
- Change the SECRET_KEY after issuing a token — does the old token still work?
- Try to delete a book as a 'reader' — do you get 403?
- What happens if you send an expired token?

---

## Level 3.5 — OAuth 2.0: "Login with Google/GitHub"

### Questions to Answer First
1. Why would a user prefer "Login with Google" over creating yet another password?
2. What is OAuth 2.0? What problem does it solve?
3. What's the difference between authentication and authorization in OAuth?
4. What is the Authorization Code flow? Draw the sequence diagram.
5. What are access tokens vs refresh tokens?

### Theory (Concise)
```
OAuth 2.0 Authorization Code Flow:

User → clicks "Login with GitHub"
  → Browser redirects to GitHub with client_id + redirect_uri
  → User logs in on GitHub, grants permission
  → GitHub redirects back with authorization_code
  → Your server exchanges code for access_token (server-to-server)
  → Your server uses access_token to get user profile from GitHub API
  → Your server creates a session/JWT for the user

Why?
  - User never gives YOUR app their GitHub password
  - You can request specific scopes (read email, read repos, etc.)
  - User can revoke access anytime on GitHub
```

### Hands-On: GitHub OAuth
```bash
pip install requests
```

1. Register an OAuth app at https://github.com/settings/developers
2. Set callback URL to `http://localhost:5000/api/auth/github/callback`

```python
# file: mybookshelf/oauth.py (simplified)
import os
import requests
from flask import redirect, request, jsonify
from auth import create_token
from db import get_db

GITHUB_CLIENT_ID = os.environ.get('GITHUB_CLIENT_ID')
GITHUB_CLIENT_SECRET = os.environ.get('GITHUB_CLIENT_SECRET')

def register_oauth_routes(app):
    @app.route('/api/auth/github')
    def github_login():
        return redirect(
            f"https://github.com/login/oauth/authorize"
            f"?client_id={GITHUB_CLIENT_ID}&scope=user:email"
        )

    @app.route('/api/auth/github/callback')
    def github_callback():
        code = request.args.get('code')
        if not code:
            return jsonify({"error": "No code provided"}), 400

        # Exchange code for token
        token_resp = requests.post(
            "https://github.com/login/oauth/access_token",
            json={"client_id": GITHUB_CLIENT_ID, "client_secret": GITHUB_CLIENT_SECRET, "code": code},
            headers={"Accept": "application/json"}
        )
        access_token = token_resp.json().get('access_token')

        # Get user profile
        user_resp = requests.get(
            "https://api.github.com/user",
            headers={"Authorization": f"Bearer {access_token}"}
        )
        github_user = user_resp.json()

        # Create or find user in our DB
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT * FROM users WHERE email = %s", (github_user['email'] or f"{github_user['login']}@github",))
        user = cur.fetchone()

        if not user:
            cur.execute(
                "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s) RETURNING *",
                (github_user['login'], github_user['email'] or f"{github_user['login']}@github", 'oauth-no-password')
            )
            user = cur.fetchone()
            conn.commit()

        cur.close()
        conn.close()

        token = create_token(user['id'], user['role'])
        return jsonify({"token": token, "user": {"id": user['id'], "username": user['username']}})
```

---

## Level 3.6 — GraphQL: An Alternative to REST

### Questions to Answer First
1. What problem does GraphQL solve that REST doesn't? (over-fetching, under-fetching)
2. When is REST better? When is GraphQL better?
3. What is a schema in GraphQL? A resolver?
4. What is the N+1 query problem?

### Hands-On: GraphQL with Strawberry
```bash
pip install strawberry-graphql flask-cors
```

```python
# file: mybookshelf/graphql_api.py
import strawberry
from strawberry.flask.views import GraphQLView
from db import get_db
from typing import List, Optional

@strawberry.type
class Book:
    id: int
    title: str
    author: str
    year: int
    rating: int

@strawberry.type
class Query:
    @strawberry.field
    def books(self, search: Optional[str] = None) -> List[Book]:
        conn = get_db()
        cur = conn.cursor()
        if search:
            cur.execute(
                "SELECT id, title, author, year, rating FROM books WHERE title ILIKE %s",
                (f'%{search}%',)
            )
        else:
            cur.execute("SELECT id, title, author, year, rating FROM books")
        result = [Book(**dict(row)) for row in cur.fetchall()]
        cur.close()
        conn.close()
        return result

    @strawberry.field
    def book(self, id: int) -> Optional[Book]:
        conn = get_db()
        cur = conn.cursor()
        cur.execute("SELECT id, title, author, year, rating FROM books WHERE id = %s", (id,))
        row = cur.fetchone()
        cur.close()
        conn.close()
        return Book(**dict(row)) if row else None

schema = strawberry.Schema(query=Query)
# Add to Flask: app.add_url_rule("/graphql", view_func=GraphQLView.as_view("graphql", schema=schema))
```

### Test GraphQL
```bash
# Query specific fields (no over-fetching!)
curl -X POST http://localhost:5000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ books { title author } }"}'

# Query with filter
curl -X POST http://localhost:5000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ books(search: \"code\") { title rating } }"}'
```

---

## Level 3.7 — Redis: Caching & Sessions

### Questions to Answer First
1. What is Redis? Why is it faster than PostgreSQL?
2. What is a cache? What is the cache invalidation problem?
3. When should you cache? When should you NOT cache?
4. What are Redis data structures? (strings, hashes, lists, sets, sorted sets)

### Hands-On: Add Redis Caching
```bash
sudo apt install redis-server -y
sudo systemctl start redis
pip install redis

# Test Redis
redis-cli ping    # Should return PONG
redis-cli SET hello world
redis-cli GET hello
```

```python
# file: mybookshelf/cache.py
import redis
import json

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

CACHE_TTL = 300  # 5 minutes

def cache_get(key):
    data = r.get(key)
    return json.loads(data) if data else None

def cache_set(key, value, ttl=CACHE_TTL):
    r.setex(key, ttl, json.dumps(value, default=str))

def cache_delete(pattern):
    """Delete all keys matching pattern."""
    for key in r.scan_iter(match=pattern):
        r.delete(key)

# Usage in API:
# books = cache_get("books:all")
# if not books:
#     books = get_all_books()
#     cache_set("books:all", books)
# On CREATE/UPDATE/DELETE: cache_delete("books:*")
```

---

## Checkpoint Questions (Answer Before Moving to Layer 4)

1. Design a REST API for a todo-list app — what are the endpoints, methods, status codes?
2. What's the difference between 401 and 403? Give examples.
3. Decode a JWT by hand (base64). What's in the header, payload, signature?
4. Why hash passwords with bcrypt instead of SHA-256?
5. Draw the OAuth 2.0 Authorization Code flow from memory.
6. When would you choose GraphQL over REST? Give a concrete example.
7. What is cache invalidation? Why is it "one of the two hard problems in CS"?

---

**Previous**: [Layer 2 — Backend Server & Databases](layer2-backend-db.md)
**Next**: [Layer 4 — Containers & DevOps](layer4-containers-devops.md)
