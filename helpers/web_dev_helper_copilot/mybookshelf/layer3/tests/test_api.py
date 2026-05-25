"""
=============================================================================
Level 3.2 — Testing Your API
=============================================================================

Q: Why write tests?
   - Catch bugs BEFORE users do
   - Refactor with confidence (tests tell you if you broke something)
   - Documentation by example (tests show how the API works)
   - CI/CD: tests run on every push → bad code never deploys

Q: What is pytest?
   - Python's most popular test framework
   - Functions starting with test_ are auto-discovered
   - assert statements check expected outcomes
   - Fixtures provide reusable test setup

RUN: pytest tests/ -v
=============================================================================
"""

import pytest
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from api import app


@pytest.fixture
def client():
    """
    Q: What is a fixture?
       Reusable test setup. Every test that takes 'client' as an argument
       automatically gets a fresh test client.
    """
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


# =============================================================================
# GET /api/books
# =============================================================================

def test_list_books_returns_200(client):
    """GET /api/books should return 200 and a list."""
    response = client.get("/api/books")
    assert response.status_code == 200
    data = response.get_json()
    assert "books" in data
    assert "count" in data
    assert isinstance(data["books"], list)
    assert data["count"] == len(data["books"])


def test_list_books_search(client):
    """GET /api/books?search=code should filter results."""
    response = client.get("/api/books?search=code")
    assert response.status_code == 200
    data = response.get_json()
    # All results should contain 'code' in title or author
    for book in data["books"]:
        assert "code" in book["title"].lower() or "code" in book["author"].lower()


def test_list_books_sort(client):
    """GET /api/books?sort=year&order=asc should sort by year ascending."""
    response = client.get("/api/books?sort=year&order=asc")
    assert response.status_code == 200
    data = response.get_json()
    years = [b["year"] for b in data["books"]]
    assert years == sorted(years)


# =============================================================================
# GET /api/books/<id>
# =============================================================================

def test_get_book_exists(client):
    """GET /api/books/1 should return the book."""
    response = client.get("/api/books/1")
    assert response.status_code == 200
    data = response.get_json()
    assert data["id"] == 1
    assert "title" in data


def test_get_book_not_found(client):
    """GET /api/books/99999 should return 404."""
    response = client.get("/api/books/99999")
    assert response.status_code == 404
    data = response.get_json()
    assert "error" in data


# =============================================================================
# POST /api/books (Create)
# =============================================================================

def test_create_book_success(client):
    """POST /api/books with valid data should return 201."""
    response = client.post("/api/books", json={
        "title": "Test Book",
        "author": "Test Author",
        "year": 2024,
        "rating": 4,
    })
    assert response.status_code == 201
    data = response.get_json()
    assert data["title"] == "Test Book"
    assert "id" in data


def test_create_book_missing_fields(client):
    """POST /api/books with missing fields should return 400."""
    response = client.post("/api/books", json={"title": "Incomplete"})
    assert response.status_code == 400


def test_create_book_invalid_rating(client):
    """POST /api/books with rating > 5 should return 400."""
    response = client.post("/api/books", json={
        "title": "Bad Rating",
        "author": "Test",
        "year": 2024,
        "rating": 99,
    })
    assert response.status_code == 400


def test_create_book_no_json(client):
    """POST /api/books without JSON body should return 400."""
    response = client.post("/api/books", data="not json")
    assert response.status_code == 400


# =============================================================================
# PUT /api/books/<id> (Update)
# =============================================================================

def test_update_book_success(client):
    """PUT /api/books/1 with valid data should return 200."""
    response = client.put("/api/books/1", json={
        "title": "Updated Title",
        "author": "Updated Author",
        "year": 2000,
        "rating": 5,
    })
    assert response.status_code == 200
    data = response.get_json()
    assert data["title"] == "Updated Title"


def test_update_book_not_found(client):
    """PUT /api/books/99999 should return 404."""
    response = client.put("/api/books/99999", json={
        "title": "X", "author": "X", "year": 2000, "rating": 3,
    })
    assert response.status_code == 404


# =============================================================================
# DELETE /api/books/<id>
# =============================================================================

def test_delete_book_not_found(client):
    """DELETE /api/books/99999 should return 404."""
    response = client.delete("/api/books/99999")
    assert response.status_code == 404


# =============================================================================
# Health
# =============================================================================

def test_health(client):
    """GET /health should return 200."""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json()["status"] == "ok"
