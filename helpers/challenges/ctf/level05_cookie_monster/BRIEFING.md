# 🍪 BRIEFING: Cookie Monster

**Difficulty:** [OPERATIVE]
**Skills:** Cookies, sessions, JWT tokens, browser dev tools, curl with cookies
**Time estimate:** 45-60 minutes

---

## SITUATION

A web app uses JWT tokens for authentication. The developer made critical
mistakes in their implementation. Your mission: escalate from a regular
user to admin by exploiting JWT weaknesses.

## SETUP

```bash
cd "$(dirname "$0")"
python3 cookie_server.py &
echo "Server running on http://localhost:7332"
```

## OBJECTIVES

1. **FLAG #1**: Login as "guest" (no password needed) and find what's in your token
2. **FLAG #2**: Modify the JWT to become admin (the signing is... flawed)
3. **FLAG #3**: Access the admin dashboard with your forged token

## INITIAL ACCESS

```bash
# Login as guest
curl http://localhost:7332/login?user=guest
# This gives you a JWT token. Decode it to see what's inside.
```

## INTEL ON JWT

A JWT has 3 parts separated by dots: `header.payload.signature`

Each part is Base64URL encoded. You can decode the first two without any key:
```bash
echo "<header_part>" | base64 -d
echo "<payload_part>" | base64 -d
```

The SIGNATURE is what prevents tampering... unless the algorithm is "none"
or the secret key is weak/guessable.

## HINTS (use only if stuck for 15+ minutes)

<details>
<summary>Hint 1: Decoding</summary>
Split the token at the dots. Base64-decode each part.
The header tells you the algorithm. The payload tells you your role.
</details>

<details>
<summary>Hint 2: The vulnerability</summary>
What if you change the algorithm in the header to "none"?
Or what if the secret key is literally "secret"?
</details>

<details>
<summary>Hint 3: Forging</summary>
Change "role":"guest" to "role":"admin" in the payload.
Re-encode. If using alg:none, remove the signature (keep the trailing dot).
</details>

---

*Forge your token, access /admin, then check DEBRIEF.md*
