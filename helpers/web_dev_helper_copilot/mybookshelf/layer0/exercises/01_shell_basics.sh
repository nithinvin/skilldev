#!/bin/bash
# =============================================================================
# Level 0.1 — The Shell Is Your IDE
# =============================================================================
#
# QUESTIONS (answer these BEFORE running the exercises):
#
#   1. What is a shell? How is it different from a terminal emulator?
#      - Terminal = the window (like GNOME Terminal, Windows Terminal, xterm)
#      - Shell = the program INSIDE the window (bash, zsh, fish)
#      - The terminal draws pixels. The shell interprets commands.
#
#   2. When you type `ls` and press Enter, what actually happens?
#      - Shell reads "ls" from stdin
#      - Shell searches PATH for an executable named "ls"
#      - Shell calls fork() → creates a child process (copy of itself)
#      - Child calls execve("/usr/bin/ls", ...) → replaces itself with ls
#      - Parent (shell) calls wait() → waits for child to finish
#      - ls writes output to stdout (fd 1) → terminal displays it
#
#   3. What is a process? How is it different from a program?
#      - Program = a file on disk (like /usr/bin/ls)
#      - Process = a running instance of a program
#      - A program can have 0 or many processes (run `ls` twice = 2 processes)
#      - Process has: PID, memory space, file descriptor table, env vars
#
#   4. What are file descriptors 0, 1, 2?
#      - fd 0 = stdin  (where the process reads input from)
#      - fd 1 = stdout (where the process writes normal output)
#      - fd 2 = stderr (where the process writes error messages)
#      - They're just integers that index into the process's open file table
#
#   5. What does | (pipe) actually do at the OS level?
#      - Creates a pipe (a kernel buffer connecting two file descriptors)
#      - Left process: stdout (fd 1) → write end of pipe
#      - Right process: stdin (fd 0) → read end of pipe
#      - Data flows through kernel memory, never hits disk
#
# =============================================================================

set -e

echo "============================================"
echo "  Level 0.1 — Shell Exercises"
echo "============================================"
echo ""

# --- Exercise 1: What is YOUR shell? ---
echo ">>> Exercise 1: Your shell"
echo "  Your shell is: $SHELL"
echo "  Your shell PID is: $$"
echo "  Your shell's parent PID is: $PPID"
echo "  All running shells:"
ps -eo pid,ppid,comm | grep -E 'bash|zsh|fish|sh' | head -5
echo ""

# --- Exercise 2: Trace a command with strace ---
echo ">>> Exercise 2: Tracing 'ls' with strace"
echo "  Watch the fork/exec/wait cycle:"
echo "  (Only showing process-related syscalls)"
echo ""
strace -f -e trace=process ls /tmp 2>&1 | head -20
echo ""
echo "  KEY INSIGHT: See 'execve' and 'clone'? That's fork+exec happening!"
echo ""

# --- Exercise 3: File descriptors ---
echo ">>> Exercise 3: Your shell's file descriptors"
echo "  These are the open files for THIS shell process (PID $$):"
ls -la /proc/$$/fd 2>/dev/null || echo "  (/proc not available — try on native Linux)"
echo ""
echo "  fd 0 = stdin, fd 1 = stdout, fd 2 = stderr"
echo "  Any fd > 2 are files/sockets the shell opened"
echo ""

# --- Exercise 4: Pipes create TWO processes ---
echo ">>> Exercise 4: Pipes"
echo "  Running: echo hello | cat"
echo "  This creates TWO processes connected by a pipe."
echo "  The output is:"
echo "hello" | cat
echo ""
echo "  To PROVE two processes exist, run this in another terminal:"
echo "    sleep 10 | sleep 10 &"
echo "    ps aux | grep sleep"
echo "  You'll see TWO sleep processes with different PIDs."
echo ""

# --- Exercise 5: Redirect stdout and stderr separately ---
echo ">>> Exercise 5: Redirecting stdout vs stderr"
echo "  Running: ls /tmp /nonexistent_dir"
echo "  stdout (normal output) goes to /tmp/layer0_stdout.txt"
echo "  stderr (error output) goes to /tmp/layer0_stderr.txt"
ls /tmp /nonexistent_dir_12345 1>/tmp/layer0_stdout.txt 2>/tmp/layer0_stderr.txt
echo ""
echo "  Contents of stdout file (first 3 lines):"
head -3 /tmp/layer0_stdout.txt
echo "  ..."
echo ""
echo "  Contents of stderr file:"
cat /tmp/layer0_stderr.txt
echo ""

# --- Exercise 6: Background processes ---
echo ">>> Exercise 6: Background processes"
echo "  Starting: sleep 5 &"
sleep 5 &
SLEEP_PID=$!
echo "  Sleep PID: $SLEEP_PID"
echo "  Jobs:"
jobs
echo ""
echo "  Process info:"
ps -p $SLEEP_PID -o pid,ppid,state,cmd 2>/dev/null || true
echo ""
echo "  Killing it..."
kill $SLEEP_PID 2>/dev/null || true
echo "  Done."
echo ""

# --- Exercise 7: Environment variables ---
echo ">>> Exercise 7: Environment variables"
echo "  PATH tells the shell WHERE to find commands:"
echo "  PATH=$PATH" | tr ':' '\n' | head -5
echo "  ..."
echo ""
echo "  HOME=$HOME"
echo "  USER=$USER"
echo "  LANG=$LANG"
echo ""
echo "  To see ALL env vars: run 'env' or 'printenv'"
echo ""

echo "============================================"
echo "  BREAK IT — Try these yourself:"
echo "============================================"
echo ""
echo "  1. exec ls"
echo "     → Your shell REPLACES itself with ls."
echo "     → ls runs, prints output, exits."
echo "     → Your terminal closes because the shell is gone!"
echo "     → (Try in a NEW terminal so you don't lose your session)"
echo ""
echo "  2. exec 1>&-"
echo "     → Closes stdout. After this, echo prints nothing."
echo "     → (Try in a NEW terminal!)"
echo ""
echo "  3. (ls; echo 'done') vs { ls; echo 'done'; }"
echo "     → () runs in a SUBSHELL (new process)"
echo "     → {} runs in the CURRENT shell"
echo "     → Prove it: (echo \$\$) vs { echo \$\$; }"
echo ""
echo "============================================"
echo "  ✅ Level 0.1 Complete"
echo "  Next: Run 02_files_permissions.sh"
echo "============================================"
