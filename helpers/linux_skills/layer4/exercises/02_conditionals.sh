#!/bin/bash
# =============================================================================
# Layer 4, Exercise 2: CONDITIONALS
# =============================================================================
# THEORY-IN-ACTION: Every script needs to make decisions. bash has multiple
# ways to test conditions — if/then, [[ ]], case. Understanding the difference
# between [ ] and [[ ]] will save you from painful debugging.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 2: Conditionals — Making Decisions in Scripts"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: if/then/else
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: BASIC if STATEMENTS ────

    # Simple if:
    if [[ -f /etc/passwd ]]; then
        echo "/etc/passwd exists"
    fi

    # if/else:
    if [[ -d /nonexistent ]]; then
        echo "Found it"
    else
        echo "Not found"
    fi

    # if/elif/else:
    hour=$(date +%H)
    if [[ $hour -lt 12 ]]; then
        echo "Good morning"
    elif [[ $hour -lt 17 ]]; then
        echo "Good afternoon"
    else
        echo "Good evening"
    fi

    # The secret: `if` just checks the EXIT CODE of a command!
    # Exit 0 = true, non-zero = false
    if grep -q "root" /etc/passwd; then
        echo "root user exists"
    fi

    if ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
        echo "Internet is up"
    else
        echo "No internet"
    fi

EXPERIMENT:
    # if with commands (no [ or [[ needed):
    if mkdir /tmp/test_dir 2>/dev/null; then
        echo "Created directory"
        rmdir /tmp/test_dir
    else
        echo "Already exists or permission denied"
    fi

    # Negation with !:
    if ! [[ -f /nonexistent ]]; then
        echo "File does not exist"
    fi

KEY INSIGHT: `if` doesn't evaluate expressions — it runs COMMANDS and checks
exit codes. [[ ]] is a command that evaluates expressions and returns 0/1.
`grep -q` is a command that returns 0 if pattern found.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: [[ ]] Test Expressions
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: [[ ]] — THE RIGHT WAY TO TEST ────

    # Always use [[ ]] over [ ] in bash. It's safer and more powerful.

    # STRING TESTS:
    name="Nithin"
    [[ -z "$name" ]] && echo "empty" || echo "not empty"     # -z = zero length
    [[ -n "$name" ]] && echo "has content" || echo "empty"   # -n = non-zero length
    [[ "$name" == "Nithin" ]] && echo "match"                # Equality
    [[ "$name" != "Bob" ]] && echo "not Bob"                 # Inequality
    [[ "$name" == N* ]] && echo "starts with N"              # Pattern matching!
    [[ "$name" =~ ^[A-Z] ]] && echo "starts with uppercase" # Regex!

    # NUMBER TESTS:
    x=10
    [[ $x -eq 10 ]] && echo "equals 10"        # -eq (equal)
    [[ $x -ne 5 ]] && echo "not 5"             # -ne (not equal)
    [[ $x -gt 5 ]] && echo "greater than 5"    # -gt (greater than)
    [[ $x -lt 20 ]] && echo "less than 20"     # -lt (less than)
    [[ $x -ge 10 ]] && echo "10 or more"       # -ge (greater or equal)
    [[ $x -le 10 ]] && echo "10 or less"       # -le (less or equal)

    # Or use (( )) for arithmetic comparisons (cleaner):
    (( x > 5 )) && echo "greater than 5"
    (( x == 10 )) && echo "equals 10"
    (( x >= 5 && x <= 15 )) && echo "between 5 and 15"

    # FILE TESTS:
    [[ -f /etc/passwd ]] && echo "is a regular file"
    [[ -d /etc ]] && echo "is a directory"
    [[ -e /tmp ]] && echo "exists (any type)"
    [[ -r /etc/passwd ]] && echo "is readable"
    [[ -w /tmp ]] && echo "is writable"
    [[ -x /usr/bin/ls ]] && echo "is executable"
    [[ -s /etc/passwd ]] && echo "is non-empty"
    [[ -L /usr/bin/python3 ]] && echo "is a symlink"
    [[ /etc/passwd -nt /etc/hostname ]] && echo "passwd is newer"

    # LOGICAL OPERATORS (inside [[ ]]):
    [[ -f /etc/passwd && -r /etc/passwd ]] && echo "exists and readable"
    [[ -f /foo || -f /etc/passwd ]] && echo "at least one exists"

EXPERIMENT:
    # Why [[ ]] is better than [ ]:
    empty=""
    # [ $empty == "hello" ]    # ERROR: too many arguments (word splitting!)
    [[ $empty == "hello" ]]    # Works fine (no word splitting in [[ ]])

    # Pattern matching (only in [[ ]]):
    file="image.png"
    [[ $file == *.png ]] && echo "PNG file!"
    # [ $file == *.png ]       # Does NOT do pattern matching!

    # Regex (only in [[ ]]):
    email="user@example.com"
    [[ $email =~ ^[a-zA-Z]+@[a-zA-Z]+\.[a-z]+$ ]] && echo "valid email"

