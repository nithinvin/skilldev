#!/bin/bash
# =============================================================================
# Layer 4, Exercise 1: VARIABLES AND QUOTING
# =============================================================================
# THEORY-IN-ACTION: Shell scripting starts with variables. But bash variables
# have tricky behaviors around quoting, expansion, and scope that trip up
# everyone. Master these rules first, and your scripts won't have subtle bugs.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 1: Variables & Quoting — The Foundation of Scripts"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: Variable Basics
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: SETTING AND READING VARIABLES ────

    # Assignment (NO spaces around =):
    name="Nithin"               # Correct
    # name = "Nithin"           # WRONG! bash thinks "name" is a command

    # Reading:
    echo $name
    echo "$name"                # Always quote! (explained in Part 2)
    echo "${name}"              # Braces for clarity
    echo "Hello, ${name}!"     # Embed in string

    # Unset/empty:
    echo "unset: $undefined_var"           # Empty string (no error!)
    unset name
    echo "after unset: $name"              # Also empty

    # Default values:
    echo "${EDITOR:-vim}"       # Use vim if EDITOR is unset/empty
    echo "${MISSING:-default}"  # "default"
    echo "${HOME:-/tmp}"        # Uses $HOME (it's set)

    # Assign default if unset:
    : "${MY_CONFIG:=/etc/default.conf}"    # Sets MY_CONFIG if empty
    echo "$MY_CONFIG"

    # Error if unset:
    # ${REQUIRED_VAR:?"Error: REQUIRED_VAR must be set"}
    # This exits the script if REQUIRED_VAR is empty!

    # String length:
    greeting="Hello World"
    echo "${#greeting}"         # 11

    # Substring:
    echo "${greeting:0:5}"      # "Hello" (offset 0, length 5)
    echo "${greeting:6}"        # "World" (offset 6 to end)

EXPERIMENT:
    # Parameter expansion tricks:
    filename="document.backup.tar.gz"
    echo "${filename%.gz}"          # Remove shortest match from end: document.backup.tar
    echo "${filename%.*}"           # Remove shortest .* from end: document.backup.tar
    echo "${filename%%.*}"          # Remove LONGEST from end: document
    echo "${filename#*.}"           # Remove shortest from start: backup.tar.gz
    echo "${filename##*.}"          # Remove longest from start: gz

    # Practical: extract extension and basename
    filepath="/home/user/project/main.py"
    echo "Dir: $(dirname $filepath)"        # /home/user/project
    echo "File: $(basename $filepath)"      # main.py
    echo "Name: ${filepath##*/}"            # main.py (same, no subprocess!)
    echo "Ext: ${filepath##*.}"             # py
    echo "NoExt: ${filepath%.*}"            # /home/user/project/main

