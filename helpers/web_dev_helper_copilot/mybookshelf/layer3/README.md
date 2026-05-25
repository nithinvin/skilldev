# Layer 3: REST APIs, Authentication & Authorization

## What You'll Learn
- REST API design (resources, verbs, status codes)
- Flask API that returns JSON (not HTML)
- FastAPI with automatic validation and documentation
- JWT authentication (token-based auth)
- Password hashing with bcrypt
- Role-based access control (RBAC)
- API testing with pytest

## File Structure

```
mybookshelf/layer3/
├── api.py                  ← Flask REST API (main app)
├── api_fastapi.py          ← Same API in FastAPI (compare approaches)
├── auth.py                 ← JWT tokens, password hashing, decorators
├── requirements.txt        ← Python dependencies
├── tests/
│   └── test_api.py         ← pytest tests for the API
├── README.md               ← This file
└── checkpoint_quiz.py      ← Self-test: 15 questions
```

## Quick Start

```bash
cd mybookshelf/layer3
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# Run Flask API
python3 api.py

# Or run FastAPI (different port)
uvicorn api_fastapi:app --reload --port 5001
# Then visit: http://localhost:5001/docs  (automatic Swagger UI!)
```

## Test With curl

```bash
# List books
curl http://localhost:5000/api/books | python3 -m json.tool

# Search
curl "http://localhost:5000/api/books?search=code&sort=year&order=desc"

# Register
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"nithin","email":"n@example.com","password":"secure123"}'

# Login (save the token)
TOKEN=$(curl -s -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"nithin","password":"secure123"}' | python3 -c "import sys,json;print(json.load(sys.stdin)['token'])")

# Create book (auth required)
curl -X POST http://localhost:5000/api/books \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"title":"New Book","author":"Me","year":2024,"rating":4}'

# Delete (admin only — will fail as 'reader')
curl -X DELETE http://localhost:5000/api/books/1 \
  -H "Authorization: Bearer $TOKEN"
# → 403 Forbidden (requires admin role)
```

## Run Tests

```bash
pytest tests/ -v
```

## Study Order

1. **Run api.py** and test with curl commands above
2. **Read api.py** — understand routes, JSON responses, status codes
3. **Read auth.py** — understand JWT, bcrypt, decorators
4. **Run `python3 auth.py`** standalone to see hashing/tokens in action
5. **Run api_fastapi.py** — visit /docs, compare with Flask version
6. **Read tests/test_api.py** — understand how to test APIs
7. **Run tests**: `pytest tests/ -v`

## Key Differences from Layer 2

| Layer 2 | Layer 3 |
|---|---|
| Returns HTML (Jinja2 templates) | Returns JSON |
| Browser-only frontend | Any client (mobile, CLI, other services) |
| Session-based (cookies) | Token-based (JWT) |
| No access control | Role-based (reader/admin) |
| No tests | Automated tests with pytest |

## Connection to Other Layers
- **Layer 2** → Same data, different interface (JSON instead of HTML)
- **Layer 4** → This API gets Dockerized and deployed with CI/CD
- **Layer 5** → The API runs behind nginx with TLS on your Hetzner VM
- **Layer 7** → ML model predictions become new API endpoints
