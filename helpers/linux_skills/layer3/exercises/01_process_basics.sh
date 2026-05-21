#!/bin/bash
# =============================================================================
# Layer 3, Exercise 1: PROCESS BASICS
# =============================================================================
# THEORY-IN-ACTION: A process is a running program. Every command you type
# becomes a process. The kernel manages them all — scheduling CPU time,
# allocating memory, handling I/O. Understanding processes = understanding
# what your computer is actually DOING.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 1: Process Basics — What's Running On Your Machine?"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: Seeing Processes
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: ps — SNAPSHOT OF RUNNING PROCESSES ────

    # Basic process list:
    ps                          # Just YOUR processes in THIS terminal
    ps aux                      # ALL processes on the system (BSD style)
    ps -ef                      # ALL processes (Unix/POSIX style)

    # Understand the columns (ps aux):
    # USER  = who owns the process
    # PID   = Process ID (unique number)
    # %CPU  = CPU usage percentage
    # %MEM  = Memory usage percentage
    # VSZ   = Virtual memory size (KB)
    # RSS   = Resident Set Size — actual RAM used (KB)
    # TTY   = Terminal attached (? = no terminal)
    # STAT  = State code
    # START = When it started
    # TIME  = Total CPU time consumed
    # COMMAND = What's running

    # Process states (STAT column):
    # R = Running (actively using CPU)
    # S = Sleeping (waiting for something — I/O, timer, signal)
    # D = Uninterruptible sleep (usually disk I/O — can't be killed!)
    # Z = Zombie (finished but parent hasn't collected exit status)
    # T = Stopped (Ctrl+Z or SIGSTOP)
    # + = foreground process group
    # < = high priority
    # N = low priority (nice)

    ps aux | head -1                    # Just the header
    ps aux | grep -v "grep" | wc -l    # How many processes?

EXPERIMENT:
    # See YOUR processes:
    ps -u $USER --forest            # Tree view of your processes

    # What's using the most CPU right now?
    ps aux --sort=-%cpu | head -10

    # What's using the most memory?
    ps aux --sort=-%mem | head -10

    # See the process tree (parent-child relationships):
    ps axjf | head -40              # Shows PPID (Parent PID)
    pstree | head -30               # Beautiful tree view
    pstree -p | head -30            # With PIDs

KEY INSIGHT: Every process has: a PID, a parent (PPID), an owner (USER),
a state, and resource usage. `ps aux` is your process X-ray.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: /proc — The Process Filesystem
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: /proc/[PID] — DEEP DIVE INTO ANY PROCESS ────

    # Your shell's PID:
    echo "My PID: $$"
    echo "My parent's PID: $PPID"

    # Explore your own shell's /proc entry:
    ls /proc/$$                         # Lots of files!

    # Key files:
    cat /proc/$$/status                 # Name, state, memory, threads
    cat /proc/$$/cmdline | tr '\0' ' ' && echo  # Command line
    cat /proc/$$/environ | tr '\0' '\n' | head -10  # Environment vars
    ls -la /proc/$$/cwd                 # Current working directory (symlink)
    ls -la /proc/$$/exe                 # Executable path (symlink)
    cat /proc/$$/maps | head -10        # Memory mappings
    ls -la /proc/$$/fd                  # Open file descriptors
    cat /proc/$$/limits                 # Resource limits

    # Find what files a process has open:
    ls -la /proc/$$/fd | head -20
    # fd 0 = stdin, 1 = stdout, 2 = stderr, rest = opened files/sockets

    # Process family:
    cat /proc/$$/status | grep -E "PPid|Pid|Name"
    cat /proc/$PPID/status | grep -E "PPid|Pid|Name"   # Parent info

EXPERIMENT:
    # Start something and examine it:
    sleep 300 &
    SLEEPPID=$!
    echo "Sleep PID: $SLEEPPID"

    cat /proc/$SLEEPPID/status | grep State     # S (sleeping)
    cat /proc/$SLEEPPID/cmdline | tr '\0' ' ' && echo
    cat /proc/$SLEEPPID/wchan                   # What it's waiting on
    echo

    kill $SLEEPPID

    # How does `top` get its data? It reads /proc for every process!
    # Every monitoring tool is just reading /proc and formatting it.

