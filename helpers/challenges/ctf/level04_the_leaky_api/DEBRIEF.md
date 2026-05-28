# DEBRIEF: The Leaky API

## Solutions

### Flag 1: Hidden Debug Endpoint
```bash
curl http://localhost:7331/debug
# OR
curl http://localhost:7331/api/debug
```
**FLAG{always_check_debug_endpoints_in_production}**

**How to find it:** Enumerate common paths that developers forget to remove:
- `/debug`, `/api/debug`
- `/admin`, `/api/admin`
- `/health`, `/status`
- `/swagger`, `/api-docs`
- `/graphql` (often has introspection enabled)
- `/.env`, `/config`

### Flag 2: HTTP Methods
```bash
curl -X OPTIONS http://localhost:7331/api/users -v
# Look at the response HEADERS (not body)
# X-Hidden-Flag: FLAG{http_methods_matter_options_reveals_secrets}
```
**FLAG{http_methods_matter_options_reveals_secrets}**

**Key insight:** The `-v` flag in curl shows response headers.
The OPTIONS method asks "what can I do here?" — CORS preflight uses this.
Sometimes devs leak information in response headers.

### Flag 3: Weak Authentication
```bash
curl -H "Authorization: Bearer admin" http://localhost:7331/api/admin
# OR
curl -H "X-API-Key: admin" http://localhost:7331/api/admin
```
**FLAG{default_credentials_are_the_first_thing_attackers_try}**

**How to find it:** 
1. First discover the `/api/admin` endpoint (enumerate common paths)
2. It returns 401 with a hint about auth headers
3. Try common weak tokens: admin, password, token, test, 1234
4. The Bearer token "admin" works — lazy development!

## Mental Model

```
API Security Checklist (attacker perspective):

RECONNAISSANCE:
├── GET /                         — what does the root say?
├── Check response for clues      — version numbers, endpoint lists
├── Enumerate common paths        — /debug, /admin, /swagger, /graphql
├── Try all HTTP methods          — GET, POST, PUT, DELETE, PATCH, OPTIONS
└── Read response HEADERS         — X-Powered-By, Server, custom headers

HTTP METHODS:
├── GET     — retrieve data
├── POST    — create/submit data
├── PUT     — replace/update data
├── PATCH   — partial update
├── DELETE  — remove data
├── OPTIONS — "what's available here?" (CORS preflight)
├── HEAD    — GET but only headers (no body)
└── TRACE   — echo request back (often disabled)

AUTHENTICATION ATTACKS:
├── Default credentials (admin/admin, test/test)
├── Missing auth on some routes
├── Auth header variations:
│   ├── Authorization: Bearer <token>
│   ├── X-API-Key: <key>
│   ├── Cookie: session=<value>
│   └── Basic auth: Authorization: Basic <base64(user:pass)>
└── Token guessing (short tokens, predictable patterns)

curl ESSENTIAL FLAGS:
├── -v        — verbose (see headers)
├── -X METHOD — specify HTTP method
├── -H "K:V"  — add request header
├── -d "data" — send request body
├── -I        — HEAD request only
├── -L        — follow redirects
└── -k        — ignore SSL errors (testing only!)
```

## Real-World Impact
- Uber breach (2016): admin panel accessible without auth
- Facebook API: debug endpoints exposed user tokens
- Thousands of APIs expose /swagger or /api-docs with full route maps
- OWASP Top 10 #1: Broken Access Control

## Skills Unlocked
- `curl` with all essential flags
- HTTP method enumeration
- API path discovery/fuzzing
- Authentication header formats
- Reading response headers for information leakage
