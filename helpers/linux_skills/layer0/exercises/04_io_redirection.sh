#!/bin/bash
# =============================================================================
# Layer 0, Exercise 4: I/O REDIRECTION
# =============================================================================
# THEORY-IN-ACTION: Every process has 3 default streams:
#   stdin (fd 0)  — where it reads input from
#   stdout (fd 1) — where it writes normal output
#   stderr (fd 2) — where it writes error messages
# The SHELL can rewire these streams before launching a process. This is
# redirection — and it's one of the most powerful ideas in Unix.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 4: I/O Redirection — Rewiring Program Input/Output"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: stdout Redirection
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: REDIRECTING stdout ────

    # > means "send stdout to a file" (OVERWRITES the file)
    echo "Hello, World" > /tmp/hello.txt
    cat /tmp/hello.txt

    # >> means "APPEND to a file"
    echo "Line 1" > /tmp/lines.txt
    echo "Line 2" >> /tmp/lines.txt
    echo "Line 3" >> /tmp/lines.txt
    cat /tmp/lines.txt

    # What happens with > on an existing file?
    echo "I replaced everything" > /tmp/lines.txt
    cat /tmp/lines.txt          # Only one line now!

    # Redirect command output:
    ls /usr/bin > /tmp/all_commands.txt
    wc -l /tmp/all_commands.txt     # How many programs do you have?
    head -5 /tmp/all_commands.txt   # First 5 lines

EXPERIMENT:
    # What does > do to an existing file even WITHOUT a command?
    echo "important data" > /tmp/test.txt
    > /tmp/test.txt             # Just the redirect, no command!
    cat /tmp/test.txt           # Empty! > truncates the file.
    # This is actually useful: `> logfile.log` to clear a log.

KEY INSIGHT: > creates/overwrites the file BEFORE the command runs.
This is why `sort file.txt > file.txt` DESTROYS your data (file is emptied
before sort can read it). Use `sort file.txt > sorted.txt && mv sorted.txt file.txt`.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: stderr Redirection
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: STDERR — THE ERROR STREAM ────

    # Generate an error:
    ls /nonexistent             # Error goes to stderr (the terminal)
    ls /nonexistent > /tmp/output.txt   # stdout goes to file, BUT error still shows!
    cat /tmp/output.txt         # Empty — the error didn't go to the file

    # Redirect JUST stderr (fd 2):
    ls /nonexistent 2> /tmp/errors.txt
    cat /tmp/errors.txt         # The error is captured here

    # Redirect stdout AND stderr separately:
    ls /usr/bin /nonexistent > /tmp/output.txt 2> /tmp/errors.txt
    cat /tmp/output.txt         # The successful listing
    cat /tmp/errors.txt         # The error message

    # Redirect both to the SAME file:
    ls /usr/bin /nonexistent > /tmp/all.txt 2>&1
    cat /tmp/all.txt            # Both output and errors together

    # Shorthand for above (bash 4+):
    ls /usr/bin /nonexistent &> /tmp/all.txt

    # Discard errors completely:
    ls /nonexistent 2>/dev/null     # Silence! Errors go to the void.

EXPERIMENT:
    # Which programs write to stderr vs stdout?
    echo "This is stdout"
    echo "This is stderr" >&2       # >&2 sends to stderr

    # Prove they're different streams:
    (echo "stdout"; echo "stderr" >&2) > /tmp/out.txt
    # "stderr" still appears on screen! Only stdout went to file.
    cat /tmp/out.txt                # Just "stdout"

KEY INSIGHT: Programs write errors to stderr so you can separate them from
real output. `2>/dev/null` is "I don't care about errors" and is everywhere.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: stdin Redirection
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: STDIN — FEEDING INPUT ────

    # < means "read stdin from a file"
    # First, create a file:
    echo -e "banana\napple\ncherry" > /tmp/fruits.txt

    # sort normally reads from stdin (keyboard). Let's feed it a file:
    sort < /tmp/fruits.txt          # Sorted! (same as: sort /tmp/fruits.txt)

    # wc counts from stdin:
    wc -l < /tmp/fruits.txt         # 3 lines (no filename shown — just the count)
    wc -l /tmp/fruits.txt           # 3 /tmp/fruits.txt (shows filename)

    # Here-string (<<<): feed a single string as stdin:
    cat <<< "Hello from a here-string"
    wc -c <<< "Count my characters"

    # Here-document (<<): feed multiple lines:
    cat << EOF
    Line one
    Line two
    Line three
EOF

    # Useful for writing config files in scripts:
    cat << EOF > /tmp/config.txt
