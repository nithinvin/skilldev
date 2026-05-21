#!/bin/bash
# =============================================================================
# Layer 4, Exercise 4: FUNCTIONS AND ERROR HANDLING
# =============================================================================
# THEORY-IN-ACTION: Functions make scripts modular and reusable. Error handling
# makes them robust. Together, they're what separates a quick hack from a
# production script that won't silently fail at 3am.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 4: Functions & Error Handling — Production-Grade Scripts"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: Functions
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: DEFINING AND USING FUNCTIONS ────

    # Define a function:
    greet() {
        echo "Hello, $1!"
    }
    greet "Nithin"              # Hello, Nithin!
    greet "World"               # Hello, World!

    # Arguments are $1, $2, ... (just like scripts):
    add() {
        echo $(( $1 + $2 ))
    }
    result=$(add 5 3)
    echo "5 + 3 = $result"     # 8

    # Local variables (don't pollute global scope):
    count_files() {
        local dir="${1:-.}"     # Default to current dir
        local count
        count=$(find "$dir" -type f | wc -l)
        echo "$count"
    }
    echo "Files in /etc: $(count_files /etc)"
    echo "Files here: $(count_files)"
    echo "$count"               # Empty! (it was local)

    # Return values (exit codes, not values!):
    is_even() {
        (( $1 % 2 == 0 ))      # Exit code 0 if true
    }
    if is_even 4; then echo "4 is even"; fi
    if is_even 7; then echo "7 is even"; else echo "7 is odd"; fi

    # For returning DATA, use echo + command substitution:
    get_extension() {
        local file="$1"
        echo "${file##*.}"
    }
    ext=$(get_extension "photo.jpg")
    echo "Extension: $ext"      # jpg

EXPERIMENT:
    # Functions that take options:
    log() {
        local level="${1:-INFO}"
        shift
        echo "[$(date '+%H:%M:%S')] [$level] $*"
    }
    log INFO "Server started"
    log ERROR "Connection failed"
    log WARN "Disk 80% full"
    log "Default level message"

    # Recursive function:
    factorial() {
        if [[ $1 -le 1 ]]; then
            echo 1
        else
            local prev=$(factorial $(( $1 - 1 )))
            echo $(( $1 * prev ))
        fi
    }
    echo "5! = $(factorial 5)"  # 120

KEY INSIGHT: Functions are mini-scripts. They have their own arguments ($1, $2).
Use `local` for variables that shouldn't leak. Return DATA via echo/stdout.
Return STATUS via exit code (return 0 = success, return 1 = failure).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Error Handling (set -euo pipefail)
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: DEFENSIVE SCRIPTING ────

    # The "strict mode" — put this at the top of every script:
    # set -euo pipefail

    # What each flag does:
    # -e = Exit immediately if a command fails (non-zero exit)
    # -u = Exit if you use an undefined variable
    # -o pipefail = Pipeline fails if ANY command in it fails (not just last)

    # Demo without strict mode:
    bash -c '
        false               # Exit code 1, but script continues!
        echo "Still running!"
        echo "$undefined"   # Empty string, no error
        false | true        # Pipeline "succeeds" (only checks last command)
        echo "All fine!"
    '

    # Demo WITH strict mode:
    bash -c '
        set -euo pipefail
        echo "Starting..."
        false               # Script STOPS here!
        echo "Never reached"
    ' 2>&1 || echo "(Script exited with error, as expected)"

    # Undefined variable with -u:
    bash -c '
        set -u
        echo "Name: $undefined_var"   # EXITS with error!
    ' 2>&1 || echo "(Caught undefined var)"

    # pipefail:
    bash -c '
        set -o pipefail
        false | true        # Pipeline now FAILS!
        echo "Never reached"
    ' 2>&1 || echo "(Pipeline failed as expected)"

EXPERIMENT:
    # Sometimes you WANT a command to fail without exiting:
    bash -c '
        set -e
        if ! grep -q "nonexistent" /etc/passwd; then
            echo "Not found (this is OK)"
        fi
        echo "Script continues!"
    '

    # Or use || true:
    bash -c '
        set -e
        rm /nonexistent 2>/dev/null || true   # Ignore failure
        echo "Still running"
    '

KEY INSIGHT: `set -euo pipefail` catches 90% of script bugs automatically.
Add it to EVERY script. Then explicitly handle expected failures with
`|| true` or `if ! cmd; then ...`.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: trap for Cleanup
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: ROBUST SCRIPTS WITH trap ────

    # Pattern: create temp files safely, always clean up:
    bash -c '
        set -euo pipefail

        # Create temp file/dir safely:
        TMPDIR=$(mktemp -d)
        TMPFILE=$(mktemp)

        # Always clean up, even on error:
        cleanup() {
            echo "Cleaning up: $TMPDIR $TMPFILE"
            rm -rf "$TMPDIR" "$TMPFILE"
        }
        trap cleanup EXIT

        # Do work:
        echo "Working in $TMPDIR"
        echo "data" > "$TMPDIR/work.txt"
        echo "Temp file: $TMPFILE"

        # Even if we exit early, cleanup runs:
        # false  # (uncomment to test — cleanup still runs!)
        echo "Done!"
    '

    # Pattern: lock file (prevent duplicate runs):
    bash -c '
        LOCKFILE="/tmp/myscript.lock"

        cleanup() { rm -f "$LOCKFILE"; }
        trap cleanup EXIT

        if [[ -f "$LOCKFILE" ]]; then
            echo "Script already running! (lock: $LOCKFILE)"
            exit 1
        fi
        echo $$ > "$LOCKFILE"

        echo "Running... (PID $$)"
        sleep 2
        echo "Done"
    '

    # Pattern: graceful shutdown:
    bash -c '
        shutdown=false
        trap "shutdown=true; echo Shutting down..." SIGTERM SIGINT

        echo "Server PID: $$. Press Ctrl+C to stop."
        while ! $shutdown; do
            echo "Working... $(date +%H:%M:%S)"
            sleep 1
        done
        echo "Cleanup complete."
    ' &
    PID=$!
    sleep 3
    kill $PID
    wait $PID 2>/dev/null

