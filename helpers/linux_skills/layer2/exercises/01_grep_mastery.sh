#!/bin/bash
# =============================================================================
# Layer 2, Exercise 1: GREP MASTERY
# =============================================================================
# THEORY-IN-ACTION: grep = "Global Regular Expression Print"
# It searches text and prints lines matching a pattern. Simple idea,
# incredibly powerful tool. You'll use it every single day.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 1: grep — Find Anything in Any Text"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# First, create sample data to work with:
cat << 'INSTRUCTIONS'

──── SETUP: CREATE SAMPLE DATA ────

Run this to create files we'll search through:

    mkdir -p /tmp/grep_lab && cd /tmp/grep_lab

    # Sample log file:
    cat > access.log << 'EOF'
192.168.1.100 - - [15/Mar/2025:10:15:30] "GET /index.html HTTP/1.1" 200 4523
192.168.1.101 - - [15/Mar/2025:10:15:31] "GET /style.css HTTP/1.1" 200 1234
10.0.0.50 - - [15/Mar/2025:10:15:32] "POST /api/login HTTP/1.1" 401 89
192.168.1.100 - - [15/Mar/2025:10:15:33] "GET /images/logo.png HTTP/1.1" 200 15678
10.0.0.50 - - [15/Mar/2025:10:15:34] "POST /api/login HTTP/1.1" 200 445
192.168.1.102 - - [15/Mar/2025:10:16:01] "GET /about.html HTTP/1.1" 404 169
172.16.0.1 - - [15/Mar/2025:10:16:02] "DELETE /api/users/5 HTTP/1.1" 403 0
192.168.1.100 - - [15/Mar/2025:10:16:05] "GET /dashboard HTTP/1.1" 302 0
10.0.0.50 - - [15/Mar/2025:10:16:10] "POST /api/upload HTTP/1.1" 500 0
192.168.1.103 - - [15/Mar/2025:10:16:15] "GET / HTTP/1.1" 200 8901
EOF

    # Sample source code:
    cat > app.py << 'EOF'
#!/usr/bin/env python3
"""Simple web application."""
import os
import sys
from flask import Flask, request, jsonify

app = Flask(__name__)
DEBUG = os.environ.get("DEBUG", "false").lower() == "true"

# TODO: Add authentication
# FIXME: This is insecure
@app.route("/api/users", methods=["GET"])
def get_users():
    """Get all users from database."""
    return jsonify({"users": []})

@app.route("/api/users/<int:user_id>", methods=["DELETE"])
def delete_user(user_id):
    """Delete a user. Requires admin role."""
    # TODO: Check permissions
    return jsonify({"deleted": user_id})

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=DEBUG)
EOF

    echo "Sample files created in /tmp/grep_lab"

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 1: Basic Searching
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: BASIC GREP ────

    cd /tmp/grep_lab

    # Search for a string:
    grep "200" access.log               # Lines containing "200"
    grep "POST" access.log              # All POST requests
    grep "TODO" app.py                  # Find TODOs

    # Case-insensitive (-i):
    grep -i "get" access.log            # Matches GET, get, Get

    # Show line numbers (-n):
    grep -n "TODO" app.py               # Shows which line number

    # Count matches (-c):
    grep -c "200" access.log            # How many 200 responses?

    # Only filenames (-l):
    grep -l "import" *.py               # Which files have imports?

    # Invert match (-v): lines that DON'T match
    grep -v "200" access.log            # Non-200 responses (errors!)

    # Show context (-A after, -B before, -C both):
    grep -B2 -A2 "500" access.log      # 2 lines before and after the error

EXPERIMENT:
    # Combine flags:
    grep -inc "error\|fail\|500\|401\|403" access.log
    # -i case insensitive, -n line numbers, -c count

    # What's the difference between these?
    grep -c "200" access.log            # Count of LINES matching
    grep -o "200" access.log | wc -l    # Count of OCCURRENCES

KEY INSIGHT: grep's flags: -i (ignore case), -n (line numbers), -c (count),
-v (invert), -l (filenames only), -r (recursive). Memorize these 6.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Regular Expressions
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: REGEX PATTERNS ────

    cd /tmp/grep_lab

    # Basic regex:
    grep "^192" access.log              # Lines STARTING with 192
    grep "html$" access.log             # Lines ENDING with html (won't work here)
    grep "HTTP.*200" access.log         # HTTP followed by anything then 200
    grep "10\." access.log              # Literal dot (escaped)

    # Character classes:
    grep "[45]0[0-9]" access.log        # 4xx and 5xx status codes
    grep "^[0-9]" access.log            # Lines starting with a digit

    # Extended regex (-E or egrep):
    grep -E "401|403|404|500" access.log    # Any of these status codes
    grep -E "192\.168\.[0-9]+\.[0-9]+" access.log  # 192.168.x.x addresses
    grep -E "^.{50}" access.log         # Lines longer than 50 chars

    # Useful patterns:
    grep -E "\b[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\b" access.log  # IP addresses
    grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" access.log  # Extract just the IPs

    # Only print the match (-o):
    grep -oE '"[A-Z]+ [^ ]+"' access.log   # Extract request methods + URLs

