# Layer 6: Security & Cryptography

## What You'll Learn
- Cryptographic primitives (hashing, HMAC, symmetric/asymmetric encryption)
- Password security (why bcrypt, not SHA256)
- OWASP Top 10 vulnerabilities with real attack examples
- Secure coding patterns (parameterized queries, input validation)
- TLS/HTTPS internals (how the handshake works)
- Security headers, rate limiting, defense in depth

## File Structure

```
mybookshelf/layer6/
├── crypto_playground.py    ← Hands-on crypto: hashing, HMAC, AES, RSA
├── security_audit.py       ← OWASP Top 10 with attack/fix examples
├── README.md               ← This file
└── checkpoint_quiz.py      ← Self-test: 15 questions
```

## Study Order

1. **Run crypto_playground.py** — see crypto in action (hashing, HMAC, keys)
2. **Read security_audit.py** — understand each OWASP vulnerability
3. **Go back to Layer 3** — find potential vulnerabilities in your own API code
4. **Think like an attacker** — for each endpoint: "How would I abuse this?"

## Key Security Principles

| Principle | Meaning | Example |
|-----------|---------|---------|
| Least Privilege | Minimum access needed | Non-root Docker user |
| Defense in Depth | Multiple layers | nginx + app + DB all validate |
| Fail Secure | Errors don't leak info | Generic "Invalid credentials" |
| Input Validation | Never trust user input | Parameterized SQL queries |
| Secure Defaults | Security without opt-in | HTTPS by default, strict CSP |

## Connection to Other Layers
- **Layer 3** → JWT auth, bcrypt passwords, role-based access
- **Layer 4** → Non-root containers, no exposed ports
- **Layer 5** → TLS, HSTS, CSP headers, rate limiting
- **Layer 7** → Adversarial ML, prompt injection (LLM security)
