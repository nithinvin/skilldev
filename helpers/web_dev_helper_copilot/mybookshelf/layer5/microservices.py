#!/usr/bin/env python3
"""
=============================================================================
Layer 5.4 — Microservices: Splitting a Monolith
=============================================================================
PURPOSE: Demonstrate microservice architecture by splitting the book service
into independent services that communicate via HTTP APIs.

QUESTIONS:
  1. What is a monolith?
     One big application that does everything (API, auth, search, analytics).
     Pros: simple to develop, deploy, debug.
     Cons: one bug crashes everything, can't scale parts independently.

  2. What is a microservice?
     Small, independent service that does ONE thing well.
     Each has its own database, deployable independently.
     Communicates with other services via HTTP/gRPC/message queues.

  3. When should you use microservices?
     START with a monolith! Split ONLY when:
     - Team is large (>10 devs stepping on each other)
     - Parts need independent scaling (search gets 100x more traffic)
     - Parts need different tech stacks (ML service in Python, API in Go)
     NEVER start with microservices. It's premature complexity.

  4. What problems do microservices introduce?
     - Network calls fail (timeouts, retries, circuit breakers)
     - Distributed transactions (no simple rollback across services)
     - Service discovery (how does service A find service B?)
     - Debugging spans multiple services (need distributed tracing)

RUN:
  python3 microservices.py
  # Starts two Flask apps on different ports to demonstrate the pattern.
=============================================================================
"""

import json
import threading
import time
from urllib.request import Request, urlopen
from urllib.error import URLError

# Q: In real microservices, each service is a SEPARATE repo/container.
# Here we simulate two services in one file for learning purposes.

# === SERVICE 1: Book Catalog Service (port 5001) ===
# Responsibilities: CRUD operations on books. Owns the "books" database.

# === SERVICE 2: Review Service (port 5002) ===
# Responsibilities: User reviews & ratings. Owns the "reviews" database.

# === API Gateway (port 5000) ===
# Responsibilities: Routes requests to correct service. Auth. Rate limiting.
# This is what nginx does in production.


try:
    from flask import Flask, jsonify, request as flask_request
    HAS_FLASK = True
except ImportError:
    HAS_FLASK = False


if HAS_FLASK:
    # =========================================================================
    # BOOK CATALOG SERVICE (port 5001)
    # =========================================================================
    catalog_app = Flask("catalog_service")
    catalog_db = [
        {"id": 1, "title": "Clean Code", "author": "Robert C. Martin", "year": 2008},
        {"id": 2, "title": "DDIA", "author": "Martin Kleppmann", "year": 2017},
        {"id": 3, "title": "The Pragmatic Programmer", "author": "David Thomas", "year": 1999},
    ]

    @catalog_app.route("/books", methods=["GET"])
    def catalog_list():
        return jsonify(catalog_db)

    @catalog_app.route("/books/<int:book_id>", methods=["GET"])
    def catalog_get(book_id):
        book = next((b for b in catalog_db if b["id"] == book_id), None)
        if not book:
            return jsonify({"error": "Book not found"}), 404
        return jsonify(book)

    # =========================================================================
    # REVIEW SERVICE (port 5002)
    # =========================================================================
    review_app = Flask("review_service")
    reviews_db = [
        {"id": 1, "book_id": 1, "user": "nithin", "rating": 5, "text": "Life-changing book"},
        {"id": 2, "book_id": 1, "user": "alice", "rating": 4, "text": "Good but verbose"},
        {"id": 3, "book_id": 2, "user": "nithin", "rating": 5, "text": "Best systems book ever"},
    ]

    @review_app.route("/reviews/<int:book_id>", methods=["GET"])
    def get_reviews(book_id):
        book_reviews = [r for r in reviews_db if r["book_id"] == book_id]
        avg_rating = (
            sum(r["rating"] for r in book_reviews) / len(book_reviews)
            if book_reviews else 0
        )
        return jsonify({
            "book_id": book_id,
            "reviews": book_reviews,
            "average_rating": round(avg_rating, 1),
            "count": len(book_reviews),
        })

    @review_app.route("/reviews", methods=["POST"])
    def add_review():
        data = flask_request.get_json()
        review = {
            "id": len(reviews_db) + 1,
            "book_id": data["book_id"],
            "user": data["user"],
            "rating": data["rating"],
            "text": data.get("text", ""),
        }
        reviews_db.append(review)
        return jsonify(review), 201

    # =========================================================================
    # API GATEWAY (port 5000)
    # =========================================================================
    gateway_app = Flask("api_gateway")

    # Q: What does the API Gateway do?
    # 1. Single entry point for clients (they don't know about internal services)
    # 2. Aggregates data from multiple services into one response
    # 3. Handles auth (verify JWT once, not in every service)
    # 4. Rate limiting, logging, metrics

    @gateway_app.route("/api/books/<int:book_id>", methods=["GET"])
    def gateway_book_detail(book_id):
        """
        Aggregate data from BOTH services into one response.
        Q: This is the "Backend for Frontend" (BFF) pattern.
        Client makes ONE request. Gateway calls multiple services internally.
        Without gateway: client makes 2 requests (slow on mobile, CORS issues).
        """
        try:
            # Call Book Catalog Service
            book_resp = urlopen(f"http://localhost:5001/books/{book_id}", timeout=5)
            book = json.loads(book_resp.read())
        except URLError:
            return jsonify({"error": "Catalog service unavailable"}), 503
            # Q: 503 = Service Unavailable. Gateway is up but backend is down.

        try:
            # Call Review Service
            review_resp = urlopen(f"http://localhost:5002/reviews/{book_id}", timeout=5)
            reviews = json.loads(review_resp.read())
        except URLError:
            # Q: Graceful degradation: if reviews fail, still return the book!
            reviews = {"reviews": [], "average_rating": None, "count": 0}

        # Aggregate response
        return jsonify({
            "book": book,
            "reviews": reviews["reviews"],
            "average_rating": reviews["average_rating"],
            "review_count": reviews["count"],
        })

    @gateway_app.route("/api/books", methods=["GET"])
    def gateway_book_list():
        try:
            resp = urlopen("http://localhost:5001/books", timeout=5)
            books = json.loads(resp.read())
            return jsonify(books)
        except URLError:
            return jsonify({"error": "Catalog service unavailable"}), 503


