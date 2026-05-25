#!/usr/bin/env python3
"""
=============================================================================
Layer 6.2 — Security Audit: OWASP Top 10 Applied to MyBookShelf
=============================================================================
PURPOSE: Walk through the OWASP Top 10 vulnerabilities with REAL examples
from our MyBookShelf application. Each vulnerability includes:
- What it is
- How an attacker exploits it
- Vulnerable code example (WRONG)
- Fixed code example (RIGHT)

QUESTIONS:
  1. What is OWASP?
     Open Web Application Security Project — a nonprofit that publishes
     the "Top 10" most critical web security risks (updated every ~3 years).

  2. Why should a B.Tech Year 1 student care about security?
     Because EVERY developer writes insecure code by default.
     Security isn't added later — it's built in from the start.
     Companies reject candidates who can't explain basic security.

RUN:
  python3 security_audit.py
=============================================================================
"""


def section(num, title):
    print(f"\n{'='*70}")
    print(f"  A{num:02d}: {title}")
    print(f"{'='*70}\n")


def demo_a01_broken_access_control():
    section(1, "BROKEN ACCESS CONTROL")
    print("""
  WHAT: Users can access/modify resources they shouldn't.
  IMPACT: User A reads User B's private data, or user becomes admin.

  ───── VULNERABLE CODE (WRONG) ─────
  @app.route("/api/users/<user_id>/books")
  def get_user_books(user_id):
      # No check! Any logged-in user can view ANY user's books
      books = db.query("SELECT * FROM books WHERE user_id = %s", (user_id,))
      return jsonify(books)

  ATTACK: Change user_id in URL: /api/users/42/books → /api/users/1/books
          Now I see the admin's private book collection!

  ───── FIXED CODE (RIGHT) ─────
  @app.route("/api/users/<user_id>/books")
  @require_auth
  def get_user_books(user_id, current_user):
      # Check: can this user access this resource?
      if current_user.id != int(user_id) and current_user.role != "admin":
          return jsonify({"error": "Forbidden"}), 403
      books = db.query("SELECT * FROM books WHERE user_id = %s", (user_id,))
      return jsonify(books)

  RULE: Always verify authorization, not just authentication.
        "Are you logged in?" ≠ "Are you allowed to do THIS?"
    """)


def demo_a02_cryptographic_failures():
    section(2, "CRYPTOGRAPHIC FAILURES")
    print("""
  WHAT: Sensitive data exposed due to weak/missing cryptography.
  IMPACT: Passwords leaked, credit cards stolen, tokens forged.

  ───── VULNERABLE CODE (WRONG) ─────
  # Storing passwords in plain text
  def register(username, password):
      db.execute("INSERT INTO users (name, password) VALUES (%s, %s)",
                 (username, password))  # ← PLAIN TEXT!

  # Using MD5 for passwords
  import hashlib
  hashed = hashlib.md5(password.encode()).hexdigest()  # ← CRACKABLE!

  # Transmitting secrets over HTTP (not HTTPS)
  requests.post("http://api.example.com/login", json={"password": "secret"})
  #              ^^^^^ plaintext! Anyone on the network can read this.

  ───── FIXED CODE (RIGHT) ─────
  import bcrypt

  def register(username, password):
      hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))
      db.execute("INSERT INTO users (name, password_hash) VALUES (%s, %s)",
                 (username, hashed.decode()))

  # Always HTTPS in production (Layer 5 nginx config handles this)
  # Never store secrets in code (use environment variables)

  RULES:
  - Passwords → bcrypt/argon2 (NEVER MD5/SHA/plaintext)
  - Data in transit → TLS (HTTPS)
  - Data at rest → AES-256 encryption
  - API keys → environment variables, never in git
    """)