[settings]
name = Nithin
level = beginner
EOF
    cat /tmp/config.txt

EXPERIMENT:
    # Compare these — they do the same thing differently:
    echo "hello" | cat              # Pipe: echo's stdout → cat's stdin
    cat <<< "hello"                 # Here-string: string → cat's stdin
    cat < /tmp/hello.txt            # Redirect: file → cat's stdin

KEY INSIGHT: Input can come from keyboard, a file (<), a string (<<<),
a here-doc (<<), or a pipe (|). The program doesn't know the difference.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: /dev/null and /dev/zero
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: SPECIAL FILES ────

    # /dev/null — the black hole (accepts anything, returns nothing)
    echo "Gone forever" > /dev/null
    cat /dev/null               # Empty — nothing comes out

    # Common pattern: suppress output
    command_that_is_noisy > /dev/null 2>&1
    # Or: run something just for its exit code
    grep -q "root" /etc/passwd && echo "root exists"

    # /dev/zero — infinite stream of zero bytes
    head -c 1024 /dev/zero > /tmp/zeros.bin
    xxd /tmp/zeros.bin | head   # All zeros!

    # /dev/urandom — infinite stream of random bytes
    head -c 32 /dev/urandom | xxd   # Random data!
    head -c 16 /dev/urandom | base64  # Random base64 string (useful for tokens)

    # /dev/stdin, /dev/stdout, /dev/stderr — your own streams as files!
    echo "Hello" > /dev/stderr  # Same as: echo "Hello" >&2

EXPERIMENT:
    # Measure how fast your disk can read /dev/zero:
    dd if=/dev/zero of=/tmp/testfile bs=1M count=100 2>&1 | tail -1
    rm /tmp/testfile

KEY INSIGHT: /dev/null = discard, /dev/zero = zeros, /dev/urandom = random.
These "files" are actually kernel interfaces pretending to be files.
"Everything is a file" means you use the SAME operations (read/write)
to interact with very different things.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 5: Combining Redirections
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 5: ADVANCED COMBINATIONS ────

    # Send stdout to file, stderr to another file:
    find / -name "*.conf" > /tmp/found.txt 2> /tmp/errors.txt
    wc -l /tmp/found.txt /tmp/errors.txt

    # Send stdout to file AND see it on screen (tee):
    ls /usr/bin | tee /tmp/commands.txt | head -5
    wc -l /tmp/commands.txt     # Full list is in the file

    # Append with tee:
    echo "new entry" | tee -a /tmp/commands.txt

    # Swap stdout and stderr (advanced trick):
    # This sends stdout to stderr and stderr to stdout:
    (echo "out"; echo "err" >&2) 3>&1 1>&2 2>&3 3>&-
    # Now piping only catches the errors:
    (echo "out"; echo "err" >&2) 3>&1 1>&2 2>&3 3>&- | cat

    # Process substitution (treat command output as a file):
    diff <(ls /usr/bin) <(ls /usr/sbin)     # Compare two command outputs!

EXPERIMENT:
    # Real-world: log both stdout and stderr, with timestamps:
    (echo "Success at $(date)"; echo "Error at $(date)" >&2) 2>&1 | \
        while IFS= read -r line; do echo "[$(date +%H:%M:%S)] $line"; done

KEY INSIGHT: You can wire any file descriptor to any file, device, or
another file descriptor. It's just plumbing. Once you see it this way,
redirection stops being mysterious.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # What happens here? (DON'T run with important files)
       cat /tmp/fruits.txt > /tmp/fruits.txt
       cat /tmp/fruits.txt          # Empty! Why?
       # Because > truncates the file BEFORE cat reads it

    2. echo "test" > /dev/full      # What's /dev/full?
       echo $?                      # Non-zero! (simulates disk full)

    3. # Redirect in wrong order:
       ls /nonexistent 2>&1 > /tmp/out.txt
       # vs
       ls /nonexistent > /tmp/out.txt 2>&1
       # Which one captures the error? Why? (hint: order matters)

    4. # Can you redirect stdin from AND stdout to the same file?
       sort < /tmp/fruits.txt > /tmp/fruits.txt   # What happens?

    5. # File descriptor magic:
       exec 3> /tmp/fd3.txt        # Open fd 3 for writing
       echo "Hello fd 3" >&3       # Write to fd 3
       echo "More to fd 3" >&3
       exec 3>&-                   # Close fd 3
       cat /tmp/fd3.txt            # Both lines are there!

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You understand I/O streams, redirection, and special files."
echo "  Next: 05_first_pipes.sh"
echo "═══════════════════════════════════════════════════════════════"