def run_services():
    """Start all three services in separate threads (for demo only)."""
    print("=" * 60)
    print("  MICROSERVICES DEMO")
    print("  Starting 3 services...")
    print("=" * 60)

    # Start services in background threads
    # Q: In production, these are separate containers. Here we cheat with threads.
    threads = [
        threading.Thread(
            target=lambda: catalog_app.run(port=5001, debug=False, use_reloader=False),
            daemon=True,
        ),
        threading.Thread(
            target=lambda: review_app.run(port=5002, debug=False, use_reloader=False),
            daemon=True,
        ),
        threading.Thread(
            target=lambda: gateway_app.run(port=5000, debug=False, use_reloader=False),
            daemon=True,
        ),
    ]

    for t in threads:
        t.start()

    time.sleep(1)  # Wait for services to start

    print("\n  Services running:")
    print("    Gateway:  http://localhost:5000/api/books")
    print("    Catalog:  http://localhost:5001/books")
    print("    Reviews:  http://localhost:5002/reviews/1")
    print("\n  Try:")
    print("    curl http://localhost:5000/api/books/1")
    print("    curl http://localhost:5000/api/books")
    print("\n  Press Ctrl+C to stop.\n")

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n  Shutting down...")


# === DEMO WITHOUT FLASK (concepts only) ===
def explain_concepts():
    """If Flask isn't available, explain the concepts."""
    print("""
=============================================================================
MICROSERVICES ARCHITECTURE — Concepts
=============================================================================

MONOLITH vs MICROSERVICES:

    Monolith (Layer 3):              Microservices (Layer 5):
    ┌──────────────────┐             ┌─────────┐  ┌─────────┐  ┌─────────┐
    │   MyBookShelf    │             │ Catalog │  │ Reviews │  │  Auth   │
    │                  │     →       │ Service │  │ Service │  │ Service │
    │ Books + Reviews  │             └────┬────┘  └────┬────┘  └────┬────┘
    │ + Auth + Search  │                  │            │            │
    └──────────────────┘             ┌────┴────────────┴────────────┴────┐
                                     │         API Gateway (nginx)       │
                                     └──────────────────────────────────┘

COMMUNICATION PATTERNS:

    1. Synchronous (HTTP/gRPC):
       Gateway → Catalog: "Give me book #1"
       Catalog → Gateway: "{id: 1, title: 'Clean Code'}"
       + Simple, immediate response
       - Tight coupling, cascade failures

    2. Asynchronous (Message Queue — RabbitMQ, Kafka):
       User adds review → Review Service publishes event
       → Catalog Service listens: "Update average rating"
       → Email Service listens: "Notify book author"
       + Decoupled, resilient
       - Harder to debug, eventual consistency

WHEN TO SPLIT:
    Start with a monolith. Split ONLY when you hit these problems:
    1. Deployment conflicts (5 teams, 1 codebase, merge hell)
    2. Scaling issues (search needs 10 servers, auth needs 1)
    3. Technology constraints (ML needs Python, API needs Go)

    NEVER split because "microservices are trendy."
    A bad microservice architecture is 10x worse than a monolith.
=============================================================================
    """)


if __name__ == "__main__":
    if HAS_FLASK:
        run_services()
    else:
        explain_concepts()
        print("Install Flask to run the live demo: pip install flask")