def demo_a03_injection():
    section(3, "INJECTION (SQL, Command, Template)")
    print("""
  WHAT: Attacker inserts malicious code into your queries/commands.
  IMPACT: Read/modify/delete entire database. Execute system commands.

  ───── SQL INJECTION (WRONG) ─────
  def search_books(query):
      sql = f"SELECT * FROM books WHERE title LIKE '%{query}%'"
      #      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      #      User input directly in SQL string!
      db.execute(sql)

  ATTACK: query = "'; DROP TABLE books; --"
  RESULT: SELECT * FROM books WHERE title LIKE '%'; DROP TABLE books; --%'
          → Your entire books table is DELETED.

  ATTACK: query = "' OR '1'='1"
  RESULT: SELECT * FROM books WHERE title LIKE '%' OR '1'='1%'
          → Returns ALL books (bypasses any filter)

  ───── FIXED CODE (RIGHT) ─────
  def search_books(query):
      sql = "SELECT * FROM books WHERE title LIKE %s"
      db.execute(sql, (f"%{query}%",))  # Parameterized query!
      # The database driver handles escaping. No injection possible.

  ───── COMMAND INJECTION (WRONG) ─────
  import os
  def generate_pdf(filename):
      os.system(f"wkhtmltopdf {filename} output.pdf")

  ATTACK: filename = "page.html; rm -rf /"
  RESULT: wkhtmltopdf page.html; rm -rf / output.pdf
          → Server's entire filesystem DELETED.

  ───── FIXED (RIGHT) ─────
  import subprocess
  def generate_pdf(filename):
      # subprocess with list args — no shell interpretation
      subprocess.run(["wkhtmltopdf", filename, "output.pdf"], check=True)
      # Even if filename contains ";rm -rf", it's treated as a filename, not a command.

  RULE: NEVER concatenate user input into SQL/commands/templates.
        ALWAYS use parameterized queries / safe APIs.
    """)


def demo_a04_insecure_design():
    section(4, "INSECURE DESIGN")
    print("""
  WHAT: Fundamental design flaws that can't be fixed by better code.
  IMPACT: Business logic bypassed, rate limits ineffective.

  ───── VULNERABLE DESIGN ─────
  # Password reset: "What's your mother's maiden name?"
  # → Social media makes this public information. Easily guessable.

  # Rate limiting only on login endpoint:
  @app.route("/api/login", methods=["POST"])
  @rate_limit("5/minute")
  def login(): ...

  # But forgot to rate-limit the password reset!
  @app.route("/api/reset-password", methods=["POST"])
  def reset_password(): ...  # ← No rate limit! Attacker brute-forces tokens.

  ───── SECURE DESIGN ─────
  # Threat modeling BEFORE coding:
  # 1. What can go wrong? (STRIDE analysis)
  # 2. What's the worst case? (Risk assessment)
  # 3. How do we prevent it? (Controls)
  
  # Example: password reset done RIGHT
  # - Generate cryptographically random token (32 bytes)
  # - Token expires in 15 minutes
  # - Token is single-use (deleted after use)
  # - Rate limit: 3 reset requests per hour per email
  # - Don't reveal if email exists ("If account exists, email sent")

  RULE: Security starts at DESIGN phase, not after coding.
        Ask: "How would I attack this?" for every feature.
    """)


def demo_a05_security_misconfiguration():
    section(5, "SECURITY MISCONFIGURATION")
    print("""
  WHAT: Default configs, unnecessary features enabled, missing hardening.
  IMPACT: Debug info leaked, admin panels exposed, unnecessary ports open.

  ───── VULNERABLE (WRONG) ─────
  # Flask debug mode in production
  app.run(debug=True)  # ← Shows full stack traces + interactive debugger!
  # Attacker gets: file paths, source code, ability to execute arbitrary Python!

  # Default credentials
  POSTGRES_PASSWORD=postgres  # ← Every attacker tries this first

  # Unnecessary info in responses
  Server: nginx/1.24.0
  X-Powered-By: Flask/3.0.0
  # ← Tells attacker exact versions to look for CVEs

  # Exposed ports
  ports:
    - "5432:5432"  # PostgreSQL open to internet!
    - "6379:6379"  # Redis open to internet (no auth by default!)

  ───── FIXED (RIGHT) ─────
  # Production: debug=False, no stack traces
  app.run(debug=False)

  # Custom error handler (no internals leaked)
  @app.errorhandler(500)
  def internal_error(e):
      return jsonify({"error": "Internal server error"}), 500
      # No stack trace, no file paths, no version info

  # Strong passwords, ports internal only
  # Remove Server/X-Powered-By headers (nginx: server_tokens off;)

  RULE: Assume default configs are INSECURE. Harden everything.
        Principle of least privilege: disable what you don't need.
    """)


