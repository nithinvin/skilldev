# 🪙 BRIEFING: The Forged Token

**Difficulty:** [SPECIALIST]
**Skills:** JWT deep-dive, HMAC, key brute-forcing, token manipulation
**Time estimate:** 60-90 minutes

---

## SITUATION

This is a step up from Cookie Monster. The server has patched the "none"
algorithm vulnerability. But the developer chose a WEAK signing key.

Your mission: brute-force the JWT secret, forge a valid admin token,
and access the classified endpoint.

## SETUP

```bash
cd "$(dirname "$0")"
python3 forge_server.py &
echo "Server running on http://localhost:7333"
```

## OBJECTIVES

1. **FLAG #1**: Get a valid token and decode its claims
2. **FLAG #2**: Brute-force the signing secret (it's a common word)
3. **FLAG #3**: Forge a token with admin privileges and access /vault

## DIFFERENCES FROM LEVEL 05

- Algorithm "none" is REJECTED (that bug is patched)
- The secret is NOT "secret" anymore (slightly harder)
- The secret IS in the wordlist.txt file from Level 07
- You need to write a brute-forcer!

## APPROACH

```python
# Pseudocode for JWT brute-forcing:
for word in wordlist:
    signature = HMAC_SHA256(header + "." + payload, word)
    if signature == token_signature:
        print(f"SECRET FOUND: {word}")
        break
```

## HINTS (use only after 30+ minutes stuck)

<details>
<summary>Hint 1</summary>
Get a token from /login. Split it into 3 parts (header.payload.signature).
You need to find what key produces THAT signature from THAT header.payload.
</details>

<details>
<summary>Hint 2</summary>
The key is in the Level 07 wordlist. Try each word as the HMAC key.
Compare the resulting signature to the real signature from your token.
</details>

<details>
<summary>Hint 3</summary>
Once you have the key, you can sign ANY payload.
Create: {"user":"admin","role":"admin"} and sign with the found key.
</details>

---

*Forge the token, access /vault, then check DEBRIEF.md*
