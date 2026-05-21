#!/bin/bash
# =============================================================================
# Layer 3, Exercise 2: SIGNALS
# =============================================================================
# THEORY-IN-ACTION: Signals are how the kernel and processes communicate
# asynchronously. They're like software interrupts — a process is doing its
# thing, and suddenly it receives a signal that says "stop", "die", "reload",
# or "your child exited."
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 2: Signals — Talking to Processes"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: Common Signals
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: THE SIGNAL TABLE ────

    # List all signals:
    kill -l

    # The important ones:
    # Signal     Number  Default Action      Sent By
    # ─────────────────────────────────────────────────────
    # SIGHUP     1       Terminate           Terminal closed
    # SIGINT     2       Terminate           Ctrl+C
    # SIGQUIT    3       Core dump           Ctrl+\
    # SIGKILL    9       Terminate (FORCED)  kill -9 (can't catch!)
    # SIGSEGV    11      Core dump           Invalid memory access
    # SIGTERM    15      Terminate           kill (default)
    # SIGSTOP    19      Stop (FORCED)       Can't catch!
    # SIGTSTP    20      Stop                Ctrl+Z
    # SIGCONT    18      Continue            fg, bg
    # SIGCHLD    17      Ignore              Child exited
    # SIGUSR1    10      Terminate           User-defined
    # SIGUSR2    12      Terminate           User-defined

    # Key insight: processes can CATCH most signals and handle them.
    # But SIGKILL (9) and SIGSTOP (19) CANNOT be caught — ever.

EXPERIMENT:
    # Start a background process:
    sleep 300 &
    PID=$!
    echo "PID: $PID"

    # Send signals:
    kill -SIGTERM $PID          # Politely ask it to die (same as: kill $PID)
    # OR
    sleep 300 &
    PID=$!
    kill -15 $PID               # Same thing by number
    # OR
    sleep 300 &
    PID=$!
    kill -SIGKILL $PID          # Force kill (no cleanup possible)

    # Check if it's dead:
    ps -p $PID 2>/dev/null && echo "Still alive" || echo "Dead"

