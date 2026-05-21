#!/bin/bash
# =============================================================================
# Layer 0, Exercise 5: PIPES — Connecting Commands
# =============================================================================
# THEORY-IN-ACTION: A pipe (|) connects stdout of one process to stdin of
# the next. That's it. That's the entire mechanism. But from this simple idea,
# you can build arbitrarily complex data processing pipelines.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 5: Pipes — The Unix Superpower"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: Basic Pipes
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: YOUR FIRST PIPELINES ────

    # One pipe: filter output
    ls /usr/bin | head -10              # First 10 programs
    ls /usr/bin | tail -10              # Last 10
    ls /usr/bin | wc -l                 # Count them
    ls /usr/bin | grep "zip"            # Only programs with "zip" in name

    # Two pipes: filter then count
    ls /usr/bin | grep "^g" | wc -l     # How many start with 'g'?
    ps aux | grep python | grep -v grep # Find python processes

    # Three pipes: the classic combo
    cat /etc/passwd | cut -d: -f1 | sort | head -10
    # Translation: get passwords file | extract field 1 | sort | first 10

EXPERIMENT:
    # How many unique shells are in use on this system?
    cat /etc/passwd | cut -d: -f7 | sort | uniq -c | sort -rn
    # cut extracts field 7 (shell), sort groups them, uniq -c counts, sort -rn ranks

    # Who's logged in and what are they running?
    w | tail -n +3          # Skip header lines