def demo_a06_vulnerable_components():
    section(6, "VULNERABLE & OUTDATED COMPONENTS")
    print("""
  WHAT: Using libraries with known security vulnerabilities.
  IMPACT: Attacker exploits a CVE in your dependency to hack your app.

  ───── EXAMPLE ─────
  # requirements.txt
  flask==2.0.0        # Has known CVE-2023-XXXXX (hypothetical)
  pyjwt==1.7.1        # Has algorithm confusion vulnerability
  requests==2.25.0    # Has SSRF vulnerability

  ───── HOW TO CHECK ─────
  # pip audit — checks for known vulnerabilities
  pip install pip-audit
  pip-audit

  # Output:
  # pyjwt 1.7.1  CVE-2022-29217  HIGH  Allows algorithm confusion attack
  # Fix: upgrade to pyjwt>=2.4.0

  # safety — another vulnerability scanner
  pip install safety
  safety check

  # GitHub Dependabot — automatic PR when vulnerabilities found
  # (configured in .github/dependabot.yml)

  ───── PREVENTION ─────
  # 1. Pin exact versions in requirements.txt
  # 2. Run pip-audit in CI/CD (Layer 4 pipeline)
  # 3. Enable GitHub Dependabot alerts
  # 4. Update dependencies monthly
  # 5. Subscribe to security advisories for your stack

  RULE: YOUR security is only as good as your WEAKEST dependency.
        One vulnerable library = entire app compromised.
    """)


def demo_a07_auth_failures():
    section(7, "IDENTIFICATION & AUTHENTICATION FAILURES")
    print("""
  WHAT: Weak authentication allows attackers to impersonate users.
  IMPACT: Account takeover, privilege escalation.

  ───── VULNERABLE (WRONG) ─────
  # No rate limiting on login
  @app.route("/login", methods=["POST"])
  def login():
      user = find_user(request.json["email"])
      if check_password(request.json["password"], user.password_hash):
          return create_token(user)
      return "Invalid", 401
  # ← Attacker tries 1 million passwords/minute (brute force)

  # Weak password policy
  if len(password) >= 4:  # ← "1234" is valid?!
      create_account(password)

  # Session doesn't expire
  token = create_jwt(user_id, exp=None)  # ← Token valid FOREVER

  ───── FIXED (RIGHT) ─────
  # Rate limiting (Layer 5 nginx: 3 attempts/minute for login)
  # Account lockout after 5 failed attempts (15-minute cooldown)
  # Strong password requirements:
  if len(password) < 8 or not any(c.isupper() for c in password):
      return "Password too weak", 400

  # Token expiration
  token = create_jwt(user_id, exp=timedelta(hours=1))  # Expires in 1 hour

  # Multi-factor authentication (MFA) for sensitive operations
  # Short-lived tokens + refresh token pattern

  RULE: Assume passwords will be stolen. Use MFA, rate limiting,
        token expiration, and account lockout.
    """)


def demo_a08_integrity_failures():
    section(8, "SOFTWARE & DATA INTEGRITY FAILURES")
    print("""
  WHAT: Code/data modified without verification.
  IMPACT: Supply chain attacks, CI/CD pipeline compromise.

  ───── EXAMPLE: Supply Chain Attack ─────
  # pip install colourfool   ← typosquat of "colorful"
  # The fake package steals environment variables on import!

  # Or: legitimate package maintainer account hacked
  # → malicious version published → you auto-update → compromised

  ───── PREVENTION ─────
  # 1. Pin EXACT versions (not >=)
  flask==3.0.0            # Exact version
  # NOT: flask>=3.0.0      # Could pull a compromised newer version

  # 2. Verify package hashes
  flask==3.0.0 --hash=sha256:abc123...
  # pip install --require-hashes -r requirements.txt

  # 3. Lock files (pip-tools, poetry.lock)
  pip-compile requirements.in → requirements.txt (with hashes)

  # 4. CI/CD pipeline security
  # - Don't use @latest for GitHub Actions (pin exact SHA)
  # - Review all dependency updates before merging
  # - Sign your commits (GPG) and verify in CI

  RULE: Verify integrity of everything: packages, images, data.
        Trust but verify → Actually, don't trust at all.
    """)