EXPERIMENT:
    # Full robust script template:
    cat << 'SCRIPT'
#!/bin/bash
set -euo pipefail

# --- Globals ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMPDIR=$(mktemp -d)
LOG_FILE="/tmp/$(basename "$0").log"

# --- Cleanup ---
cleanup() {
    local exit_code=$?
    rm -rf "$TMPDIR"
    [[ $exit_code -ne 0 ]] && echo "FAILED (exit $exit_code)" | tee -a "$LOG_FILE"
    exit $exit_code
}
trap cleanup EXIT

# --- Logging ---
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"; }

# --- Main ---
main() {
    log "Starting..."
    # Your code here
    log "Done."
}

main "$@"
SCRIPT

KEY INSIGHT: Every production script should have:
1. set -euo pipefail (catch errors)
2. trap cleanup EXIT (always clean up)
3. mktemp for temp files (never hardcode temp paths)
4. Logging (so you can debug failures after the fact)

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: Real Scripts
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: PUTTING IT ALL TOGETHER ────

    # Script 1: Safe backup script
    cat > /tmp/backup_demo.sh << 'SCRIPT'
#!/bin/bash
set -euo pipefail

SOURCE="${1:?Usage: $0 <source_dir>}"
BACKUP_DIR="/tmp/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"

log() { echo "[$(date '+%H:%M:%S')] $*"; }

[[ -d "$SOURCE" ]] || { log "ERROR: $SOURCE is not a directory"; exit 1; }

mkdir -p "$BACKUP_DIR"
log "Backing up $SOURCE to $BACKUP_FILE"
tar -czf "$BACKUP_FILE" -C "$(dirname "$SOURCE")" "$(basename "$SOURCE")"
log "Done. Size: $(du -h "$BACKUP_FILE" | cut -f1)"

# Cleanup old backups (keep last 5):
ls -t "$BACKUP_DIR"/backup_*.tar.gz | tail -n +6 | xargs rm -f 2>/dev/null || true
log "Cleanup complete. Backups: $(ls "$BACKUP_DIR" | wc -l)"
SCRIPT
    chmod +x /tmp/backup_demo.sh
    /tmp/backup_demo.sh /etc/apt

    # Script 2: System health check
    cat > /tmp/healthcheck.sh << 'SCRIPT'
#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

check() {
    local name="$1" status="$2"
    if [[ "$status" == "OK" ]]; then
        printf "${GREEN}✓${NC} %-20s %s\n" "$name" "$status"
    elif [[ "$status" == "WARN" ]]; then
        printf "${YELLOW}⚠${NC} %-20s %s\n" "$name" "${3:-}"
    else
        printf "${RED}✗${NC} %-20s %s\n" "$name" "${3:-FAILED}"
    fi
}

echo "=== System Health Check ==="
echo ""

# CPU load
load=$(cut -d' ' -f1 /proc/loadavg)
cores=$(nproc)
if (( $(echo "$load < $cores" | bc -l) )); then
    check "CPU Load" "OK" "$load / $cores cores"
else
    check "CPU Load" "WARN" "$load / $cores cores (overloaded)"
fi

# Memory
mem_avail=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)
mem_total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
mem_pct=$(( (mem_total - mem_avail) * 100 / mem_total ))
if [[ $mem_pct -lt 80 ]]; then
    check "Memory" "OK" "${mem_pct}% used"
else
    check "Memory" "WARN" "${mem_pct}% used"
fi

# Disk
disk_pct=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [[ $disk_pct -lt 80 ]]; then
    check "Disk /" "OK" "${disk_pct}% used"
else
    check "Disk /" "WARN" "${disk_pct}% used"
fi

echo ""
SCRIPT
    chmod +x /tmp/healthcheck.sh
    /tmp/healthcheck.sh

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # Function name collision with command:
       ls() { echo "I replaced ls!"; }
       ls                       # "I replaced ls!"
       unset -f ls              # Restore original
       ls                       # Normal again
       # Functions shadow commands! Use `command ls` to bypass.

    2. # set -e doesn't catch everything:
       bash -c '
           set -e
           x=$(false)          # This IS caught
           echo "Not reached"
       ' || echo "caught"

       bash -c '
           set -e
           false || true       # NOT caught (|| handles it)
           echo "Still running"
       '

    3. # Return vs Exit:
       myfunc() { return 1; }  # Returns from function
       myfunc
       echo $?                  # 1
       # exit 1                 # Would exit the ENTIRE script/shell!

    4. # Subshell functions:
       myfunc() { echo "defined"; }
       (myfunc)                 # Works (subshell inherits)
       bash -c 'myfunc'        # FAILS (new process, no inheritance)
       # Functions aren't exported by default!
       export -f myfunc        # Now it works in child bash

    5. # set -u with arrays:
       set -u
       arr=()
       echo "${arr[@]}"        # Error in bash < 4.4! (empty array = unset)
       echo "${arr[@]+"${arr[@]}"}"  # Safe way for old bash

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can write robust, production-quality shell scripts."
echo "  Layer 4 complete!"
echo "═══════════════════════════════════════════════════════════════"