KEY INSIGHT: Each | creates a new process. The shell wires stdout→stdin
between them. They run IN PARALLEL (not sequentially!) — the second command
starts reading as soon as the first produces output.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Useful Pipe Patterns
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: PATTERNS YOU'LL USE DAILY ────

    # Pattern 1: Search in output
    dpkg --list | grep nginx            # Is nginx installed?
    history | grep "git"                # When did I use git?
    env | grep -i proxy                 # Any proxy settings?

    # Pattern 2: Sort and deduplicate
    echo -e "banana\napple\nbanana\ncherry\napple" | sort | uniq
    # sort | uniq is so common it's almost one command

    # Pattern 3: Count things
    find . -name "*.py" | wc -l         # How many Python files?
    ls -la | grep "^d" | wc -l          # How many directories?

    # Pattern 4: Transform and extract
    echo "Hello World" | tr '[:upper:]' '[:lower:]'   # To lowercase
    echo "hello:world:foo" | cut -d: -f2              # Extract field 2
    echo "  spaces  " | tr -d ' '                     # Remove spaces

    # Pattern 5: Top-N analysis
    du -sh /usr/lib/* 2>/dev/null | sort -rh | head -10  # Biggest dirs
    cat /var/log/syslog | awk '{print $5}' | sort | uniq -c | sort -rn | head
    # ^ Most common log sources

EXPERIMENT:
    # One-liner: find the 5 most common commands in your history:
    history | awk '{print $2}' | sort | uniq -c | sort -rn | head -5

    # One-liner: disk usage of your home, sorted:
    du -sh ~/* 2>/dev/null | sort -rh | head -10

KEY INSIGHT: Pipes let you decompose a complex question into simple steps:
"Get data | filter it | transform it | summarize it"

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: tee — Split the Stream
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: tee — SEE AND SAVE ────

The problem: You want to save output to a file AND see it on screen.
    ls /usr/bin > /tmp/commands.txt      # Saved, but you can't see it
    ls /usr/bin                          # See it, but not saved

Solution: tee
    ls /usr/bin | tee /tmp/commands.txt | head -5
    # Output goes to BOTH the file and the next command

    # tee with append:
    echo "logged at $(date)" | tee -a /tmp/log.txt

    # tee to multiple files:
    echo "broadcast" | tee /tmp/file1.txt /tmp/file2.txt /tmp/file3.txt

    # Debug a pipeline (see intermediate results):
    cat /etc/passwd | tee /tmp/debug1.txt | cut -d: -f1 | tee /tmp/debug2.txt | sort | head
    # Now you can check debug1 and debug2 to see what happened at each stage

EXPERIMENT:
    # Use tee to log command output while still piping it:
    find /usr -name "*.so" 2>/dev/null | tee /tmp/libs.txt | wc -l
    echo "Found $(wc -l < /tmp/libs.txt) shared libraries"

KEY INSIGHT: tee is named after a T-shaped pipe junction — input flows
both straight through AND out to a file (or multiple files).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: xargs — Convert Input to Arguments
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: xargs — BRIDGE BETWEEN PIPES AND ARGUMENTS ────

The problem: Some commands don't read from stdin. They need ARGUMENTS.
    # This WON'T work:
    echo "/tmp/hello.txt" | rm          # rm doesn't read stdin!

    # xargs converts stdin lines into arguments:
    echo "/tmp/hello.txt" | xargs rm    # Works! Becomes: rm /tmp/hello.txt

    # Real examples:
    find /tmp -name "*.txt" -mtime +30 | xargs rm -v     # Delete old .txt files
    grep -rl "TODO" . | xargs wc -l                       # Count lines in TODO files
    cat /tmp/urls.txt | xargs -I{} curl -s {}             # Download each URL

    # -I{} replaces {} with each input line:
    echo -e "one\ntwo\nthree" | xargs -I{} echo "Processing: {}"

    # -n1 runs command once per input:
    echo "a b c d" | xargs -n1 echo "Item:"

    # -P for parallel execution:
    seq 10 | xargs -P4 -I{} bash -c 'echo "Job {} started"; sleep 1; echo "Job {} done"'

EXPERIMENT:
    # Find and count lines in all Python files:
    find / -name "*.py" 2>/dev/null | head -20 | xargs wc -l | tail -1

    # Delete all files matching a pattern (CAREFUL):
    find /tmp -name "*.tmp" -print      # SEE what would be deleted first
    find /tmp -name "*.tmp" -print | xargs rm -v   # Then delete

KEY INSIGHT: Pipes pass DATA (text streams). Arguments are passed on the
command line. xargs is the bridge between these two worlds.
Always `find ... -print` first, then add `| xargs rm`.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 5: Putting It All Together
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 5: REAL CHALLENGES ────

Solve these using only pipes, redirections, and commands you've learned:

1. SYSTEM INVENTORY:
   How many executable files are in /usr/bin? How many are shell scripts?
   Hint: file /usr/bin/* | grep "shell script" | wc -l

2. LOG ANALYSIS:
   Find the 5 most common error types in system logs:
   journalctl --no-pager -p err | awk '{for(i=5;i<=NF;i++) printf "%s ", $i; print ""}' | sort | uniq -c | sort -rn | head -5

3. DISK DETECTIVE:
   Find the 10 largest files on your system:
   find / -type f -exec du -h {} \; 2>/dev/null | sort -rh | head -10
   # OR faster: find / -type f -size +100M -exec ls -lh {} \; 2>/dev/null

4. NETWORK SNAPSHOT:
   List all listening ports with their process names:
   ss -tlnp | tail -n +2 | awk '{print $4, $6}' | sort

5. PROCESS TREE:
   Show all processes as a tree, find the one using the most memory:
   ps aux --sort=-%mem | head -10

BONUS: THE LONGEST PIPELINE YOU CAN BUILD
   Try to solve a problem with 5+ pipes. Example:
   # Find duplicate files by size (simplified):
   find . -type f -exec du -b {} \; | sort -n | awk '{print $1}' | uniq -d | \
       while read size; do find . -type f -size ${size}c; done | sort

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # What happens when a command in the middle of a pipe fails?
       ls /nonexistent | sort | head
       echo "Exit: ${PIPESTATUS[@]}"    # PIPESTATUS shows ALL exit codes!

    2. # Broken pipe: what if the reader quits early?
       yes | head -5                    # `yes` produces infinite "y"s
       # head quits after 5 lines. What happens to `yes`? (SIGPIPE!)

    3. # Order matters:
       cat /etc/passwd | head -3 | wc -l    # = 3
       cat /etc/passwd | wc -l | head -3    # = total (just one line!)
       # Why different?

    4. # Pipe vs redirect confusion:
       echo "hello" | cat > /tmp/out.txt    # Works
       echo "hello" > cat                   # Creates a FILE called "cat"!
       rm cat                               # Clean up

    5. # Can you pipe stderr?
       ls /nonexistent | wc -l              # 0 — error goes to terminal, not pipe
       ls /nonexistent 2>&1 | wc -l         # 1 — NOW stderr goes through pipe
       ls /nonexistent |& wc -l             # Shorthand for above (bash 4+)

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can now combine commands into powerful pipelines."
echo "  Layer 0 complete! Run the checkpoint quiz before moving to Layer 1."
echo "═══════════════════════════════════════════════════════════════"