EXPERIMENT:
    # Extract unique IP addresses:
    grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" access.log | sort -u

    # Find IPs with more than 2 requests:
    grep -oE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" access.log | sort | uniq -c | sort -rn

KEY INSIGHT: Regex basics: ^ (start), $ (end), . (any char), * (0+ of prev),
+ (1+ of prev), [] (char class), | (or), \b (word boundary).
Use -E for extended regex (no need to escape +, |, etc.)

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Recursive and Multi-File Search
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: SEARCHING ACROSS FILES ────

    # Recursive search (-r):
    grep -r "import" /usr/lib/python3/         # Search all Python files
    grep -rn "TODO" ~/                          # All TODOs in your home

    # Limit to file types (--include):
    grep -rn --include="*.py" "def " /usr/lib/python3/ | head -10
    grep -rn --include="*.conf" "port" /etc/ 2>/dev/null | head -10

    # Exclude patterns (--exclude, --exclude-dir):
    grep -rn --exclude-dir=".git" --exclude="*.pyc" "class" .

    # Real-world searches:
    grep -rn "password\|secret\|key" /etc/ 2>/dev/null | head -20
    # ^ Finding potentially exposed secrets (security audit!)

    grep -rn --include="*.py" "eval\|exec\|os.system" . 2>/dev/null
    # ^ Finding dangerous function calls

EXPERIMENT:
    # How grep -r differs from find + grep:
    time grep -r "import" /usr/lib/python3/ > /dev/null 2>&1
    time find /usr/lib/python3/ -name "*.py" -exec grep -l "import" {} \; > /dev/null 2>&1
    # grep -r is usually faster (single process, optimized)

    # ripgrep (rg) is even faster — install if available:
    # sudo apt install ripgrep
    # rg "import" /usr/lib/python3/     # 10x faster than grep -r

KEY INSIGHT: grep -r searches everything recursively. Use --include to
narrow by filename. In real projects, use ripgrep (rg) — it respects
.gitignore and is much faster.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: Practical grep Recipes
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: RECIPES YOU'LL USE WEEKLY ────

    cd /tmp/grep_lab

    # 1. Find failed login attempts:
    grep "401\|403" access.log

    # 2. Extract and count HTTP methods:
    grep -oE "(GET|POST|PUT|DELETE)" access.log | sort | uniq -c | sort -rn

    # 3. Find lines between two patterns (sed is better, but grep can do it):
    grep -A 100 "def get_users" app.py | grep -B 100 "^$" | head -10

    # 4. Show only lines that match ALL patterns (AND logic):
    grep "POST" access.log | grep "api"     # POST AND api

    # 5. Find empty lines:
    grep -n "^$" app.py

    # 6. Find lines that are NOT comments:
    grep -v "^\s*#" app.py | grep -v "^$"

    # 7. Binary file search:
    grep -rl "ELF" /usr/bin/ 2>/dev/null | head -5  # Find ELF binaries

    # 8. Count unique patterns:
    grep -ohE "HTTP/[0-9.]+" access.log | sort -u

    # 9. Show file:line:match (great for code search):
    grep -Hn "def " app.py              # filename:linenum:content

    # 10. Quiet mode (just check if match exists):
    grep -q "500" access.log && echo "Server errors found!" || echo "All clear"

EXPERIMENT:
    # Build a simple log analyzer:
    echo "=== Log Analysis ==="
    echo "Total requests: $(wc -l < access.log)"
    echo "Successful (2xx): $(grep -c '" 2[0-9][0-9] ' access.log)"
    echo "Redirects (3xx): $(grep -c '" 3[0-9][0-9] ' access.log)"
    echo "Client errors (4xx): $(grep -c '" 4[0-9][0-9] ' access.log)"
    echo "Server errors (5xx): $(grep -c '" 5[0-9][0-9] ' access.log)"
    echo "Top IPs:"
    grep -oE "^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" access.log | sort | uniq -c | sort -rn | head -3

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # grep vs fgrep (fixed string):
       grep "192.168" access.log        # . means ANY character in regex!
       grep -F "192.168" access.log     # -F treats pattern as literal string
       # When does this matter? Try: grep "file.txt" vs grep -F "file.txt"

    2. # Regex greediness:
       echo "aabab" | grep -oE "a.*b"    # Greedy: matches "aabab"
       echo "aabab" | grep -oP "a.*?b"   # Non-greedy: matches "aab" then "ab"
       # -P enables Perl regex (PCRE) — more powerful but not on all systems

    3. # Binary file gotcha:
       echo -e "hello\x00world" > /tmp/binary.txt
       grep "world" /tmp/binary.txt     # "Binary file matches" (won't show line)
       grep -a "world" /tmp/binary.txt  # -a treats as text

    4. # What does grep return when it doesn't match?
       grep "zzzzz" access.log
       echo $?                          # 1 (no match)
       grep "GET" access.log > /dev/null
       echo $?                          # 0 (match found)
       # This is useful in scripts: if grep -q "pattern" file; then ...

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: grep is now your go-to search tool."
echo "  Next: 02_sed_transform.sh"
echo "═══════════════════════════════════════════════════════════════"
