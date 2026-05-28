# 🔐 BRIEFING: Cracking the Vault

**Difficulty:** [SPECIALIST]
**Skills:** Password hashing, hash identification, dictionary attacks, salts
**Time estimate:** 45-90 minutes

---

## SITUATION

We've obtained a leaked password database from a compromised server.
The passwords are hashed, but the hashing is weak. Your mission:
crack as many passwords as you can and extract the flags.

## OBJECTIVES

The file `leaked_hashes.txt` contains username:hash pairs.
Crack the passwords to find 3 flags hidden within.

1. **FLAG #1**: Crack the MD5 hash (it's a common password)
2. **FLAG #2**: Crack the SHA-256 hash (it's in a wordlist we provide)
3. **FLAG #3**: Figure out why one hash CAN'T be cracked the same way

## FILES

- `leaked_hashes.txt` — The stolen password database
- `wordlist.txt` — A small dictionary of common passwords
- `crack_it.py` — A starter script (fill in the logic!)

## APPROACH

1. Identify what hash algorithm each line uses (by length and format)
2. Write a script to hash each word in the wordlist
3. Compare against the target hashes
4. One hash uses a SALT — understand why that changes everything

## HASH IDENTIFICATION CHEAT SHEET

| Hash | Length | Example starts with |
|------|--------|-------------------|
| MD5 | 32 hex chars | varies |
| SHA-1 | 40 hex chars | varies |
| SHA-256 | 64 hex chars | varies |
| bcrypt | 60 chars | $2b$ or $2a$ |

## CONSTRAINTS

- Write your own cracking script (no online hash lookup sites)
- Use Python's `hashlib` module
- Understand WHY each hash was easy/hard to crack

---

*Crack the hashes, then check DEBRIEF.md*
