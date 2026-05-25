#!/usr/bin/env python3
"""
=============================================================================
Layer 6 Checkpoint Quiz — Security & Cryptography
=============================================================================
Score 12/15 to proceed to Layer 7 (ML/DL/LLMs).
Run: python3 checkpoint_quiz.py
=============================================================================
"""

QUESTIONS = [
    {
        "q": "What is the difference between hashing and encryption?",
        "options": [
            "A) They are the same thing",
            "B) Hashing is one-way (can't recover input). Encryption is reversible with a key.",
            "C) Encryption is faster than hashing",
            "D) Hashing requires a key, encryption doesn't",
        ],
        "answer": "B",
        "explain": "Hash: input → fixed output (irreversible). SHA256('hello') → always same hash. "
                   "Encryption: plaintext + key → ciphertext. Ciphertext + key → plaintext.",
    },
    {
        "q": "Why is SHA-256 WRONG for password hashing?",
        "options": [
            "A) SHA-256 has been cracked",
            "B) SHA-256 is too fast — GPUs compute billions/sec, enabling brute-force attacks",
            "C) SHA-256 produces collisions",
            "D) SHA-256 is reversible",
        ],
        "answer": "B",
        "explain": "SHA-256 is SECURE for integrity checks but TOO FAST for passwords. "
                   "bcrypt/argon2 are intentionally slow (~250ms) making brute-force impractical.",
    },
    {
        "q": "What is SQL injection?",
        "options": [
            "A) Injecting SQL files into the database folder",
            "B) Inserting malicious SQL into user input that gets executed by the database",
            "C) A type of database optimization",
            "D) Encrypting SQL queries",
        ],
        "answer": "B",
        "explain": "Input: \"'; DROP TABLE users; --\" → if concatenated into SQL, "
                   "it executes as a command. Fix: parameterized queries (placeholders, not string concat).",
    },
    {
        "q": "How do you prevent SQL injection?",
        "options": [
            "A) Escape special characters manually",
            "B) Use parameterized queries (placeholders): db.execute('SELECT * WHERE id=%s', (id,))",
            "C) Validate input length",
            "D) Use HTTPS",
        ],
        "answer": "B",
        "explain": "Parameterized queries separate code from data. The DB driver handles escaping. "
                   "Manual escaping is error-prone (you'll miss edge cases).",
    },
    {
        "q": "What is the purpose of a 'salt' in password hashing?",
        "options": [
            "A) Makes the hash longer",
            "B) Random data added before hashing — makes identical passwords produce different hashes",
            "C) Encrypts the password before hashing",
            "D) Slows down the hashing process",
        ],
        "answer": "B",
        "explain": "Without salt: all users with password '123456' have the SAME hash (rainbow table attack). "
                   "With salt: each hash is unique even for identical passwords.",
    },
    {
        "q": "What is SSRF (Server-Side Request Forgery)?",
        "options": [
            "A) Forging SSL certificates",
            "B) Tricking the server into making requests to internal services/URLs",
            "C) Spoofing the server's IP address",
            "D) Injecting requests into the browser",
        ],
        "answer": "B",
        "explain": "Attacker: /fetch?url=http://169.254.169.254/meta-data → server fetches cloud "
                   "credentials. Fix: allowlist domains, block internal IPs.",
    },
    {
        "q": "What does the 'X-Content-Type-Options: nosniff' header prevent?",
        "options": [
            "A) Prevents downloading files",
            "B) Prevents browsers from MIME-type guessing (reduces XSS risk)",
            "C) Blocks JavaScript execution",
            "D) Encrypts the response",
        ],
        "answer": "B",
        "explain": "Without nosniff: browser might interpret a text file as JavaScript (XSS). "
                   "With nosniff: browser strictly follows the Content-Type header.",
    },
    {
        "q": "In asymmetric encryption, what is the relationship between public and private keys?",
        "options": [
            "A) They are identical",
            "B) Public key encrypts, private key decrypts (or: private signs, public verifies)",
            "C) Private key is just a shorter version of public key",
            "D) Public key is stored on the server, private key on the client",
        ],
        "answer": "B",
        "explain": "Key pair: public (share with everyone) and private (keep secret). "
                   "Encrypt with public → only private can decrypt. Sign with private → public verifies.",
    },
    {
        "q": "Why use HMAC instead of plain hashing for authentication?",
        "options": [
            "A) HMAC is faster",
            "B) HMAC requires a secret key — only someone with the key can produce/verify it",
            "C) HMAC produces shorter hashes",
            "D) HMAC is reversible",
        ],
        "answer": "B",
        "explain": "Plain hash: anyone can compute SHA256('hello'). "
                   "HMAC: need the secret key to produce the correct hash. Used in JWT, API auth, webhooks.",
    },
    {
        "q": "What is a timing attack on password comparison?",
        "options": [
            "A) Attacking during server maintenance windows",
            "B) Measuring comparison time to guess correct bytes (== exits early on mismatch)",
            "C) Sending many requests simultaneously",
            "D) Exploiting timezone differences",
        ],
        "answer": "B",
        "explain": "'==' returns False immediately on first wrong byte. Attacker measures: "
                   "longer comparison = more correct bytes. Fix: hmac.compare_digest() (constant time).",
    },
    {
        "q": "What is the principle of 'least privilege'?",
        "options": [
            "A) Users should have all permissions by default",
            "B) Give each user/process only the MINIMUM permissions needed to do their job",
            "C) Only admins should have any permissions",
            "D) Remove all permissions after each session",
        ],
        "answer": "B",
        "explain": "Docker: non-root user. DB: app user can't DROP tables. API: users can't access admin routes. "
                   "If compromised, damage is LIMITED to what that role can do.",
    },
    {
        "q": "What does 'defense in depth' mean?",
        "options": [
            "A) Using the strongest single security measure",
            "B) Multiple layers of security — if one fails, others still protect",
            "C) Encrypting data multiple times",
            "D) Having a deep knowledge of security",
        ],
        "answer": "B",
        "explain": "Layers: nginx (rate limit) → app (auth check) → DB (row-level security). "
                   "If nginx is bypassed, app auth still blocks. If auth is broken, DB limits damage.",
    },
    {
        "q": "Why should error messages NOT reveal internal details?",
        "options": [
            "A) It makes the UI look unprofessional",
            "B) Stack traces reveal file paths, versions, and logic — helping attackers find vulnerabilities",
            "C) Error messages slow down the server",
            "D) Users might fix bugs themselves",
        ],
        "answer": "B",
        "explain": "Stack trace: '/app/auth.py line 42, bcrypt version 4.0.1, PostgreSQL 16.1'. "
                   "Attacker now knows: file structure, library versions (check for CVEs), DB type.",
    },
    {
        "q": "What is the purpose of rate limiting on a login endpoint?",
        "options": [
            "A) Improve server performance",
            "B) Prevent brute-force password attacks (limit guesses per minute)",
            "C) Reduce database load",
            "D) Comply with GDPR",
        ],
        "answer": "B",
        "explain": "Without limit: attacker tries 1M passwords/minute. With 3/minute limit: "
                   "8-char password would take 1000+ years. Combined with lockout = very secure.",
    },
    {
        "q": "What is Base64 encoding?",
        "options": [
            "A) An encryption algorithm",
            "B) A format conversion (binary to text) — NOT security, anyone can decode it",
            "C) A hashing function",
            "D) A compression algorithm",
        ],
        "answer": "B",
        "explain": "Base64 is NOT encryption! It just converts binary to text characters. "
                   "JWT payloads are Base64-encoded — anyone can read them. The signature prevents tampering, not reading.",
    },
]


def run_quiz():
    print("\n" + "=" * 60)
    print("  LAYER 6 CHECKPOINT: Security & Cryptography")
    print("  Score 12/15 to proceed to Layer 7")
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
        print("  ✓ PASSED! Ready for Layer 7: ML/DL/LLMs")
    else:
        print("  ✗ Review the material and try again.")
        print("  Focus on: injection types, crypto primitives, OWASP categories")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    run_quiz()
