#!/usr/bin/env python3
"""
=============================================================================
Layer 6.1 — Cryptography Playground
=============================================================================
PURPOSE: Hands-on exploration of cryptographic primitives.
NOT a security library — this is for LEARNING how crypto works under the hood.

QUESTIONS:
  1. What is the difference between encoding, hashing, and encryption?
     - Encoding: reversible format conversion (Base64, URL-encode). NOT security.
     - Hashing: one-way function. Can't recover input from output. For integrity.
     - Encryption: reversible with a key. For confidentiality.

  2. What is symmetric vs asymmetric encryption?
     - Symmetric: same key to encrypt and decrypt (AES). Fast. Key sharing problem.
     - Asymmetric: public key encrypts, private key decrypts (RSA). Slow. Solves key sharing.

  3. What is a digital signature?
     - Sign with private key → anyone can verify with public key.
     - Proves: (a) message came from you, (b) message wasn't modified.

  4. What is a hash collision?
     - Two different inputs producing the same hash output.
     - MD5/SHA1: collisions found → broken for security.
     - SHA256: no known collisions → safe (for now).

RUN:
  python3 crypto_playground.py
=============================================================================
"""

import hashlib
import hmac
import base64
import os
import json
import time


def section(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


# =============================================================================
# PART 1: HASHING
# =============================================================================
def demo_hashing():
    section("HASHING — One-way functions")

    message = "MyBookShelf is awesome!"

    # Different hash algorithms
    # Q: Why so many? Older ones get "broken" (collisions found).
    algorithms = {
        "MD5 (BROKEN — don't use for security)": hashlib.md5(message.encode()).hexdigest(),
        "SHA-1 (BROKEN — don't use for security)": hashlib.sha1(message.encode()).hexdigest(),
        "SHA-256 (current standard)": hashlib.sha256(message.encode()).hexdigest(),
        "SHA-512 (extra security)": hashlib.sha512(message.encode()).hexdigest(),
    }

    print(f"  Input: '{message}'\n")
    for name, digest in algorithms.items():
        print(f"  {name}:")
        print(f"    {digest}")
        print(f"    Length: {len(digest)} hex chars = {len(digest)*4} bits\n")

    # === AVALANCHE EFFECT ===
    # Q: Change one character → completely different hash. This is critical!
    print("  --- Avalanche Effect ---")
    msg1 = "hello"
    msg2 = "hellp"  # One character different
    hash1 = hashlib.sha256(msg1.encode()).hexdigest()
    hash2 = hashlib.sha256(msg2.encode()).hexdigest()
    print(f"  '{msg1}' → {hash1[:32]}...")
    print(f"  '{msg2}' → {hash2[:32]}...")

    # Count differing characters
    diff = sum(1 for a, b in zip(hash1, hash2) if a != b)
    print(f"  Difference: {diff}/64 characters changed ({diff/64*100:.0f}%)")
    print(f"  → Tiny input change = massive output change (unpredictable)\n")

    # === HASH FOR INTEGRITY ===
    # Q: How do you verify a downloaded file isn't corrupted/tampered?
    print("  --- File Integrity Check ---")
    file_content = b"This is my important file content"
    file_hash = hashlib.sha256(file_content).hexdigest()
    print(f"  File hash: {file_hash}")
    print(f"  Download file → compute hash → compare with published hash")
    print(f"  If they match: file is intact. If not: corrupted or tampered.\n")


# =============================================================================
# PART 2: HMAC (Hash-based Message Authentication Code)
# =============================================================================
def demo_hmac():
    section("HMAC — Authenticated hashing (requires a secret key)")

    # Q: Why not just hash(message)? Anyone can compute SHA256("hello").
    # HMAC = hash(key + message). Only someone WITH the key can produce/verify it.
    # Used in: JWT signatures, API authentication, webhook verification.

    secret_key = b"my-secret-key-2024"
    message = b"user_id=42&amount=100"

    # Create HMAC
    mac = hmac.new(secret_key, message, hashlib.sha256).hexdigest()
    print(f"  Message: {message.decode()}")
    print(f"  HMAC:    {mac}")

    # Verify HMAC
    # Q: Why use hmac.compare_digest instead of == ?
    # Timing attack: == exits early on first mismatch.
    # Attacker can measure time to guess the correct HMAC byte by byte.
    # compare_digest always takes the same time (constant-time comparison).
    received_mac = mac
    is_valid = hmac.compare_digest(
        hmac.new(secret_key, message, hashlib.sha256).hexdigest(),
        received_mac
    )
    print(f"  Valid:   {is_valid}")

    # Tampered message
    tampered = b"user_id=42&amount=999"
    tampered_mac = hmac.new(secret_key, tampered, hashlib.sha256).hexdigest()
    matches_original = hmac.compare_digest(mac, tampered_mac)
    print(f"\n  Tampered message: {tampered.decode()}")
    print(f"  HMAC matches original: {matches_original} ← CAUGHT!\n")


# =============================================================================
# PART 3: ENCODING (NOT encryption!)
# =============================================================================
def demo_encoding():
    section("ENCODING — Format conversion (NOT security!)")

    # Q: Common mistake: "I encrypted it with Base64!"
    # Base64 is NOT encryption. Anyone can decode it. It's just format conversion.
    # Used for: binary data in JSON/URLs, email attachments, data URIs.

    original = "MyBookShelf:password123"

    # Base64
    b64 = base64.b64encode(original.encode()).decode()
    decoded = base64.b64decode(b64).decode()
    print(f"  Original:   {original}")
    print(f"  Base64:     {b64}")
    print(f"  Decoded:    {decoded}")
    print(f"  → Anyone can decode this! NOT encryption!\n")

    # Hex encoding
    hex_encoded = original.encode().hex()
    hex_decoded = bytes.fromhex(hex_encoded).decode()
    print(f"  Hex:        {hex_encoded}")
    print(f"  Decoded:    {hex_decoded}\n")

    # JWT structure (from Layer 3)
    print("  --- JWT is just Base64-encoded JSON ---")
    header = {"alg": "HS256", "typ": "JWT"}
    payload = {"user_id": 42, "role": "admin", "exp": int(time.time()) + 3600}

    header_b64 = base64.urlsafe_b64encode(json.dumps(header).encode()).rstrip(b"=").decode()
    payload_b64 = base64.urlsafe_b64encode(json.dumps(payload).encode()).rstrip(b"=").decode()
    print(f"  Header (JSON):  {json.dumps(header)}")
    print(f"  Header (B64):   {header_b64}")
    print(f"  Payload (JSON): {json.dumps(payload)}")
    print(f"  Payload (B64):  {payload_b64}")
    print(f"  → The payload is NOT encrypted! Anyone can decode it!")
    print(f"  → The SIGNATURE (HMAC) prevents tampering, not reading.\n")


# =============================================================================
# PART 4: SYMMETRIC ENCRYPTION (AES)
# =============================================================================
def demo_symmetric():
    section("SYMMETRIC ENCRYPTION — Same key encrypts & decrypts (AES)")

    # Q: AES = Advanced Encryption Standard. Used everywhere:
    # HTTPS, disk encryption, password managers, WhatsApp, Signal.
    # Key sizes: 128, 192, or 256 bits. We use 256 (strongest).

    # We'll use a simple XOR cipher to demonstrate the CONCEPT.
    # (Real AES requires the cryptography library)

    print("  --- XOR Cipher (educational — NEVER use in production!) ---")
    print("  Shows the CONCEPT of symmetric encryption:\n")

    plaintext = "SECRET BOOK DATA"
    key = "MYKEY"  # In real AES: 32 random bytes

    # Encrypt with XOR
    encrypted = bytes([p ^ k for p, k in zip(
        plaintext.encode(),
        (key * (len(plaintext) // len(key) + 1)).encode()
    )])
    encrypted_hex = encrypted.hex()

    # Decrypt with same XOR (symmetric!)
    decrypted = bytes([e ^ k for e, k in zip(
        encrypted,
        (key * (len(encrypted) // len(key) + 1)).encode()
    )]).decode()

    print(f"  Plaintext:  {plaintext}")
    print(f"  Key:        {key}")
    print(f"  Encrypted:  {encrypted_hex} (unreadable)")
    print(f"  Decrypted:  {decrypted} (same key recovers original)")

    print(f"\n  --- Real AES-256 would look like: ---")
    print(f"  from cryptography.fernet import Fernet")
    print(f"  key = Fernet.generate_key()       # 256-bit random key")
    print(f"  f = Fernet(key)")
    print(f"  encrypted = f.encrypt(b'secret')  # AES-CBC + HMAC")
    print(f"  decrypted = f.decrypt(encrypted)  # Need same key!")

    # Key generation
    print(f"\n  --- Secure Random Key Generation ---")
    random_key = os.urandom(32)  # 256 bits of cryptographic randomness
    print(f"  os.urandom(32): {random_key.hex()}")
    print(f"  Length: {len(random_key)} bytes = {len(random_key)*8} bits")
    print(f"  → NEVER use 'password' as a key. Use os.urandom() or KDF.\n")


# =============================================================================
# PART 5: ASYMMETRIC ENCRYPTION (RSA concept)
# =============================================================================
def demo_asymmetric():
    section("ASYMMETRIC ENCRYPTION — Public/Private key pairs (RSA concept)")

    # Q: The key insight of asymmetric crypto:
    # Public key: give to EVERYONE. Used to ENCRYPT messages to you.
    # Private key: keep SECRET. Used to DECRYPT messages meant for you.
    # Analogy: public key = open padlock. private key = the only key that opens it.

    print("""
  How HTTPS works (simplified):

  1. Browser connects to https://mybookshelf.com
  2. Server sends its PUBLIC KEY (in the TLS certificate)
  3. Browser generates a random symmetric key (for AES)
  4. Browser ENCRYPTS the symmetric key with server's PUBLIC KEY
  5. Server DECRYPTS with its PRIVATE KEY → now both have the symmetric key
  6. All further communication uses fast AES encryption

  Q: Why not use RSA for everything?
  RSA is SLOW (100-1000x slower than AES).
  Solution: use RSA once to exchange an AES key, then use AES for data.
  This is called "hybrid encryption."

  --- Digital Signatures (the reverse) ---

  Signing: hash(message) → encrypt hash with PRIVATE key = signature
  Verify:  decrypt signature with PUBLIC key → compare with hash(message)

  If they match: (a) message is from the private key owner
                 (b) message wasn't modified in transit

  Used in: git commits (GPG), code signing, TLS certificates, JWT (RS256)
    """)

    # Demonstrate with a simple (insecure) example
    print("  --- Simplified RSA Math (educational) ---")
    # Real RSA uses 2048-bit primes. This uses tiny numbers to show the math.
    p, q = 61, 53  # Two primes
    n = p * q       # 3233 (public modulus)
    phi = (p-1) * (q-1)  # 3120 (Euler's totient)
    e = 17          # Public exponent (coprime to phi)

    # Find d such that (d * e) % phi == 1
    d = pow(e, -1, phi)  # 2753 (private exponent)

    print(f"  p={p}, q={q} (two primes)")
    print(f"  n = p×q = {n} (public modulus)")
    print(f"  e = {e} (public exponent)")
    print(f"  d = {d} (private exponent — SECRET)")
    print(f"  Public key:  (n={n}, e={e})")
    print(f"  Private key: (n={n}, d={d})")

    message = 42  # Small number for demo
    encrypted = pow(message, e, n)    # m^e mod n
    decrypted = pow(encrypted, d, n)  # c^d mod n

    print(f"\n  Message:   {message}")
    print(f"  Encrypted: {encrypted} (encrypted with public key)")
    print(f"  Decrypted: {decrypted} (decrypted with private key)")
    print(f"\n  Q: Why is RSA secure? Because factoring n back into p×q")
    print(f"     is computationally infeasible for large numbers (2048+ bits).\n")


# =============================================================================
# PART 6: PASSWORD HASHING (bcrypt, argon2)
# =============================================================================
def demo_password_hashing():
    section("PASSWORD HASHING — Why SHA256 is WRONG for passwords")

    # Q: Why not just SHA256(password)?
    # 1. TOO FAST: GPU can compute 10 billion SHA256/second → brute-force trivial
    # 2. No salt: same password → same hash → rainbow table attacks
    # 3. No stretching: no way to make it slower as hardware gets faster

    password = "MySecretP@ss123"

    # SHA256 — WRONG for passwords (too fast)
    sha_hash = hashlib.sha256(password.encode()).hexdigest()
    print(f"  Password:    {password}")
    print(f"  SHA-256:     {sha_hash}")
    print(f"  ⚠ WRONG! GPU computes 10 BILLION SHA256/sec. Cracked instantly.\n")

    # === SALT: Random data added to password before hashing ===
    # Q: Why salt? Without it, all users with password "123456" have the SAME hash.
    # Attacker precomputes hashes for common passwords (rainbow table).
    # Salt makes each hash unique even for identical passwords.
    salt = os.urandom(16)
    salted_hash = hashlib.sha256(salt + password.encode()).hexdigest()
    print(f"  Salt:        {salt.hex()}")
    print(f"  Salted SHA:  {salted_hash}")
    print(f"  → Better! But still too fast. Need bcrypt/argon2.\n")

    # === BCRYPT (what we use in Layer 3) ===
    print("  --- bcrypt (correct approach) ---")
    print("  import bcrypt")
    print("  hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))")
    print("  # Intentionally SLOW: ~250ms per hash (rounds=12)")
    print("  # Includes: salt + cost factor + algorithm identifier")
    print("  # Output: $2b$12$salt.....hash..... (60 chars)")
    print()
    print("  --- Argon2 (state of the art, recommended for new systems) ---")
    print("  from argon2 import PasswordHasher")
    print("  ph = PasswordHasher(time_cost=3, memory_cost=65536, parallelism=4)")
    print("  # Uses CPU time + RAM → resistant to GPU/ASIC attacks")
    print("  # time_cost: iterations. memory_cost: KB of RAM required.")
    print("  # GPU has fast cores but LIMITED memory → Argon2 wins.\n")

    # Speed comparison
    print("  --- Speed comparison (why slow = good for passwords) ---")
    import time as t

    start = t.time()
    for _ in range(100000):
        hashlib.sha256(password.encode()).hexdigest()
    sha_time = t.time() - start

    print(f"  100,000 SHA-256 hashes: {sha_time:.3f}s ({100000/sha_time:.0f}/sec)")
    print(f"  → At this speed: 8-char password cracked in hours")
    print(f"  bcrypt (rounds=12): ~4 hashes/sec")
    print(f"  → At this speed: 8-char password takes centuries\n")


# =============================================================================
# MAIN
# =============================================================================
def main():
    print("\n" + "=" * 60)
    print("  CRYPTOGRAPHY PLAYGROUND")
    print("  Learn crypto by seeing it in action")
    print("=" * 60)

    demo_hashing()
    demo_hmac()
    demo_encoding()
    demo_symmetric()
    demo_asymmetric()
    demo_password_hashing()

    print("\n" + "=" * 60)
    print("  KEY TAKEAWAYS")
    print("=" * 60)
    print("""
  1. Encoding ≠ Encryption (Base64 is NOT security)
  2. Hashing = one-way, for integrity (SHA-256)
  3. HMAC = hashing with a key, for authentication
  4. Symmetric = same key both ways (AES, fast)
  5. Asymmetric = public/private keys (RSA, slow)
  6. Passwords → bcrypt/argon2 (intentionally slow)
  7. HTTPS = asymmetric to exchange key + symmetric for data
  8. NEVER roll your own crypto in production
    """)


if __name__ == "__main__":
    main()
