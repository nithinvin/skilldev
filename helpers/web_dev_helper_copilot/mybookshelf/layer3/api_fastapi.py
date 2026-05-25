"""
=============================================================================
Level 3.3 — FastAPI: The Modern Alternative
=============================================================================

QUESTIONS:
  1. How is FastAPI different from Flask?
     - Automatic request validation via type hints + Pydantic
     - Automatic API documentation (Swagger UI at /docs)
     - Async support (async/await for I/O-bound operations)
     - Faster (built on Starlette + uvicorn ASGI server)

  2. What is Pydantic?
     - Data validation library using Python type hints
     - Define a model → Pydantic validates incoming data automatically
     - No manual if-not-data / if-field-missing checks!

  3. When to use Flask vs FastAPI?
     - Flask: simpler, huge ecosystem, great for learning, SSR templates
     - FastAPI: better for pure APIs, automatic docs, type safety, async
     - Both are valid. Industry uses both.

=============================================================================
RUN:
  pip install fastapi uvicorn pydantic
  uvicorn api_fastapi:app --reload --port 5001

  Open: http://localhost:5001/docs  ← Interactive API documentation!
=============================================================================
"""

from fastapi import FastAPI, HTTPException, Query, Depends
from pydantic import BaseModel, Field
from typing import Optional

app = FastAPI(
    title="MyBookShelf API",
    description="A book collection manager — Layer 3 (FastAPI version)",
    version="1.0.0",
)

# =============================================================================
# PYDANTIC MODELS (automatic validation!)
# =============================================================================
# Q: Compare this to Flask's manual validation in api.py.
# With Pydantic: invalid data → automatic 422 error with details.
# No manual if/else, no try/except for type conversion!

class BookCreate(BaseModel):
    """Schema for creating a new book."""
    title: str = Field(..., min_length=1, max_length=200, examples=["Clean Code"])
    author: str = Field(..., min_length=1, max_length=200, examples=["Robert Martin"])
    year: int = Field(..., ge=1800, le=2100, examples=[2008])
    rating: int = Field(..., ge=1, le=5, examples=[4])

class BookUpdate(BaseModel):
    """Schema for updating a book (all fields optional)."""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    author: Optional[str] = Field(None, min_length=1, max_length=200)
    year: Optional[int] = Field(None, ge=1800, le=2100)
    rating: Optional[int] = Field(None, ge=1, le=5)

class BookResponse(BaseModel):
    """Schema for book in responses."""
    id: int
    title: str
    author: str
    year: int
    rating: int


# =============================================================================
# IN-MEMORY DATA
# =============================================================================

books_db = [
    {"id": 1, "title": "Code", "author": "Charles Petzold", "year": 1999, "rating": 5},
    {"id": 2, "title": "The C Programming Language", "author": "K&R", "year": 1978, "rating": 5},
    {"id": 3, "title": "SICP", "author": "Abelson & Sussman", "year": 1996, "rating": 4},
    {"id": 4, "title": "Clean Code", "author": "Robert Martin", "year": 2008, "rating": 3},
    {"id": 5, "title": "Introduction to Algorithms", "author": "Cormen et al.", "year": 2009, "rating": 4},
]
next_id = 6


# =============================================================================
# ROUTES
# =============================================================================

@app.get("/api/books", summary="List all books")
def list_books(
    search: Optional[str] = Query(None, description="Search in title or author"),
    sort: str = Query("id", description="Sort by field"),
    order: str = Query("asc", description="Sort order: asc or desc"),
):
    """
    Q: Notice how query parameters become function arguments with type hints.
       FastAPI reads them from the URL automatically.
       search: Optional[str] = None means it's optional with default None.
    """
    results = books_db[:]

    if search:
        s = search.lower()
        results = [b for b in results if s in b["title"].lower() or s in b["author"].lower()]

    allowed = {"id", "title", "author", "year", "rating"}
    if sort in allowed:
        results.sort(key=lambda b: b.get(sort, ""), reverse=(order == "desc"))

    return {"books": results, "count": len(results)}


@app.get("/api/books/{book_id}", summary="Get a single book")
def get_book(book_id: int):
    """
    Q: {book_id} in the path + book_id: int in the function.
       FastAPI validates it's an integer. If not → automatic 422 error.
    """
    book = next((b for b in books_db if b["id"] == book_id), None)
    if not book:
        raise HTTPException(status_code=404, detail="Book not found")
    return book


@app.post("/api/books", status_code=201, summary="Create a new book")
def create_book(book: BookCreate):
    """
    Q: How does validation work here?
       The 'book: BookCreate' parameter tells FastAPI:
       1. Parse the request body as JSON
       2. Validate against BookCreate schema (min/max, required fields)
       3. If invalid → automatic 422 with detailed error messages
       4. If valid → pass the validated BookCreate object to this function
       
       Compare to Flask where you manually check each field!
    """
    global next_id
    new_book = {"id": next_id, **book.model_dump()}
    next_id += 1
    books_db.append(new_book)
    return new_book


@app.put("/api/books/{book_id}", summary="Update a book")
def update_book(book_id: int, book: BookUpdate):
    """PATCH/PUT with optional fields — only update what's provided."""
    existing = next((b for b in books_db if b["id"] == book_id), None)
    if not existing:
        raise HTTPException(status_code=404, detail="Book not found")

    update_data = book.model_dump(exclude_unset=True)
    # Q: exclude_unset=True means only include fields the client actually sent.
    # If they omit "year", we keep the old value instead of setting it to None.
    existing.update(update_data)
    return existing


@app.delete("/api/books/{book_id}", status_code=204, summary="Delete a book")
def delete_book(book_id: int):
    """Returns 204 No Content on success."""
    global books_db
    before = len(books_db)
    books_db = [b for b in books_db if b["id"] != book_id]
    if len(books_db) == before:
        raise HTTPException(status_code=404, detail="Book not found")


@app.get("/health", summary="Health check")
def health():
    return {"status": "ok"}


# =============================================================================
# RUN: uvicorn api_fastapi:app --reload --port 5001
# Then visit: http://localhost:5001/docs for Swagger UI
# =============================================================================
