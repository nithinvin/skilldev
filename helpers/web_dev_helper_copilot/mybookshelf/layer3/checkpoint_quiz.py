#!/usr/bin/env python3
"""Layer 3 Checkpoint Quiz — APIs, Auth & Authorization. Score 12/15 to proceed."""

import random

QUESTIONS = [
    {
        "q": "What HTTP method should you use to DELETE a resource?",
        "options": ["GET /books/1/delete", "POST /deleteBook", "DELETE /books/1", "PUT /books/1 with empty body"],
        "answer": 2,
        "explanation": "REST convention: DELETE method on the resource URL. Verbs belong in HTTP methods, not URLs."
    },
    {
        "q": "What status code means 'resource created successfully'?",
        "options": ["200 OK", "201 Created", "204 No Content", "301 Moved"],
        "answer": 1,
        "explanation": "201 Created indicates a new resource was made. 200 is for reads/updates, 204 for deletes."
    },
    {
        "q": "What's the difference between 401 and 403?",
        "options": ["401=server error, 403=client error", "401=not authenticated, 403=authenticated but not authorized", "401=not found, 403=forbidden", "They're the same"],
        "answer": 1,
        "explanation": "401: 'Who are you?' (no valid token). 403: 'I know you, but you can't do this' (wrong role)."
    },
    {
        "q": "Why use bcrypt instead of SHA-256 for password hashing?",
        "options": ["bcrypt is newer", "bcrypt is intentionally slow (prevents brute-force), SHA-256 is fast", "SHA-256 is broken", "bcrypt encrypts, SHA-256 only hashes"],
        "answer": 1,
        "explanation": "SHA-256: billions of hashes/second (bad for passwords). bcrypt: ~100/second (brute force takes centuries). The slowness IS the security."
    },
    {
        "q": "Is a JWT payload encrypted?",
        "options": ["Yes, only the server can read it", "No, it's Base64 encoded (anyone can read it), but the SIGNATURE prevents tampering", "It depends on the algorithm", "Yes, using the secret key"],
        "answer": 1,
        "explanation": "JWT = header.payload.signature. Payload is just Base64 (readable). The signature proves authenticity, not secrecy. Never put passwords in JWTs."
    },
    {
        "q": "What does the Authorization: Bearer <token> header do?",
        "options": ["Encrypts the request body", "Sends the JWT token so the server knows who's making the request", "Creates a new user session", "Enables HTTPS"],
        "answer": 1,
        "explanation": "The Bearer token identifies the user without cookies or sessions. Server decodes it to get user_id and role."
    },
    {
        "q": "Why return the same error for 'user not found' and 'wrong password'?",
        "options": ["To save server resources", "To prevent username enumeration attacks (attacker can't discover valid usernames)", "Because they're the same error internally", "To confuse hackers"],
        "answer": 1,
        "explanation": "If 'user not found' is a distinct error, attackers can try usernames until they get 'wrong password' → now they know that username exists."
    },
    {
        "q": "What is RBAC (Role-Based Access Control)?",
        "options": ["A database indexing strategy", "Assigning permissions based on user roles (admin, reader) rather than individual users", "A type of encryption", "A REST API design pattern"],
        "answer": 1,
        "explanation": "Instead of per-user permissions (complex), assign roles. Admin role can delete. Reader role can only read. Simple and scalable."
    },
    {
        "q": "What does Pydantic do in FastAPI?",
        "options": ["Handles database connections", "Automatically validates request data against type-annotated models", "Generates HTML templates", "Manages user sessions"],
        "answer": 1,
        "explanation": "Define BookCreate(title: str, rating: int = Field(ge=1, le=5)) → FastAPI auto-validates. Invalid data → 422 with details. No manual if/else needed."
    },
    {
        "q": "What is the purpose of the /health endpoint?",
        "options": ["To show API documentation", "To let monitoring tools, load balancers, and Docker check if the app is alive", "To reset the server", "To display server logs"],
        "answer": 1,
        "explanation": "Docker HEALTHCHECK, Kubernetes probes, and monitoring tools ping /health. 200 = alive. Any other code = trigger alert/restart."
    },
    {
        "q": "Why whitelist allowed sort columns instead of using user input directly?",
        "options": ["Performance optimization", "Prevents SQL injection via ORDER BY (user could inject: 'title; DROP TABLE books')", "Makes the code shorter", "Required by Flask"],
        "answer": 1,
        "explanation": "ORDER BY can't use parameterized queries (%s). If you interpolate user input directly, it's injectable. Whitelist = only known-safe values allowed."
    },
    {
        "q": "What does the @wraps(f) decorator do inside require_auth?",
        "options": ["Encrypts the function", "Preserves the original function's name and docstring (for debugging and docs)", "Makes the function async", "Adds error handling"],
        "answer": 1,
        "explanation": "Without @wraps, every decorated function would appear as 'decorated' in stack traces and Flask's URL map. @wraps copies the original metadata."
    },
    {
        "q": "What's the advantage of token-based auth (JWT) over session-based auth?",
        "options": ["Tokens are more secure", "Stateless: server doesn't store sessions, scales horizontally without shared state", "Tokens never expire", "Easier to implement"],
        "answer": 1,
        "explanation": "Sessions need server storage (or shared Redis). JWTs are self-contained — any server instance can verify them with just the secret key."
    },
    {
        "q": "Why run 'pytest tests/ -v' instead of manually testing with curl?",
        "options": ["pytest is faster", "Automated tests run on every code change, catching regressions humans would miss", "curl doesn't work with APIs", "Company policy"],
        "answer": 1,
        "explanation": "Manual testing: 'I'll just check it works.' Automated testing: 'The CI pipeline verifies EVERY endpoint on EVERY push.' Catches bugs before deploy."
    },
    {
        "q": "What HTTP header must be set when sending JSON in a POST request?",
        "options": ["Accept: text/html", "Content-Type: application/json", "Authorization: JSON", "X-Format: json"],
        "answer": 1,
        "explanation": "Content-Type tells the server how to parse the body. Without it, Flask/FastAPI may not recognize the body as JSON and return 400."
    },
]

def run_quiz():
    print("=" * 60)
    print("  LAYER 3 CHECKPOINT: APIs, Auth & Authorization")
    print("  Score 12/15 to proceed to Layer 4")
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
            print(f"  ❌ Wrong. Answer: {q['options'][q['answer']]}")
        print(f"  💡 {q['explanation']}")
        print("\n" + "-" * 60 + "\n")

    print("=" * 60)
    print(f"  FINAL SCORE: {score}/15")
    print("=" * 60)
    if score >= 12:
        print("\n  🎉 PASSED! You're ready for Layer 4 (Containers & DevOps).")
    else:
        print(f"\n  📚 Need {12 - score} more. Review auth.py and REST concepts.")
    print()

if __name__ == "__main__":
    run_quiz()
