#!/bin/bash
# =============================================================================
# Layer 4, Exercise 3: LOOPS
# =============================================================================
# THEORY-IN-ACTION: Loops are how you automate repetitive work. Process every
# file in a directory, retry until something works, transform every line in
# a file. bash has for, while, and until — each for different situations.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 3: Loops — Repeat Until Done"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: for Loops
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: for LOOPS ────

    # Loop over a list:
    for fruit in apple banana cherry; do
        echo "I like $fruit"
    done

    # Loop over files (USE GLOBS, not ls):
    for file in /etc/*.conf; do
        echo "Config: $(basename "$file")"
    done | head -10

    # Loop over command output:
    for user in $(cut -d: -f1 /etc/passwd | head -5); do
        echo "User: $user"
    done

    # C-style for loop:
    for ((i=1; i<=5; i++)); do
        echo "Iteration $i"
    done

    # Loop over a range:
    for i in {1..10}; do
        echo -n "$i "
    done
    echo

    # Range with step:
    for i in {0..100..10}; do
        echo -n "$i "
    done
    echo

    # Loop over array:
    servers=("web01" "web02" "db01" "cache01")
    for server in "${servers[@]}"; do
        echo "Checking $server..."
    done

EXPERIMENT:
    # Process all .sh files, add execution permission:
    mkdir -p /tmp/loop_test
    touch /tmp/loop_test/{a,b,c}.sh
    for script in /tmp/loop_test/*.sh; do
        chmod +x "$script"
        echo "Made executable: $script"
    done
    ls -la /tmp/loop_test/
    rm -rf /tmp/loop_test

    # Generate filenames:
    for i in {01..12}; do
        echo "report_2025_${i}.csv"
    done

KEY INSIGHT: `for x in ITEMS` is the most common loop.
For files: use globs (*.txt), NOT $(ls *.txt).
For numbers: use {1..N} or C-style ((i=0; i<N; i++)).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: while Loops
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: while LOOPS ────

    # while with counter:
    count=1
    while [[ $count -le 5 ]]; do
        echo "Count: $count"
        ((count++))
    done

    # while with condition:
    while ! ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; do
        echo "Waiting for network..."
        sleep 2
    done
    echo "Network is up!"

    # Read file line by line (THE correct way):
    while IFS= read -r line; do
        echo "Line: $line"
    done < /etc/hostname

    # Read with multiple fields:
    while IFS=: read -r user _ uid gid _ home shell; do
        if [[ $uid -ge 1000 && $uid -lt 65000 ]]; then
            echo "Real user: $user (uid=$uid, shell=$shell)"
        fi
    done < /etc/passwd

    # Infinite loop (with break):
    counter=0
    while true; do
        ((counter++))
        echo "Loop $counter"
        [[ $counter -ge 3 ]] && break
    done

    # Read from command output:
    find /etc -maxdepth 1 -name "*.conf" 2>/dev/null | while read -r conf; do
        echo "$(wc -l < "$conf") lines in $(basename "$conf")"
    done | sort -rn | head -5

EXPERIMENT:
    # Retry pattern (useful for flaky operations):
    max_attempts=5
    attempt=1
    while [[ $attempt -le $max_attempts ]]; do
        echo "Attempt $attempt..."
        if (( RANDOM % 3 == 0 )); then  # Simulated random success
            echo "Success!"
            break
        fi
        ((attempt++))
        sleep 1
    done
    [[ $attempt -gt $max_attempts ]] && echo "Failed after $max_attempts attempts"

    # IMPORTANT: pipe + while creates subshell!
    count=0
    echo -e "a\nb\nc" | while read -r line; do
        ((count++))
    done
    echo "Count: $count"    # 0! (while was in subshell, count is lost)

    # Fix with process substitution:
    count=0
    while read -r line; do
        ((count++))
    done < <(echo -e "a\nb\nc")
    echo "Count: $count"    # 3! (no subshell)

KEY INSIGHT: `while read -r line` is the safe way to process text line by line.
IFS= prevents trimming, -r prevents backslash interpretation.
BEWARE: `cmd | while ...` runs while in a subshell (variables are lost).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Loop Control and Patterns
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: break, continue, AND PRACTICAL PATTERNS ────

    # break — exit the loop:
    for i in {1..100}; do
        [[ $i -eq 5 ]] && break
        echo "$i"
    done
    # Prints: 1 2 3 4

    # continue — skip to next iteration:
    for i in {1..10}; do
        [[ $((i % 2)) -eq 0 ]] && continue  # Skip even numbers
        echo "$i"
    done
    # Prints: 1 3 5 7 9

    # Nested loops with break N:
    for i in {1..3}; do
        for j in {1..3}; do
            [[ $j -eq 2 ]] && break 2  # Break out of BOTH loops
            echo "$i $j"
        done
    done
    # Only prints: 1 1

    # --- PRACTICAL PATTERNS ---

    # 1. Process files in batches:
    files=(/usr/bin/*)
    batch_size=10
    for ((i=0; i<${#files[@]}; i+=batch_size)); do
        echo "Batch starting at $i: ${files[@]:$i:$batch_size}" | wc -w
    done | head -5

    # 2. Countdown:
    for i in {5..1}; do
        echo -ne "\rStarting in $i..."
        sleep 1
    done
    echo -e "\rGo!          "

    # 3. Menu loop:
    while true; do
        echo "1) List files  2) Show date  3) Quit"
        read -p "Choice: " choice
        case "$choice" in
            1) ls ;;
            2) date ;;
            3) break ;;
            *) echo "Invalid" ;;
        esac
        echo
    done

EXPERIMENT:
    # 4. Parallel execution in loops:
    for i in {1..5}; do
        (echo "Job $i starting"; sleep $((RANDOM % 3 + 1)); echo "Job $i done") &
    done
    wait
    echo "All jobs finished"

    # 5. Progress indicator:
    total=20
    for ((i=1; i<=total; i++)); do
        pct=$((i * 100 / total))
        printf "\r[%-20s] %3d%%" "$(printf '#%.0s' $(seq 1 $((i))))" "$pct"
        sleep 0.1
    done
    echo

KEY INSIGHT: break exits loops, continue skips iterations.
For parallelism: use & in loop body + wait after.
For progress: use \r (carriage return) to overwrite the same line.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # Infinite loop without break:
       # while true; do echo "forever"; done
       # Ctrl+C to escape (SIGINT)

    2. # Loop over files that don't exist:
       for f in /nonexistent/*.txt; do
           echo "Found: $f"
       done
       # Prints: Found: /nonexistent/*.txt (glob didn't expand!)
       # Fix: shopt -s nullglob (empty result when no match)

    3. # Word splitting in for:
       for word in $(cat /etc/hostname); do
           echo "[$word]"
       done
       # If hostname has spaces, they become separate iterations!
       # Fix: while read, not for with command substitution

    4. # Variable scope in loops:
       for i in {1..5}; do x=$i; done
       echo "x after loop: $x"     # 5 — loop vars persist!
       # bash has no block scope. Variables set in loops are visible after.

    5. # Modifying array during iteration:
       arr=(1 2 3 4 5)
       for item in "${arr[@]}"; do
           arr+=($((item * 10)))    # Adding while iterating?
       done
       echo "${arr[@]}"             # Original + new items (but loop only saw original)

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can write any loop pattern."
echo "  Next: 04_functions.sh"
echo "═══════════════════════════════════════════════════════════════"