KEY INSIGHT: /proc/[PID]/ is the kernel's live view of a process.
Tools like `ps`, `top`, `htop` just read these files and display them.
You can always go to the source directly.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: top and htop — Live Monitoring
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: REAL-TIME PROCESS MONITORING ────

    # top — built-in live monitor:
    top
    # Interactive keys in top:
    # q = quit
    # P = sort by CPU
    # M = sort by memory
    # k = kill a process (enter PID)
    # c = show full command line
    # 1 = show individual CPU cores
    # h = help

    # top header explained:
    # load average: 1min 5min 15min (processes wanting CPU)
    # Tasks: total, running, sleeping, stopped, zombie
    # %Cpu: us(user) sy(system) id(idle) wa(I/O wait)
    # Mem: total, free, used, buff/cache

    # Run top in batch mode (non-interactive, good for scripts):
    top -bn1 | head -20

    # htop — the better top (install if needed):
    # sudo apt install htop
    # htop
    # Features: mouse support, tree view (F5), search (F3), filter (F4)
    # Color-coded CPU/memory bars

    # Specific process monitoring:
    top -p $$                   # Monitor just your shell (q to quit)

EXPERIMENT:
    # Generate CPU load and watch it in top:
    # Terminal 1: Run top
    # Terminal 2: Run this
    yes > /dev/null &
    YESPID=$!
    # Watch it spike in top (should be ~100% one core)
    sleep 5
    kill $YESPID

    # Generate memory pressure:
    python3 -c "x = 'A' * (100 * 1024 * 1024); import time; time.sleep(10)" &
    # Watch memory usage spike in top, then process exits after 10s

KEY INSIGHT: top shows LIVE system status. The most important numbers:
- load average (> num_cores means overloaded)
- %wa (I/O wait — high means disk is bottleneck)
- free memory + buff/cache (Linux uses "free" RAM for cache, that's normal!)

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: Process Creation — fork and exec
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: HOW PROCESSES ARE BORN ────

    # Every process (except PID 1) is created by fork():
    # fork() = "clone myself" → creates child with new PID
    # exec() = "replace myself with a new program"

    # See it in action:
    strace -f -e trace=clone,execve bash -c "ls /tmp" 2>&1 | head -20
    # You'll see:
    # clone(...) → child PID created
    # execve("/usr/bin/ls", ["ls", "/tmp"]) → child becomes ls

    # The process tree proves it:
    echo "Shell PID: $$"
    bash -c 'echo "Child PID: $$ Parent: $PPID"'
    # The child's PPID = our PID!

    # Multiple children:
    for i in 1 2 3; do
        bash -c 'echo "Child $$ started"; sleep 2' &
    done
    ps --forest -g $$
    wait    # Wait for all children to finish

    # fork() without exec() (child is a COPY of parent):
    python3 -c "
import os
pid = os.fork()
if pid == 0:
    print(f'Child: PID={os.getpid()}, Parent={os.getppid()}')
else:
    print(f'Parent: PID={os.getpid()}, Child={pid}')
    os.waitpid(pid, 0)
"

EXPERIMENT:
    # How many processes does a pipeline create?
    echo "hello" | cat | wc -c
    # Answer: 3 (echo, cat, wc) + the shell managing them

    # Trace it:
    strace -f -e trace=clone bash -c 'echo hi | cat | wc -c' 2>&1 | grep clone

    # What about subshells?
    (echo "Subshell PID: $$")           # Same $$ (special case)
    (echo "Real PID: $BASHPID")         # Different! (subshell fork)

KEY INSIGHT: fork() + exec() is how EVERY program starts in Linux.
The shell fork()s for each command, then exec()s the program.
This is why environment changes in child processes don't affect the parent.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # Create a zombie process:
       python3 -c "
import os, time
pid = os.fork()
if pid == 0:
    # Child exits immediately
    os._exit(0)
else:
    # Parent sleeps without wait() — child becomes zombie
    print(f'Child {pid} is now a zombie. Check: ps aux | grep Z')
    time.sleep(15)
    # After parent exits, init adopts and reaps the zombie
"
       # In another terminal: ps aux | grep Z

    2. # Fork bomb (DO NOT RUN ON SHARED SYSTEMS):
       # :(){ :|:& };:
       # This defines a function : that calls itself twice in background
       # It's exponential process creation — freezes the system!
       # Understanding: fork unlimited → exhaust process table → system hangs

    3. # What happens to orphaned processes?
       bash -c 'sleep 100 &; echo "Parent exiting, child PID: $!"'
       # The sleep process is now orphaned — adopted by PID 1 (init/systemd)
       ps -ef | grep "sleep 100" | grep -v grep

    4. # Process with no terminal:
       nohup sleep 100 &
       ps aux | grep "sleep 100"    # TTY shows ?
       # It's a daemon now — no controlling terminal

    5. # How many processes can you create?
       ulimit -u                     # Max user processes
       cat /proc/sys/kernel/pid_max  # Max PID number system-wide

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You understand what processes are and how they work."
echo "  Next: 02_signals.sh"
echo "═══════════════════════════════════════════════════════════════"
