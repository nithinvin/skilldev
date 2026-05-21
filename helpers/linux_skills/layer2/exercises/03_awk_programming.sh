#!/bin/bash
# =============================================================================
# Layer 2, Exercise 3: AWK — A Programming Language for Text
# =============================================================================
# THEORY-IN-ACTION: awk splits each line into fields and lets you write
# programs that process them. It's grep + sed + arithmetic + variables
# all in one tool. When pipes get too complex, switch to awk.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 3: awk — When Pipes Aren't Enough"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── SETUP ────

    mkdir -p /tmp/awk_lab && cd /tmp/awk_lab

    # Create a sample data file:
    cat > grades.txt << 'EOF'
Name        Subject     Score   Grade
Alice       Math        92      A
Alice       Physics     88      B+
Alice       CS          95      A+
Bob         Math        76      C+
Bob         Physics     82      B
Bob         CS          90      A
Charlie     Math        88      B+
Charlie     Physics     91      A
Charlie     CS          85      B
Diana       Math        95      A+
Diana       Physics     79      C+
Diana       CS          97      A+
EOF

    # Process-style data:
    cat > processes.txt << 'EOF'
USER       PID  %CPU %MEM    VSZ   RSS COMMAND
root         1   0.0  0.1 169324 11280 systemd
root         2   0.0  0.0      0     0 kthreadd
nithin    1234  15.2  3.5 2345678 567890 firefox
nithin    1235   8.7  1.2 1234567 234567 code
root      1500   0.3  0.5 345678  98765 dockerd
nithin    2000   2.1  0.8 456789 123456 python3
nithin    2001   0.0  0.0  12345   1234 bash
EOF

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 1: Fields and Printing
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: FIELDS — AWK SPLITS LINES AUTOMATICALLY ────

    cd /tmp/awk_lab

    # awk splits each line by whitespace. Fields are $1, $2, $3...
    # $0 = the whole line

    awk '{print $1}' grades.txt             # First field (names)
    awk '{print $1, $3}' grades.txt         # Name and score
    awk '{print $3, $1}' grades.txt         # Rearranged!
    awk '{print $0}' grades.txt             # Whole line (like cat)
    awk '{print NR, $0}' grades.txt         # Line numbers + content

    # Built-in variables:
    # $1, $2, ... $NF = fields
    # $0 = whole line
    # NF = Number of Fields on this line
    # NR = current line Number (Record number)
    # FS = Field Separator (default: whitespace)
    # OFS = Output Field Separator (default: space)

    awk '{print NF}' grades.txt             # How many fields per line?
    awk '{print $NF}' grades.txt            # LAST field on each line
    awk '{print $(NF-1)}' grades.txt        # Second-to-last field

    # Custom separator:
    echo "alice:x:1000:1000::/home/alice:/bin/bash" | awk -F: '{print $1, $6}'
    awk -F, '{print $2, $3}' /tmp/sed_lab/users.csv 2>/dev/null

EXPERIMENT:
    # Print fields in reverse order:
    echo "one two three four" | awk '{for(i=NF;i>=1;i--) printf "%s ", $i; print ""}'

    # Extract specific columns from ps output:
    ps aux | awk '{print $1, $2, $11}'      # user, pid, command

KEY INSIGHT: awk sees text as a TABLE. Each line is a row, each word is a column.
$1 through $NF access columns. This makes it perfect for columnar data.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Patterns and Conditions
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: PATTERN {ACTION} — ONLY PROCESS MATCHING LINES ────

    cd /tmp/awk_lab

    # Structure: awk 'pattern {action}' file
    # If pattern matches → run action. If no pattern → run on all lines.

    # Pattern matching:
    awk '/Alice/' grades.txt                # Lines containing "Alice"
    awk '/CS/' grades.txt                   # CS subject lines
    awk '!/Name/' grades.txt                # Skip header (not matching "Name")

    # Comparison operators:
    awk '$3 > 90' grades.txt                # Score > 90
    awk '$3 >= 90 {print $1, $3}' grades.txt  # Names with score >= 90
    awk '$1 == "Bob"' grades.txt            # Only Bob's records
    awk '$4 ~ /A/' grades.txt               # Grade contains "A"

    # Combining conditions:
    awk '$1 == "Alice" && $3 > 90' grades.txt       # Alice's high scores
    awk '$3 < 80 || $3 > 95' grades.txt             # Very low or very high
    awk 'NR > 1 && $3 > 90' grades.txt              # Skip header, score > 90

    # Line number conditions:
    awk 'NR == 1' grades.txt                # Just the header
    awk 'NR > 1' grades.txt                 # Skip header
    awk 'NR >= 3 && NR <= 5' grades.txt     # Lines 3-5

EXPERIMENT:
    # Find processes using more than 5% CPU:
    awk 'NR > 1 && $3 > 5.0 {print $7, $3"%"}' processes.txt

    # Find students who got A+ in any subject:
    awk '$4 == "A+" {print $1, "got A+ in", $2}' grades.txt