KEY INSIGHT: [[ ]] is a bash keyword (not a command) — it's parsed specially.
Benefits over [ ]: no word splitting, pattern matching (==), regex (=~),
&& and || work inside. ALWAYS use [[ ]] in bash scripts.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: case Statements
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: case — PATTERN MATCHING SWITCH ────

    # case is like switch/case in C, but with glob patterns:

    # Simple:
    fruit="apple"
    case "$fruit" in
        apple)
            echo "Red fruit"
            ;;
        banana)
            echo "Yellow fruit"
            ;;
        *)
            echo "Unknown fruit: $fruit"
            ;;
    esac

    # With patterns:
    filename="photo.jpg"
    case "$filename" in
        *.jpg|*.jpeg|*.png|*.gif)
            echo "Image file"
            ;;
        *.mp4|*.avi|*.mkv)
            echo "Video file"
            ;;
        *.py|*.js|*.sh)
            echo "Script file"
            ;;
        *)
            echo "Other: $filename"
            ;;
    esac

    # Practical: command-line option parsing
    cat > /tmp/myscript.sh << 'SCRIPT'
#!/bin/bash
case "$1" in
    start)
        echo "Starting service..."
        ;;
    stop)
        echo "Stopping service..."
        ;;
    restart)
        echo "Restarting..."
        ;;
    status)
        echo "Service is running"
        ;;
    -h|--help)
        echo "Usage: $0 {start|stop|restart|status}"
        ;;
    *)
        echo "Unknown option: $1"
        echo "Try: $0 --help"
        exit 1
        ;;
esac
SCRIPT
    chmod +x /tmp/myscript.sh
    /tmp/myscript.sh start
    /tmp/myscript.sh --help
    /tmp/myscript.sh blah

EXPERIMENT:
    # case with user input:
    read -p "Continue? [y/N] " answer
    case "$answer" in
        [yY]|[yY]es)
            echo "Proceeding..."
            ;;
        [nN]|[nN]o|"")
            echo "Aborted."
            ;;
        *)
            echo "Invalid input"
            ;;
    esac

KEY INSIGHT: case is cleaner than long if/elif chains when you're matching
one variable against multiple patterns. The patterns are globs (not regex).
;; ends each case. esac closes the block.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: Short-circuit Operators
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: && AND || — ONE-LINE CONDITIONALS ────

    # && = "and then" (run right side only if left succeeds)
    [[ -f /etc/passwd ]] && echo "File exists"
    mkdir -p /tmp/test && echo "Created" && touch /tmp/test/file && echo "Touched"

    # || = "or else" (run right side only if left FAILS)
    [[ -f /nonexistent ]] || echo "File missing!"
    cd /nonexistent 2>/dev/null || echo "Can't go there"

    # Common patterns:
    command || exit 1                   # Die if command fails
    command || { echo "Failed"; exit 1; }  # Die with message
    [[ -d "$dir" ]] || mkdir -p "$dir"  # Create if missing

    # Combine (but be careful!):
    [[ -f /etc/passwd ]] && echo "exists" || echo "missing"
    # This looks like if/else but ISN'T quite the same!
    # If the && command fails, || also runs!

    # Safe pattern:
    if [[ -f /etc/passwd ]]; then echo "exists"; else echo "missing"; fi
    # Use real if/else for anything non-trivial.

EXPERIMENT:
    # The && || trap:
    true && false || echo "Oops!"      # "Oops!" prints because `false` failed
    true && echo "yes" || echo "no"    # "yes" (echo succeeds, || skipped)
    true && (exit 1) || echo "no"      # "no" (subshell fails, || triggers)

    # Best practice: && || only for simple cases:
    # Good: [[ condition ]] && simple_action
    # Good: command || die "message"
    # Bad:  [[ condition ]] && complex_thing || other_complex_thing

KEY INSIGHT: && and || are sequential operators based on exit codes.
&& = "if previous succeeded, do this too"
|| = "if previous failed, do this instead"
For real branching, use if/then/else.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # [ ] vs [[ ]] with unquoted empty variable:
       empty=""
       [ $empty == "hello" ] 2>&1       # Error!
       [[ $empty == "hello" ]] 2>&1     # Fine (false, no error)

    2. # Arithmetic in [[ ]] — strings, not numbers!
       [[ "9" > "10" ]] && echo "9 > 10?!"     # True! (string comparison)
       [[ 9 -gt 10 ]] && echo "9 > 10" || echo "no"  # False (numeric)
       (( 9 > 10 )) && echo "yes" || echo "no"       # False (numeric)
       # > inside [[ ]] is STRING comparison. Use -gt for numbers!

    3. # Common mistake — single = vs ==:
       [[ "$name" = "test" ]]    # Works (= and == are the same in [[ ]])
       # But in [ ], only = works (== is not POSIX)

    4. # test command is just [ ]:
       test -f /etc/passwd && echo "exists"
       [ -f /etc/passwd ] && echo "exists"
       # They're the same! [ is a command called '[' that expects ] as last arg

    5. # Negation positions:
       ! [[ -f /etc/passwd ]] && echo "not found"    # Negate whole test
       [[ ! -f /etc/passwd ]] && echo "not found"    # Negate inside
       # Both work, but ! outside is more consistent

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can make decisions in scripts."
echo "  Next: 03_loops.sh"
echo "═══════════════════════════════════════════════════════════════"
