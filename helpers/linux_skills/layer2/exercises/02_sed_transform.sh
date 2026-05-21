#!/bin/bash
# =============================================================================
# Layer 2, Exercise 2: SED — Stream Editor
# =============================================================================
# THEORY-IN-ACTION: sed reads text line by line, applies transformations,
# and outputs the result. It's your search-and-replace tool for the terminal.
# Think of it as "find and replace" on steroids.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 2: sed — Transform Text Without Opening an Editor"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── SETUP ────

    mkdir -p /tmp/sed_lab && cd /tmp/sed_lab

    # Create sample config file:
    cat > config.ini << 'EOF'
[server]
host = localhost
port = 8080
debug = true
workers = 4

[database]
host = localhost
port = 5432
name = myapp_dev
user = admin
password = changeme123

[logging]
level = DEBUG
file = /var/log/myapp.log
max_size = 10MB
EOF

    # Create sample CSV:
    cat > users.csv << 'EOF'
id,name,email,role
1,Alice Smith,alice@example.com,admin
2,Bob Jones,bob@company.org,user
3,Charlie Brown,charlie@example.com,user
4,Diana Prince,diana@hero.net,moderator
5,Eve Wilson,eve@example.com,admin
EOF

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 1: Basic Substitution
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: SEARCH AND REPLACE ────

    cd /tmp/sed_lab

    # Basic syntax: sed 's/pattern/replacement/' file
    sed 's/localhost/0.0.0.0/' config.ini        # Replace first occurrence per line
    sed 's/localhost/0.0.0.0/g' config.ini       # Replace ALL occurrences (global)

    # Note: original file is unchanged! sed outputs to stdout.
    cat config.ini              # Still says localhost

    # In-place editing (-i):
    cp config.ini config_backup.ini
    sed -i 's/debug = true/debug = false/' config.ini
    grep "debug" config.ini     # Changed!

    # In-place with backup (-i.bak):
    sed -i.bak 's/8080/9090/' config.ini
    ls config.ini*              # config.ini (new) and config.ini.bak (original)
    diff config.ini config.ini.bak

    # Case-insensitive replacement:
    echo "Hello HELLO hello" | sed 's/hello/hi/gi'

    # Different delimiters (useful when pattern contains /):
    echo "/usr/local/bin" | sed 's|/usr/local|/opt|'
    echo "/var/log/myapp.log" | sed 's#/var/log#/tmp#'

EXPERIMENT:
    # Replace only the 2nd occurrence on a line:
    echo "foo bar foo baz foo" | sed 's/foo/FOO/2'

    # Replace from the 2nd occurrence onwards:
    echo "foo bar foo baz foo" | sed 's/foo/FOO/2g'

KEY INSIGHT: s/pattern/replacement/flags is the core of sed.
Flags: g (global), i (case insensitive), number (nth match).
Default: only replaces FIRST match on each line.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Line Selection
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: ADDRESSING — WHICH LINES TO AFFECT ────

    cd /tmp/sed_lab

    # By line number:
    sed -n '3p' config.ini              # Print only line 3
    sed -n '1,5p' config.ini            # Print lines 1-5
    sed -n '5,$p' config.ini            # Line 5 to end

    # By pattern:
    sed -n '/database/p' config.ini         # Lines matching "database"
    sed -n '/\[database\]/,/\[/p' config.ini  # From [database] to next section

    # Delete lines:
    sed '/^$/d' config.ini              # Delete empty lines
    sed '/^#/d' config.ini              # Delete comment lines
    sed '1d' users.csv                  # Delete first line (header)
    sed '$d' users.csv                  # Delete last line

    # Replace only on matching lines:
    sed '/\[server\]/,/\[/ s/port = .*/port = 3000/' config.ini
    # Only change port within [server] section!

    # Negate with !:
    sed -n '/admin/!p' users.csv        # Print lines NOT containing admin

EXPERIMENT:
    # Extract just the database section:
    sed -n '/\[database\]/,/^$/p' config_backup.ini

    # Number all lines:
    sed = config_backup.ini | sed 'N;s/\n/\t/'

    # Delete lines 2 through 4:
    sed '2,4d' users.csv

