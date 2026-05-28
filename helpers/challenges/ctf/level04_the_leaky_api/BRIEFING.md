# 🌐 BRIEFING: The Leaky API

**Difficulty:** [OPERATIVE]
**Skills:** HTTP methods, curl, headers, API enumeration, auth bypass
**Time estimate:** 45-60 minutes

---

## SITUATION

Intelligence has located a poorly secured REST API running on this machine.
The developer left debugging endpoints active and forgot to secure some routes.

Your mission: interact with the API, find the unprotected routes, and
extract the classified data.

## SETUP

```bash
# Start the vulnerable API server
cd "$(dirname "$0")"
python3 leaky_server.py &
echo "Server running on http://localhost:7331"
```

## OBJECTIVES

Find 3 flags hidden in the API:

1. **FLAG #1**: The API has a hidden endpoint that isn't documented.
   Think about common API paths developers leave behind.

2. **FLAG #2**: One endpoint responds differently based on the HTTP method.
   GET shows public data. What about other methods?

3. **FLAG #3**: An endpoint requires auth but accepts a well-known weak token.
   The developer was lazy about their "admin" authentication.

## RECONNAISSANCE HINTS

Start with:
```bash
curl http://localhost:7331/
curl -v http://localhost:7331/api/
```

Think about:
- What HTTP methods exist beyond GET? (POST, PUT, DELETE, OPTIONS, PATCH)
- What paths do developers commonly forget to disable? (/debug, /admin, /status, /health, /swagger)
- How do APIs communicate auth? (Headers: Authorization, X-API-Key, Cookie)
- What does the OPTIONS method tell you?

## TOOLS

```bash
curl -X GET http://...          # GET request
curl -X POST http://...         # POST request
curl -X OPTIONS http://...      # Ask what methods are allowed
curl -H "Header: value" ...    # Send custom header
curl -v http://...              # Verbose (see response headers)
curl -I http://...              # HEAD request (headers only)
```

---

*Find all 3 flags, then check DEBRIEF.md*