KEY INSIGHT: SIGTERM = "please shut down" (process can cleanup first)
SIGKILL = "die NOW" (no cleanup, kernel removes it immediately)
ALWAYS try SIGTERM first. Use SIGKILL only as last resort.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Sending Signals with kill
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: kill COMMAND (IT DOESN'T JUST KILL!) ────

    # Despite the name, `kill` sends ANY signal:
    # kill -SIGNAL PID

    # Start test processes:
    sleep 1000 &
    PID1=$!
    sleep 1000 &
    PID2=$!
    sleep 1000 &
    PID3=$!
    echo "PIDs: $PID1 $PID2 $PID3"

    # Default signal is SIGTERM (15):
    kill $PID1                  # Same as: kill -15 $PID1

    # Stop (pause) a process:
    kill -SIGSTOP $PID2         # Process freezes
    ps -o pid,stat,cmd -p $PID2 # State: T (stopped)

    # Continue (resume) a process:
    kill -SIGCONT $PID2         # Process resumes
    ps -o pid,stat,cmd -p $PID2 # State: S (sleeping again)

    # Kill multiple processes:
    kill $PID2 $PID3            # Both receive SIGTERM

    # Kill all processes with a name:
    sleep 500 & sleep 500 & sleep 500 &
    killall sleep               # Kill all processes named "sleep"

    # Kill by pattern:
    pkill -f "sleep 500"        # Kill processes whose command matches pattern

    # Find then kill:
    pgrep -la sleep             # Find processes (shows PID + command)
    pkill sleep                 # Kill them

EXPERIMENT:
    # What happens when you kill PID 1?
    # kill -9 1                 # DON'T DO THIS — undefined behavior!
    # On modern systems, PID 1 (systemd) ignores SIGKILL anyway.

    # Kill your own shell (carefully):
    bash                        # Start a subshell
    echo "Subshell PID: $$"
    kill -9 $$                  # Kills the subshell, returns to parent
    # You're back in the parent shell!

KEY INSIGHT: kill sends signals, it doesn't just terminate.
`kill -STOP` pauses, `kill -CONT` resumes, `kill -HUP` reloads config.
Use `killall` (by name) or `pkill` (by pattern) for convenience.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Ctrl+C, Ctrl+Z, Ctrl+\
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: KEYBOARD SIGNALS ────

    # Your keyboard sends signals too:
    # Ctrl+C  → SIGINT (2)   → "interrupt" → default: terminate
    # Ctrl+Z  → SIGTSTP (20) → "terminal stop" → default: suspend
    # Ctrl+\  → SIGQUIT (3)  → "quit" → default: terminate + core dump

    # Try each:
    sleep 100                   # Now press Ctrl+C → process dies
    sleep 100                   # Now press Ctrl+Z → process stops (backgrounded)
    jobs                        # See the stopped job
    fg                          # Bring it back
    # Ctrl+\ now → dies with "Quit (core dumped)"

    # Which terminal characters send which signals:
    stty -a                     # Look for "intr", "susp", "quit"
    # intr = ^C    (SIGINT)
    # susp = ^Z    (SIGTSTP)
    # quit = ^\    (SIGQUIT)

    # You can change them:
    # stty intr ^X              # Make Ctrl+X send SIGINT instead of Ctrl+C
    # stty intr ^C              # Reset to normal

EXPERIMENT:
    # Some programs catch SIGINT and don't die:
    python3 -c "
import signal, time
def handler(sig, frame):
    print('Caught SIGINT! Not dying.')
signal.signal(signal.SIGINT, handler)
print('Press Ctrl+C (I will catch it). Ctrl+\\ to really kill me.')
while True:
    time.sleep(1)
"
    # Press Ctrl+C — it catches it!
    # Press Ctrl+\ — SIGQUIT kills it (unless also caught)

    # This is why some programs need kill -9:
    # They catch SIGTERM and SIGINT and refuse to die.

KEY INSIGHT: Ctrl+C sends SIGINT (catchable), Ctrl+\ sends SIGQUIT (also
catchable but rarely caught), and kill -9 sends SIGKILL (NEVER catchable).
Programs catch signals to do cleanup (save data, close connections, etc.)

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: trap — Catching Signals in Scripts
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: trap — HANDLE SIGNALS IN YOUR SCRIPTS ────

    # trap lets your script DO SOMETHING when it receives a signal:

    # Example: cleanup on exit
    bash -c '
        trap "echo Cleaning up...; rm -f /tmp/myscript.lock" EXIT
        echo "Script running (PID: $$)"
        echo "Creating lock file"
        touch /tmp/myscript.lock
        sleep 5
        echo "Script finished normally"
    '
    # Notice: "Cleaning up..." runs even on normal exit!

    # Example: catch Ctrl+C
    bash -c '
        trap "echo Interrupted!; exit 1" SIGINT
        echo "Press Ctrl+C to test (or wait 10s)"
        sleep 10
        echo "Done (you did not interrupt)"
    '
    # Press Ctrl+C during the sleep

    # Example: ignore a signal
    bash -c '
        trap "" SIGINT   # Empty handler = ignore
        echo "Try pressing Ctrl+C (I ignore it)"
        sleep 5
        echo "See? Still alive."
    '

    # Practical: graceful shutdown
    bash -c '
        RUNNING=true
        trap "echo Shutting down...; RUNNING=false" SIGTERM SIGINT

        echo "Server running (PID: $$). Send SIGTERM to stop."
        while $RUNNING; do
            sleep 1
        done
        echo "Server stopped cleanly."
    ' &
    SERVER_PID=$!
    sleep 2
    kill $SERVER_PID
    wait $SERVER_PID 2>/dev/null

EXPERIMENT:
    # trap DEBUG — runs before EVERY command:
    bash -c '
        trap "echo [DEBUG] About to run: $BASH_COMMAND" DEBUG
        echo "hello"
        ls /tmp > /dev/null
        echo "world"
    '

    # trap ERR — runs when any command fails:
    bash -c '
        set -e
        trap "echo ERROR on line $LINENO" ERR
        echo "This works"
        false                   # This fails!
        echo "Never reached"
    '

KEY INSIGHT: trap is essential for robust scripts:
- `trap cleanup EXIT` → always cleanup (temp files, locks)
- `trap handler SIGTERM` → graceful shutdown for daemons
- `trap "" SIGNAL` → ignore a signal completely

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # Can you catch SIGKILL?
       bash -c '
           trap "echo caught!" SIGKILL  # Does this work?
           echo "Try to kill -9 me (PID: $$)"
           sleep 100
       ' &
       kill -9 $!              # Dead anyway — SIGKILL is uncatchable

    2. # What about SIGSTOP?
       bash -c '
           trap "echo caught!" SIGSTOP  # Does this work?
           sleep 100
       ' &
       kill -STOP $!           # Stopped anyway — SIGSTOP is uncatchable
       kill -CONT $!; kill $!  # Resume then terminate

    3. # Signal race condition:
       # What if a signal arrives while you're in your handler?
       bash -c '
           trap "echo handling...; sleep 3; echo done" SIGUSR1
           echo "PID: $$"
           sleep 100
       ' &
       PID=$!
       kill -USR1 $PID         # First signal
       kill -USR1 $PID         # Second while handling first — queued? lost?
       sleep 5; kill $PID

    4. # SIGHUP and terminals:
       # When you close a terminal, all processes in it get SIGHUP
       bash -c 'echo $$ > /tmp/hup_test.pid; sleep 100' &
       # If you close this terminal, that sleep will die (SIGHUP)
       # nohup prevents this: nohup sleep 100 &

    5. # Signal to process group:
       bash -c 'sleep 100 & sleep 100 & sleep 100 & wait' &
       PGID=$!
       ps -o pid,pgid,cmd --forest -g $PGID
       kill -- -$PGID          # Negative PID = send to entire process GROUP

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can communicate with any process via signals."
echo "  Next: 03_job_control.sh"
echo "═══════════════════════════════════════════════════════════════"
