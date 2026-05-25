#!/usr/bin/env python3
"""
=============================================================================
Layer 5 Checkpoint Quiz — Cloud, Production, Microservices
=============================================================================
Score 12/15 to proceed to Layer 6 (Security & Cryptography).
Run: python3 checkpoint_quiz.py
=============================================================================
"""

QUESTIONS = [
    {
        "q": "What is 'Infrastructure as Code' (IaC)?",
        "options": [
            "A) Writing code that runs on servers",
            "B) Defining servers, networks, and infrastructure in code (reproducible, version-controlled)",
            "C) Using a coding language to build hardware",
            "D) Writing documentation about infrastructure",
        ],
        "answer": "B",
        "explain": "IaC means your infrastructure is defined in files (Terraform, scripts, YAML). "
                   "Benefits: git history, code review, reproducibility, automation.",
    },
    {
        "q": "Why should you NEVER commit .env files (with secrets) to git?",
        "options": [
            "A) Git can't handle .env files",
            "B) Secrets in git history are permanent — even after deletion, they exist in old commits",
            "C) .env files are too large for git",
            "D) It slows down git operations",
        ],
        "answer": "B",
        "explain": "Git keeps ALL history. A secret committed once exists forever (even after 'deleting' it). "
                   "Bots scan GitHub for leaked secrets within minutes.",
    },
    {
        "q": "What does TLS (HTTPS) protect against?",
        "options": [
            "A) Server crashes",
            "B) SQL injection",
            "C) Eavesdropping — encrypts data in transit so attackers can't read it",
            "D) Denial of service attacks",
        ],
        "answer": "C",
        "explain": "Without TLS: passwords, tokens, data sent in PLAINTEXT. Anyone on the same WiFi "
                   "can read everything. TLS encrypts the connection end-to-end.",
    },
    {
        "q": "What is the ACME challenge (Let's Encrypt)?",
        "options": [
            "A) A coding challenge to prove you're a developer",
            "B) A process to verify you control the domain before issuing a TLS certificate",
            "C) A speed test for your server",
            "D) A security audit",
        ],
        "answer": "B",
        "explain": "Let's Encrypt needs proof you own the domain. ACME: place a file at "
                   "/.well-known/acme-challenge/... → they verify → certificate issued.",
    },
    {
        "q": "Why is the database port NOT exposed in docker-compose.prod.yml?",
        "options": [
            "A) It would conflict with the host's PostgreSQL",
            "B) Security: only internal services should access the DB, not the internet",
            "C) PostgreSQL doesn't support external connections",
            "D) Docker doesn't allow it in production mode",
        ],
        "answer": "B",
        "explain": "Exposed DB port = anyone can attempt to connect (brute-force, SQL attacks). "
                   "Internal only = only your app container can reach it via Docker network.",
    },
    {
        "q": "What is the purpose of resource limits (memory: 512M) in docker-compose?",
        "options": [
            "A) Makes the container faster",
            "B) Prevents one container from consuming all server resources (isolation)",
            "C) Required by Docker",
            "D) Reduces Docker image size",
        ],
        "answer": "B",
        "explain": "Memory leak in app → consumes all RAM → OOM killer strikes → all containers die. "
                   "With limits: only the leaking container gets killed. Others survive.",
    },
    {
        "q": "What is an API Gateway?",
        "options": [
            "A) A firewall that blocks API calls",
            "B) A single entry point that routes requests to backend services, handles auth, rate limiting",
            "C) A tool for generating API documentation",
            "D) A database for storing API responses",
        ],
        "answer": "B",
        "explain": "Client → Gateway → routes to correct microservice. Gateway handles: auth, "
                   "rate limiting, request aggregation, logging. Client doesn't know about internal services.",
    },
    {
        "q": "When should you split a monolith into microservices?",
        "options": [
            "A) Always, from the start of any project",
            "B) When the team is large, parts need independent scaling, or different tech stacks",
            "C) When you learn about microservices",
            "D) When the code reaches 1000 lines",
        ],
        "answer": "B",
        "explain": "START with a monolith. Split only when you hit real problems: deployment conflicts, "
                   "scaling needs, tech constraints. Premature microservices = unnecessary complexity.",
    },
    {
        "q": "What is 'graceful degradation' in microservices?",
        "options": [
            "A) Slowly shutting down the server",
            "B) If one service fails, others still work (return partial data instead of error)",
            "C) Gradually reducing performance under load",
            "D) Migrating from old to new service versions",
        ],
        "answer": "B",
        "explain": "Review service is down? Return book data WITHOUT reviews (partial response). "
                   "Better than returning 500 error. Users still get value.",
    },
    {
        "q": "What does HSTS (Strict-Transport-Security header) do?",
        "options": [
            "A) Encrypts the response body",
            "B) Tells browsers to ALWAYS use HTTPS for this domain (even if user types http://)",
            "C) Blocks requests from other domains",
            "D) Compresses the response",
        ],
        "answer": "B",
        "explain": "After seeing HSTS header, browser refuses HTTP for that domain for max-age seconds. "
                   "Prevents SSL-stripping attacks (downgrade from HTTPS to HTTP).",
    },
    {
        "q": "What is cloud-init?",
        "options": [
            "A) A cloud storage service",
            "B) A script that runs on FIRST BOOT of a new cloud server (setup, install, configure)",
            "C) A tool for initializing Docker containers",
            "D) A cloud monitoring service",
        ],
        "answer": "B",
        "explain": "Cloud-init: server starts → installs Docker, sets up firewall, creates users. "
                   "Server dies? Create a new one with same cloud-init → identical server in 2 min.",
    },
    {
        "q": "What is the 'maxmemory-policy allkeys-lru' Redis configuration?",
        "options": [
            "A) Blocks new writes when memory is full",
            "B) When memory limit is hit, evicts Least Recently Used keys to make room",
            "C) Deletes all keys when memory is full",
            "D) Compresses keys to save memory",
        ],
        "answer": "B",
        "explain": "LRU = Least Recently Used. When Redis hits 100MB, it removes the oldest "
                   "unused keys. Prevents Redis from consuming all server memory.",
    },
    {
        "q": "What is the difference between 'build: .' and 'image: name:tag' in docker-compose?",
        "options": [
            "A) They do the same thing",
            "B) 'build' compiles from Dockerfile (dev). 'image' pulls pre-built image (prod).",
            "C) 'build' is faster",
            "D) 'image' only works with Docker Hub",
        ],
        "answer": "B",
        "explain": "Dev: build from source code (Dockerfile). Prod: use pre-built image from CI/CD. "
                   "No source code on production server. Faster deploys, consistent builds.",
    },
    {
        "q": "Why rotate logs (max-size: 10m, max-file: 3)?",
        "options": [
            "A) Faster log searching",
            "B) Prevents logs from filling the disk (bounded to 30MB total)",
            "C) Required by Docker",
            "D) Improves application performance",
        ],
        "answer": "B",
        "explain": "Without rotation: logs grow forever → disk full → server unresponsive → EVERYTHING dies. "
                   "With rotation: max 30MB (3 × 10MB). Old logs auto-deleted.",
    },
    {
        "q": "What is the Content-Security-Policy 'default-src self' header?",
        "options": [
            "A) Allows loading resources from any domain",
            "B) Only allows loading scripts/styles/images from your own domain (prevents XSS)",
            "C) Blocks all JavaScript",
            "D) Encrypts the page content",
        ],
        "answer": "B",
        "explain": "XSS attack injects <script src='evil.com/steal.js'>. With CSP 'self': "
                   "browser REFUSES to load scripts from evil.com. Only your domain is allowed.",
    },
]


def run_quiz():
    print("\n" + "=" * 60)
    print("  LAYER 5 CHECKPOINT: Cloud, Production, Microservices")
    print("  Score 12/15 to proceed to Layer 6")
    print("=" * 60)

    score = 0
    for i, q in enumerate(QUESTIONS, 1):
        print(f"\nQ{i}. {q['q']}")
        for opt in q["options"]:
            print(f"    {opt}")

        while True:
            ans = input(f"\n  Your answer (A/B/C/D): ").strip().upper()
            if ans in ("A", "B", "C", "D"):
                break
            print("  Please enter A, B, C, or D.")

        if ans == q["answer"]:
            score += 1
            print(f"  ✓ Correct!")
        else:
            print(f"  ✗ Wrong. Answer: {q['answer']}")
        print(f"  → {q['explain']}")

    print("\n" + "=" * 60)
    print(f"  SCORE: {score}/15")
    if score >= 12:
        print("  ✓ PASSED! Ready for Layer 6: Security & Cryptography")
    else:
        print("  ✗ Review the material and try again.")
        print("  Focus on: TLS flow, microservice trade-offs, prod vs dev differences")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    run_quiz()