KEY INSIGHT: awk's pattern/action model: scan each line, if pattern matches,
execute the action. No pattern = all lines. No action = print whole line.
It's like a mini event-driven language.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Computation
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: ARITHMETIC AND VARIABLES ────

    cd /tmp/awk_lab

    # awk can do math:
    awk 'NR > 1 {print $1, $2, $3, $3*1.1}' grades.txt    # 10% bonus
    awk 'NR > 1 {total += $3} END {print "Sum:", total}' grades.txt
    awk 'NR > 1 {total += $3; count++} END {print "Average:", total/count}' grades.txt

    # BEGIN and END blocks:
    awk 'BEGIN {print "=== Report ==="} {print $0} END {print "=== End ==="}' grades.txt

    # Accumulating per-student average:
    awk 'NR > 1 {
        sum[$1] += $3
        count[$1]++
    }
    END {
        for (name in sum)
            printf "%s: %.1f\n", name, sum[name]/count[name]
    }' grades.txt

    # String concatenation:
    awk 'NR > 1 {full = $1 " (" $4 ")"; print full}' grades.txt

    # Formatted output with printf:
    awk 'NR > 1 {printf "%-10s %-10s %3d\n", $1, $2, $3}' grades.txt

    # Counting occurrences:
    awk 'NR > 1 {grades[$4]++} END {for (g in grades) print g, grades[g]}' grades.txt

EXPERIMENT:
    # Memory usage report:
    awk 'NR > 1 {
        total_mem += $4
        if ($4 > max_mem) {max_mem = $4; max_proc = $7}
    }
    END {
        printf "Total %%MEM: %.1f%%\n", total_mem
        printf "Heaviest: %s (%.1f%%)\n", max_proc, max_mem
    }' processes.txt

KEY INSIGHT: awk has variables (no declaration needed), arrays (associative!),
arithmetic, and printf formatting. BEGIN runs once before data, END runs once
after all data. This makes it a real programming language for data.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: Real-World awk
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: PRACTICAL RECIPES ────

    cd /tmp/awk_lab

    # 1. Sum a column of numbers:
    df -h | awk 'NR>1 {print $5}' | sed 's/%//' | awk '{sum+=$1} END {print sum/NR "%"}'

    # 2. Convert CSV to a formatted table:
    awk -F, 'NR==1 {for(i=1;i<=NF;i++) printf "%-15s", $i; print ""}
             NR>1  {for(i=1;i<=NF;i++) printf "%-15s", $i; print ""}' /tmp/sed_lab/users.csv 2>/dev/null

    # 3. Log file analysis — requests per minute:
    # (using our access.log from grep exercise)
    awk -F'[\\[\\]]' '{print $2}' /tmp/grep_lab/access.log 2>/dev/null | \
        awk -F: '{print $1":"$2":"$3}' | sort | uniq -c

    # 4. Find duplicate lines:
    awk 'seen[$0]++ == 1' grades.txt    # Print lines seen more than once

    # 5. Print lines between two patterns:
    awk '/\[database\]/,/^\[/' /tmp/sed_lab/config_backup.ini 2>/dev/null

    # 6. Transpose rows and columns:
    echo -e "1 2 3\n4 5 6\n7 8 9" | awk '{
        for(i=1; i<=NF; i++) a[NR][i]=$i
    }
    END {
        for(j=1; j<=NF; j++) {
            for(i=1; i<=NR; i++) printf "%s ", a[i][j]
            print ""
        }
    }'

    # 7. Running total:
    echo -e "10\n20\n30\n40\n50" | awk '{sum+=$1; print $1, sum}'

    # 8. Conditional column output:
    awk 'NR > 1 {
        if ($3 >= 90) status = "PASS*"
        else if ($3 >= 70) status = "PASS"
        else status = "FAIL"
        printf "%-10s %-10s %d %s\n", $1, $2, $3, status
    }' grades.txt

EXPERIMENT:
    # Build a grade report:
    awk 'BEGIN {
        print "╔══════════════════════════════════════════╗"
        print "║         STUDENT GRADE REPORT             ║"
        print "╠══════════════════════════════════════════╣"
    }
    NR > 1 {
        sum[$1] += $3; count[$1]++
        if ($3 > best[$1]) {best[$1] = $3; best_subj[$1] = $2}
    }
    END {
        for (name in sum) {
            avg = sum[name] / count[name]
            printf "║ %-10s Avg: %5.1f  Best: %s (%d) ║\n",
                name, avg, best_subj[name], best[name]
        }
        print "╚══════════════════════════════════════════╝"
    }' grades.txt

KEY INSIGHT: When you find yourself writing grep | sed | cut | sort...
maybe just use awk. It can do all of those in one pass.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # Uninitialized variables:
       echo "hello" | awk '{print x + 1}'   # x is 0 (not an error!)
       echo "hello" | awk '{print s "!"}'   # s is "" (empty string)
       # awk variables are auto-initialized to 0 (number) or "" (string)

    2. # Field separator gotcha:
       echo "a,,b" | awk -F, '{print NF}'   # 3 (empty field counts!)
       echo "a  b" | awk '{print NF}'       # 2 (multiple spaces = one separator)

    3. # Changing a field:
       echo "hello world" | awk '{$2="WORLD"; print $0}'
       # Notice: extra spaces are normalized! awk rebuilds the line.

    4. # Division by zero:
       echo "0" | awk '{print 10/$1}'       # Different behavior per system
       # Some: inf, some: error

    5. # When to use awk vs Python:
       # awk: quick one-liners, column extraction, simple aggregation
       # Python: complex logic, external libraries, persistence
       # Rule of thumb: if your awk is > 20 lines, write Python

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can now process structured text like a pro."
echo "  Next: 04_sort_uniq_cut.sh (the supporting cast)"
echo "═══════════════════════════════════════════════════════════════"