KEY INSIGHT: ${var} has powerful text manipulation built in.
%/# remove patterns from end/start. %%/## are greedy versions.
This avoids spawning sed/cut for simple string operations.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Quoting (The #1 Source of Bugs)
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: QUOTING — WHY IT MATTERS ────

    # The problem: bash splits words and expands globs UNLESS you quote.

    # Double quotes "$var" — preserves spaces, expands variables:
    file="my document.txt"
    touch "$file"               # Creates ONE file: "my document.txt"
    touch $file                 # Creates TWO files: "my" and "document.txt" !!
    rm -f "my document.txt" my document.txt 2>/dev/null

    # Single quotes 'literal' — NO expansion at all:
    echo 'Hello $USER'          # Literally: Hello $USER
    echo "Hello $USER"          # Expands: Hello nithin

    # No quotes — word splitting AND glob expansion:
    files="*.txt"
    echo $files                 # Expands globs! Lists all .txt files
    echo "$files"               # Literally: *.txt

    # The golden rule: ALWAYS DOUBLE-QUOTE VARIABLES
    # Exception: when you deliberately want word splitting

    # Quoting inside quotes:
    echo "She said \"hello\""   # Escape with backslash
    echo 'She said "hello"'    # Or use other quote type
    echo "It's fine"           # Single quote inside double is fine
    echo 'Can'\''t'            # Single quote inside single: end-open-close

    # $() command substitution — also needs quoting:
    current_dir="$(pwd)"        # Good: quoted
    # current_dir=$(pwd)        # Works here, but fails if pwd has spaces

EXPERIMENT:
    # Classic bug:
    mkdir -p /tmp/quote_test && cd /tmp/quote_test
    touch "file 1.txt" "file 2.txt" "file 3.txt"

    # Without quotes:
    for f in $(ls); do echo "Found: [$f]"; done
    # Output: Found: [file] Found: [1.txt] Found: [file] Found: [2.txt] ...
    # WRONG! Split on spaces!

    # With quotes (but ls is still wrong):
    for f in "$(ls)"; do echo "Found: [$f]"; done
    # Also wrong — it's all one string now!

    # Correct way:
    for f in *.txt; do echo "Found: [$f]"; done
    # Output: Found: [file 1.txt] Found: [file 2.txt] Found: [file 3.txt]

    rm -rf /tmp/quote_test

KEY INSIGHT: Unquoted variables undergo word splitting and globbing.
"$var" prevents both. ALWAYS quote unless you have a reason not to.
For file loops: use globs (*.txt) not $(ls).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Arrays
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: BASH ARRAYS ────

    # Indexed arrays:
    fruits=("apple" "banana" "cherry" "date")

    echo "${fruits[0]}"         # apple (0-indexed!)
    echo "${fruits[2]}"         # cherry
    echo "${fruits[@]}"         # All elements
    echo "${#fruits[@]}"        # Count: 4

    # Add elements:
    fruits+=("elderberry")
    echo "${fruits[@]}"

    # Loop over array (SAFELY — handles spaces):
    for fruit in "${fruits[@]}"; do
        echo "- $fruit"
    done

    # Array from command output:
    files=($(find /etc -maxdepth 1 -name "*.conf" 2>/dev/null))
    echo "Found ${#files[@]} conf files"
    echo "First: ${files[0]}"

    # Slice:
    echo "${fruits[@]:1:3}"     # Elements 1,2,3 (banana cherry date)

    # Delete element:
    unset 'fruits[1]'           # Removes banana (leaves gap!)
    echo "${fruits[@]}"         # apple cherry date elderberry

    # Associative arrays (bash 4+):
    declare -A colors
    colors[red]="#ff0000"
    colors[green]="#00ff00"
    colors[blue]="#0000ff"

    echo "${colors[red]}"       # #ff0000
    echo "${!colors[@]}"        # All keys: red green blue
    echo "${colors[@]}"         # All values

    for key in "${!colors[@]}"; do
        echo "$key = ${colors[$key]}"
    done

EXPERIMENT:
    # Why arrays matter for filenames with spaces:
    # BAD:
    filelist="file one.txt file two.txt"
    for f in $filelist; do echo "[$f]"; done  # 4 words, not 2 files!

    # GOOD:
    filelist=("file one.txt" "file two.txt")
    for f in "${filelist[@]}"; do echo "[$f]"; done  # 2 files!

    # Read lines into array:
    mapfile -t lines < /etc/passwd
    echo "Users: ${#lines[@]}"
    echo "First: ${lines[0]}"
    echo "Last: ${lines[-1]}"

KEY INSIGHT: Arrays are the safe way to handle lists of items (especially
filenames with spaces). Always use "${array[@]}" (quoted!) in loops.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: Special Variables
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: SPECIAL VARIABLES ────

    # Script/function arguments:
    # $0    = script name (or function name)
    # $1-$9 = positional arguments
    # ${10} = 10th argument (braces required for > 9)
    # $#    = number of arguments
    # $@    = all arguments (as separate words — QUOTE IT: "$@")
    # $*    = all arguments (as one string — rarely want this)

    # Process info:
    # $$    = current shell's PID
    # $!    = last background process's PID
    # $?    = exit code of last command (0=success, 1-255=failure)
    # $-    = current shell options (e.g., himBHs)

    # Demo with a temporary script:
    cat > /tmp/demo_args.sh << 'SCRIPT'
#!/bin/bash
echo "Script: $0"
echo "Args: $#"
echo "All: $@"
echo "First: $1"
echo "Second: $2"
echo "PID: $$"
SCRIPT
    chmod +x /tmp/demo_args.sh
    /tmp/demo_args.sh hello world "third arg"

    # "$@" vs "$*" — critical difference:
    cat > /tmp/test_at.sh << 'SCRIPT'
#!/bin/bash
echo "--- \$@ (each arg separate) ---"
for arg in "$@"; do echo "  [$arg]"; done
echo "--- \$* (all as one) ---"
for arg in "$*"; do echo "  [$arg]"; done
SCRIPT
    chmod +x /tmp/test_at.sh
    /tmp/test_at.sh "hello world" "foo bar"
    # $@ correctly preserves: [hello world] [foo bar]
    # $* merges into: [hello world foo bar]

EXPERIMENT:
    # shift — consume arguments:
    cat > /tmp/test_shift.sh << 'SCRIPT'
#!/bin/bash
echo "Before: $@"
echo "First: $1"
shift
echo "After shift: $@"
echo "First now: $1"
SCRIPT
    chmod +x /tmp/test_shift.sh
    /tmp/test_shift.sh a b c d

    # PIPESTATUS — exit codes of ALL pipeline commands:
    true | false | true
    echo "${PIPESTATUS[@]}"     # 0 1 0

KEY INSIGHT: "$@" preserves argument boundaries (ALWAYS use this to pass
args to other commands). $? gives the last exit code. $! gives the last
background PID. These are the glue of shell scripting.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # Spaces in assignment:
       x = 5                    # Error! bash runs "x" with args "=" and "5"
       x=5                      # Correct

    2. # Missing quotes disaster:
       dir="/tmp/my project"
       mkdir -p "$dir"
       cd $dir                  # Error: /tmp/my: No such file
       cd "$dir"                # Works
       rm -rf "$dir"

    3. # Indirect variable reference:
       var_name="HOME"
       echo "${!var_name}"      # Prints value of $HOME!

    4. # Integer arithmetic (not string!):
       x=5
       y=3
       echo $((x + y))         # 8 (arithmetic)
       echo "$x + $y"          # "5 + 3" (string)
       echo $((x ** y))        # 125 (exponent)

    5. # Array gotchas:
       arr=(one two three)
       echo ${arr}             # Just "one" (same as ${arr[0]})!
       echo ${arr[@]}          # All elements
       # Without [@], array just gives first element!

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: Variables and quoting mastered."
echo "  Next: 02_conditionals.sh"
echo "═══════════════════════════════════════════════════════════════"