KEY INSIGHT: Address tells sed WHICH lines to operate on.
Can be: line number, range (5,10), pattern (/regex/), or combo.
Without address, sed operates on ALL lines.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Advanced Transformations
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: BEYOND SIMPLE REPLACE ────

    cd /tmp/sed_lab

    # Insert and Append:
    sed '1i\# This is a header comment' config_backup.ini | head -5   # Insert BEFORE line 1
    sed '1a\# Added after first line' config_backup.ini | head -5     # Append AFTER line 1
    sed '/\[database\]/i\# Database Configuration' config_backup.ini | grep -A1 "Config"

    # Capture groups (back-references):
    echo "2025-03-15" | sed 's/\([0-9]*\)-\([0-9]*\)-\([0-9]*\)/\3\/\2\/\1/'
    # Converts YYYY-MM-DD to DD/MM/YYYY

    # Extended regex (-E makes it cleaner):
    echo "2025-03-15" | sed -E 's/([0-9]+)-([0-9]+)-([0-9]+)/\3\/\2\/\1/'

    # Transform CSV to a different format:
    sed -E 's/^([^,]+),([^,]+),([^,]+),(.+)/User \1: \2 (\3) - Role: \4/' users.csv

    # Multiple commands (-e or semicolons):
    sed -e 's/admin/ADMIN/g' -e 's/user/USER/g' users.csv
    # OR:
    sed 's/admin/ADMIN/g; s/user/USER/g' users.csv

    # Change case (GNU sed):
    echo "hello world" | sed 's/.*/\U&/'        # UPPERCASE
    echo "HELLO WORLD" | sed 's/.*/\L&/'        # lowercase
    echo "hello world" | sed 's/\b./\u&/g'      # Title Case

EXPERIMENT:
    # Wrap every email in <angle brackets>:
    sed -E 's/([a-zA-Z0-9.]+@[a-zA-Z0-9.]+)/<\1>/' users.csv

    # Add line numbers with padding:
    sed = users.csv | sed 'N;s/\n/: /'

    # Swap first and last name:
    echo "Smith, John" | sed -E 's/^([^,]+), (.+)/\2 \1/'

KEY INSIGHT: \1, \2, \3 = captured groups. Wrap the pattern part in \( \)
(basic) or ( ) with -E (extended). This is how you REARRANGE text, not
just replace it.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: Multi-line and Real-World Usage
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: PRACTICAL SED RECIPES ────

    cd /tmp/sed_lab

    # 1. Remove trailing whitespace:
    sed 's/[[:space:]]*$//' config_backup.ini

    # 2. Remove leading whitespace:
    sed 's/^[[:space:]]*//' config_backup.ini

    # 3. Squeeze multiple blank lines into one:
    sed '/^$/N;/^\n$/d' config_backup.ini

    # 4. Comment out a line:
    sed '/debug/s/^/# /' config_backup.ini

    # 5. Uncomment a line:
    echo "# debug = true" | sed 's/^#\s*//'

    # 6. Extract value from key=value:
    grep "port" config_backup.ini | sed 's/.*= //'

    # 7. Add text to end of specific lines:
    sed '/port/s/$/ # network port/' config_backup.ini

    # 8. Replace a whole block (between patterns):
    sed '/\[logging\]/,/^$/ {
        s/level = .*/level = INFO/
        s/max_size = .*/max_size = 100MB/
    }' config_backup.ini

    # 9. Convert Windows line endings to Unix:
    sed -i 's/\r$//' config_backup.ini    # Remove \r (carriage return)

    # 10. Replace the 3rd line entirely:
    sed '3 c\replacement text here' config_backup.ini | head -5

EXPERIMENT:
    # Build a template engine:
    cat > template.txt << 'EOF'
Hello {{NAME}},
Welcome to {{COMPANY}}!
Your role is: {{ROLE}}
EOF

    sed -e 's/{{NAME}}/Nithin/' \
        -e 's/{{COMPANY}}/MyStartup/' \
        -e 's/{{ROLE}}/Developer/' template.txt

KEY INSIGHT: sed is perfect for:
- Config file changes in automation scripts
- Quick text cleanup (whitespace, line endings)
- Template variable substitution
- Log file processing
Think of it as "automated vim search-and-replace."

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # Greedy matching problem:
       echo "<b>bold</b> and <i>italic</i>" | sed 's/<.*>/[TAG]/'
       # Expected: [TAG]bold[TAG] and [TAG]italic[TAG]
       # Got: [TAG] (matches from first < to LAST >!)
       # Fix: use non-greedy or be more specific:
       echo "<b>bold</b> and <i>italic</i>" | sed 's/<[^>]*>/[TAG]/g'

    2. # Sed with special characters:
       echo "price: $100" | sed 's/$100/$200/'     # Fails! $ means end-of-line
       echo "price: \$100" | sed 's/\$100/\$200/'  # Escape it

    3. # The & back-reference (means "the whole match"):
       echo "hello world" | sed 's/[a-z]*/(&)/g'
       # Wraps each word in parentheses

    4. # In-place editing pitfall:
       # sed -i 's/foo/bar/' *.txt
       # What if *.txt matches no files? → error
       # What if file is a symlink? → replaces symlink with regular file!

    5. # Order of multiple -e matters:
       echo "cat" | sed -e 's/cat/dog/' -e 's/dog/fish/'   # Result: fish
       echo "cat" | sed -e 's/dog/fish/' -e 's/cat/dog/'   # Result: dog

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: sed is now your text transformation tool."
echo "  Next: 03_awk_programming.sh"
echo "═══════════════════════════════════════════════════════════════"
