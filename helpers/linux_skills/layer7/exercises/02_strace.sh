#!/bin/bash
# =============================================================================
# Layer 7, Exercise 2: STRACE — SYSTEM CALL TRACING
# =============================================================================
# THEORY-IN-ACTION: Every program talks to the kernel through system calls
# (syscalls). strace intercepts and logs every syscall a program makes.
# It's your X-ray vision into what any program is actually DOING —
# what files it opens, what network connections it makes, what's failing.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 2: strace — X-Ray Vision for Programs"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: BASIC STRACE ────

    # Trace a simple command:
    strace echo "hello" 2>&1 | tail -20
    # Every line = one system call

    # Reading strace output:
    # syscall_name(arguments) = return_value
    # write(1, "hello\n", 6) = 6
    # ↑ syscall  ↑ fd=stdout ↑ data ↑ length  ↑ bytes written

    # Common syscalls you'll see:
    # open/openat  = open a file
    # read         = read from file/socket
    # write        = write to file/socket
    # close        = close file descriptor
    # mmap         = map memory
    # brk          = extend heap
    # execve       = execute a program
    # clone/fork   = create a process
    # connect      = network connection
    # stat/fstat   = get file info
    # access       = check permissions

    # Trace with more detail:
    strace -f ls /tmp 2>&1 | head -30   # -f = follow child processes
    strace -e trace=open,read ls / 2>&1 | head -20  # Only file operations
    strace -e trace=network curl -s google.com 2>&1 | head -30  # Only network

    # Count syscalls (summary):
    strace -c ls /tmp 2>&1
    # Shows: % time, calls, syscall name — like a profiler!

EXPERIMENT:
    # What files does 'cat' open?
    strace -e openat cat /etc/hostname 2>&1
    # You'll see it opens the C library, then your file

    # What does 'python3 -c "print(1)"' actually do?
    strace -c python3 -c "print(1)" 2>&1 | tail -20
    # Hundreds of syscalls just to print "1"!
    # Compare to: strace -c echo "1" 2>&1 | tail -10

    # Trace file access:
    strace -e trace=file ls / 2>&1 | head -20
    # Shows every file operation (openat, stat, access, etc.)

KEY INSIGHT: strace shows you TRUTH — not what a program says it does,
but what it ACTUALLY does. "File not found" in strace = definitive answer.
-c gives you a syscall profile (which syscalls take the most time).

──── PART 2: DEBUGGING WITH STRACE ────

    # Attach to a running process:
    # sudo strace -p PID 2>&1 | head -50
    # (Shows what the process is doing RIGHT NOW)

    # Common debugging patterns:

    # 1. "Why can't my program find the config file?"
    strace -e openat myprogram 2>&1 | grep -i config
    # Shows EXACTLY which paths it searches

    # 2. "Why is my program hanging?"
    # sudo strace -p PID    # Shows it stuck in read(), poll(), etc.

    # 3. "Why does my program crash?"
    strace ./buggy_program 2>&1 | tail -5
    # Last syscall before exit = probable cause

    # 4. "What's taking so long?"
    strace -T ls /tmp 2>&1 | sort -t= -k2 -n | tail -5
    # -T shows time spent in each syscall

    # 5. "Why permission denied?"
    strace -e trace=openat,access program 2>&1 | grep "EACCES\|EPERM"
    # Shows EXACTLY which file/operation was denied

    # Useful strace flags:
    # -f     = follow forks (trace child processes too)
    # -p PID = attach to running process
    # -o file = write output to file (instead of stderr)
    # -t     = timestamp each syscall
    # -T     = show time spent in each syscall
    # -e trace=network = only network syscalls
    # -e trace=file    = only file syscalls
    # -e trace=process = only process syscalls (fork, exec, exit)
    # -s 1000 = show more string data (default truncates at 32 chars)

EXPERIMENT:
    # Debug a Python program:
    python3 -c "
import json
try:
    with open('/nonexistent/config.json') as f:
        json.load(f)
except:
    pass
" &
    # Now trace it:
    strace -e openat python3 -c "open('/nonexistent/config.json')" 2>&1 | grep nonexistent
    # openat(AT_FDCWD, "/nonexistent/config.json", O_RDONLY) = -1 ENOENT (No such file or directory)
    # ^ This is HOW you debug "file not found" problems definitively

    # Trace network connections:
    strace -e connect curl -s https://example.com 2>&1 | grep -A1 "connect("
    # Shows the IP address and port it actually connects to

    # Save long traces to a file:
    strace -f -o /tmp/trace.txt ls -la /tmp
    wc -l /tmp/trace.txt                # How many syscalls?
    grep "openat" /tmp/trace.txt | head -10
    rm /tmp/trace.txt

KEY INSIGHT: When a program "doesn't work" and gives you no useful error,
strace tells you EXACTLY what's happening: which file it can't find,
which syscall is failing, which permission is denied. It's definitive.

──── PART 3: ltrace AND OTHER TRACING ────

    # ltrace = trace library calls (not syscalls):
    ltrace ls /tmp 2>&1 | head -20
    # Shows calls to libc functions: strlen, malloc, printf, etc.
    # Higher level than strace — shows what the C library is doing

    # Comparison:
    # strace → kernel interface (open, read, write, mmap)
    # ltrace → library interface (malloc, printf, strlen)

    # perf trace (alternative to strace, less overhead):
    # sudo perf trace ls /tmp 2>&1 | head -20

    # /proc-based debugging (no overhead!):
    cat /proc/$$/syscall 2>/dev/null    # Current syscall being executed
    cat /proc/$$/stack 2>/dev/null      # Kernel stack (if available)
    cat /proc/$$/wchan 2>/dev/null      # What kernel function it's waiting in

EXPERIMENT:
    # Profile where time is spent:
    strace -c -f python3 -c "import os; os.listdir('/tmp')" 2>&1 | tail -15
    # Which syscall dominates? (probably read/mmap for loading libraries)

    # Find all files a complex program touches:
    strace -e trace=openat -f bash -c "ls /tmp && echo hi" 2>&1 | grep -v ENOENT | head -20

KEY INSIGHT: strace = syscalls (program↔kernel).
ltrace = library calls (program↔libc).
Use strace 95% of the time — it's the universal debugging tool.
If a program is misbehaving and logs don't help, strace ALWAYS tells the truth.

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You have X-ray vision for any program."
echo "  Next: 03_memory_and_performance.sh"
echo "═══════════════════════════════════════════════════════════════"