def demo_a09_logging_monitoring():
    section(9, "SECURITY LOGGING & MONITORING FAILURES")
    print("""
  WHAT: Attacks go undetected because of insufficient logging.
  IMPACT: Attacker has been in your system for MONTHS before discovery.
  Average time to detect a breach: 197 days (IBM 2023 report).

  ───── WHAT TO LOG ─────
  # Log these security events:
  - Failed login attempts (who, when, from where)
  - Access control failures (403s)
  - Input validation failures
  - Authentication events (login, logout, token refresh)
  - Admin actions (user creation, role changes, data deletion)
  - API errors (500s — could indicate attack probing)

  ───── HOW TO LOG (WRONG) ─────
  # DON'T log sensitive data!
  logger.info(f"Login attempt: user={email}, password={password}")  # ← NEVER!
  logger.info(f"Token: {jwt_token}")  # ← Attacker reads logs = game over

  ───── HOW TO LOG (RIGHT) ─────
  import logging
  logger = logging.getLogger("security")

  def login(email, password):
      user = find_user(email)
      if not user or not check_password(password, user.password_hash):
          logger.warning(
              "Failed login",
              extra={"email": email, "ip": request.remote_addr, "timestamp": time.time()}
          )
          # Alert if >5 failures from same IP in 1 minute
          return "Invalid credentials", 401

      logger.info("Successful login", extra={"user_id": user.id, "ip": request.remote_addr})
      return create_token(user)

  ───── ALERTING ─────
  # Set up alerts for:
  # - 10+ failed logins from same IP → possible brute force
  # - Login from new country → possible account compromise
  # - Admin action at unusual hours → possible insider threat
  # - Spike in 403/500 errors → possible automated attack

  RULE: If you can't detect an attack, you can't stop it.
        Log security events. Set up alerts. Review regularly.
    """)


def demo_a10_ssrf():
    section(10, "SERVER-SIDE REQUEST FORGERY (SSRF)")
    print("""
  WHAT: Attacker tricks your server into making requests to internal services.
  IMPACT: Access internal APIs, cloud metadata, databases.

  ───── VULNERABLE (WRONG) ─────
  @app.route("/api/fetch-cover")
  def fetch_book_cover():
      url = request.args.get("url")
      # Fetches ANY URL the user provides!
      response = requests.get(url)
      return response.content

  ATTACK: /api/fetch-cover?url=http://169.254.169.254/latest/meta-data/
  RESULT: Returns cloud instance metadata (AWS/GCP credentials!)

  ATTACK: /api/fetch-cover?url=http://localhost:6379/
  RESULT: Sends commands to your internal Redis!

  ATTACK: /api/fetch-cover?url=http://db:5432/
  RESULT: Probes internal services that should be unreachable from outside.

  ───── FIXED (RIGHT) ─────
  from urllib.parse import urlparse
  import ipaddress

  ALLOWED_HOSTS = {"covers.openlibrary.org", "images.bookcover.com"}

  @app.route("/api/fetch-cover")
  def fetch_book_cover():
      url = request.args.get("url")
      parsed = urlparse(url)

      # 1. Allowlist of domains
      if parsed.hostname not in ALLOWED_HOSTS:
          return "Domain not allowed", 403

      # 2. Block internal IPs
      try:
          ip = ipaddress.ip_address(parsed.hostname)
          if ip.is_private or ip.is_loopback:
              return "Internal addresses blocked", 403
      except ValueError:
          pass  # It's a hostname, not an IP — that's fine

      # 3. Only allow HTTPS
      if parsed.scheme != "https":
          return "Only HTTPS allowed", 403

      response = requests.get(url, timeout=5)
      return response.content

  RULE: Never let users control URLs your server fetches.
        Allowlist domains. Block internal IPs. Use HTTPS only.
    """)


def main():
    print("\n" + "=" * 70)
    print("  SECURITY AUDIT: OWASP TOP 10 for MyBookShelf")
    print("  Every vulnerability with attack examples & fixes")
    print("=" * 70)

    demo_a01_broken_access_control()
    demo_a02_cryptographic_failures()
    demo_a03_injection()
    demo_a04_insecure_design()
    demo_a05_security_misconfiguration()
    demo_a06_vulnerable_components()
    demo_a07_auth_failures()
    demo_a08_integrity_failures()
    demo_a09_logging_monitoring()
    demo_a10_ssrf()

    print("\n" + "=" * 70)
    print("  SUMMARY: Security Mindset")
    print("=" * 70)
    print("""
  1. Never trust user input (validate, sanitize, parameterize)
  2. Principle of least privilege (minimum access needed)
  3. Defense in depth (multiple layers of security)
  4. Fail securely (errors don't leak information)
  5. Keep it simple (complexity = bugs = vulnerabilities)
  6. Security by default (secure configs, not opt-in security)
  7. Fix the root cause (not just the symptom)

  ASK YOURSELF: "If I were an attacker, how would I abuse this?"
    """)


if __name__ == "__main__":
    main()
