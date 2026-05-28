# DEBRIEF: Cracking the Vault

## Solutions

### Flag 1: MD5 Crack
```python
import hashlib
password = "password"
assert hashlib.md5(password.encode()).hexdigest() == "5f4dcc3b5aa765d61d8327deb882cf99"
```
**Password:** `password`
**FLAG{md5_is_dead_never_use_it_for_passwords}**

### Flag 2: SHA-256 Crack
```python
password = "password123"
assert hashlib.sha256(password.encode()).hexdigest() == "ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f"
```
**Password:** `password123`
**FLAG{dictionary_attacks_defeat_weak_passwords}**

### Flag 3: Salted Hash Lesson
The salted hash uses the SAME password (`password123`) but with salt `pepper2024` prepended:
```python
salted = "pepper2024" + "password123"
hashlib.sha256(salted.encode()).hexdigest()
# Produces a COMPLETELY different hash than unsalted
```
**FLAG{salts_prevent_rainbow_tables_but_not_targeted_attacks}**

### Complete Cracker Implementation
```python
def crack_md5(target_hash, wordlist):
    for word in wordlist:
        if hashlib.md5(word.encode()).hexdigest() == target_hash:
            return word
    return None

def crack_sha256(target_hash, wordlist):
    for word in wordlist:
        if hashlib.sha256(word.encode()).hexdigest() == target_hash:
            return word
    return None

def crack_sha256_salted(target_hash, salt, wordlist):
    for word in wordlist:
        salted = salt + word
        if hashlib.sha256(salted.encode()).hexdigest() == target_hash:
            return word
    return None
```

## Mental Model

```
PASSWORD STORAGE EVOLUTION:

TERRIBLE (never use):
├── Plaintext           — "password123" stored directly
├── MD5                 — fast, broken, rainbow tables exist for ALL common passwords
└── SHA-1/SHA-256 alone — fast hash, vulnerable to dictionary/brute-force attacks

WHY FAST HASHES ARE BAD FOR PASSWORDS:
  MD5:    ~10 BILLION hashes/sec on GPU
  SHA-256: ~1 BILLION hashes/sec on GPU
  At 1B/sec: all 8-char passwords cracked in HOURS

SALTING (better, but not enough alone):
├── salt = random bytes unique per user
├── hash = SHA256(salt + password)
├── WHY: same password → different hash for each user
├── KILLS: rainbow tables (precomputed hash → password maps)
└── DOESN'T HELP: if attacker targets ONE user and has the salt

PROPER PASSWORD HASHING (use these):
├── bcrypt   — intentionally slow (~100ms per hash), adaptive cost
├── argon2   — winner of Password Hashing Competition (2015), best option
├── scrypt   — memory-hard (expensive for GPUs)
└── PBKDF2   — acceptable if others unavailable (used by Django)

WHY SLOWNESS = SECURITY:
  bcrypt at cost=12: ~3 hashes/sec per CPU
  vs MD5: 10,000,000,000 hashes/sec per GPU
  
  Brute-forcing 8-char password:
    MD5:    hours
    bcrypt: CENTURIES

THE DEFENSE STACK:
1. Argon2/bcrypt (slow hash)         — makes cracking expensive
2. Per-user random salt              — prevents batch attacks
3. Strong password policy            — increases search space
4. Rate limiting + lockout           — blocks online attacks
5. Multi-factor authentication       — password alone isn't enough
```

## The Real Lesson

**It's not about the hash algorithm — it's about the TIME COST.**

A "secure" hash (SHA-256) is actually WORSE for passwords than a "slower" one (bcrypt)
because the goal isn't to be unbreakable — it's to be SLOW ENOUGH that trying
billions of guesses becomes economically infeasible.

## Skills Unlocked
- hashlib module (md5, sha256, sha1)
- Dictionary attack implementation
- Understanding salts and their purpose
- Hash identification by length/format
- Why bcrypt/argon2 > SHA-256 for passwords
- Rainbow tables and why salts defeat them
