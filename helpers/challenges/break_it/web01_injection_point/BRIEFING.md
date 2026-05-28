# 💥 BREAK-IT: Injection Point

**Difficulty:** [OPERATIVE]
**Type:** Break-It (Valorant-style — find the weak point, exploit it)
**Skills:** SQL injection basics, input validation, database queries
**Time estimate:** 45-60 minutes

---

## SITUATION

A login form is backed by a SQLite database. The developer concatenates
user input directly into SQL queries without sanitization.

Your mission: bypass the login without knowing the password.

## SETUP

```bash
cd "$(dirname "$0")"
python3 vuln_login.py &
echo "Server running on http://localhost:7334"
```

## OBJECTIVES

1. **FLAG #1**: Login as "admin" without knowing the password
2. **FLAG #2**: Extract the full user table (dump all usernames + passwords)
3. **FLAG #3**: Find a way to read a file from the server filesystem

## THE TARGET

```bash
# Normal login attempt:
curl -X POST http://localhost:7334/login \
  -d "username=admin&password=wrongpassword"
# Returns: Login failed

# Your job: craft input that breaks the SQL query logic
```

## WHAT IS SQL INJECTION?

The server does something like:
```sql
SELECT * FROM users WHERE username='INPUT' AND password='INPUT'
```

If you can make the SQL do something DIFFERENT than intended...
What happens if your input contains a single quote (`'`)?

## PROGRESSIVE HINTS

<details>
<summary>Hint 1: The single quote</summary>
Try username: admin'
What error do you get? That error confirms injection is possible.
</details>

<details>
<summary>Hint 2: Boolean logic</summary>
SQL has OR. What if you make the WHERE clause always true?
username: admin' OR '1'='1' --
The -- comments out the rest of the query!
</details>

<details>
<summary>Hint 3: UNION attack</summary>
UNION combines result sets. You can query OTHER tables:
' UNION SELECT sql FROM sqlite_master --
This dumps the schema!
</details>

---

*Break it, then check DEBRIEF.md to understand the defense.*
