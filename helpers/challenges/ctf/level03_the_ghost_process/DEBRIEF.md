# DEBRIEF: The Ghost Process

## Solution Path

### 1. Find the ghost
```bash
# The ghost disguised itself as [kworker/u8:2] — looks like a kernel thread!
# But real kernel threads have PID parents of 2 (kthreadd)
ps aux | grep python3     # Reveals python3 running something
# OR
ps -ef --forest           # Shows process tree — ghost has YOUR shell as parent
# OR
ps aux | grep -v "^\[" | grep kworker  # Real kworkers don't run as your user
```

**Key insight:** The process RENAMED itself, but it's still running as YOUR user.
Real kernel threads run as root. The user column gives it away.

### 2. Find what it's writing
```bash
# Method 1: lsof (list open files)
lsof -p <PID>            # Shows all files the process has open

# Method 2: /proc filesystem
ls /proc/<PID>/fd/       # File descriptors
cat /proc/<PID>/fd/3     # Usually fd 3 is the first non-standard file

# Method 3: find the temp file
find /tmp -name ".ghost_*" -newer /tmp 2>/dev/null
ls -la /tmp/.ghost_*
```

### 3. Read the flag
```bash
cat /tmp/.ghost_<random>.tmp
# FLAG{proc_filesystem_reveals_all_secrets}
```

### 4. Kill it
```bash
kill -15 <PID>           # SIGTERM — clean shutdown
# OR
kill -SIGTERM <PID>      # Same thing, human-readable

# Verify it's dead:
ps -p <PID>              # Should show nothing
ls /tmp/.ghost_*         # File should be gone (cleanup handler ran)
```

## Mental Model

```
Process Hunting Toolkit:
├── ps aux                    — list all processes (user, PID, command)
├── ps -ef --forest           — show parent-child tree
├── /proc/<PID>/              — everything about a process
│   ├── cmdline               — original command that started it
│   ├── comm                  — current process name (can be faked!)
│   ├── exe                   — symlink to actual binary (HARD TO FAKE)
│   ├── fd/                   — all open file descriptors
│   ├── environ               — environment variables
│   └── status                — UID, GID, memory usage
├── lsof -p <PID>            — open files, network connections
├── strace -p <PID>          — trace system calls in real-time
└── kill -<signal> <PID>     — send signal to process

Signals:
  SIGTERM (15) = "please exit cleanly" (can be caught/handled)
  SIGKILL (9)  = "die immediately" (CANNOT be caught — last resort)
  SIGSTOP (19) = "freeze" (pause execution)
  SIGCONT (18) = "resume" (unpause)
```

## Key Lessons

1. **Process names can lie.** Always verify with `/proc/PID/exe` or the user column.
2. **The /proc filesystem is X-ray vision** — it reveals everything about running processes.
3. **SIGTERM before SIGKILL** — always try polite shutdown first (allows cleanup).
4. **Temp files are ephemeral** — if you need data from a running process, get it NOW.
5. **Real kernel threads (kworker, ksoftirqd)** have PPID 2 and run as root.

## Real-World Application
- Detecting malware that disguises itself as system processes
- Debugging server issues (which process has that port? lsof -i :8080)
- Finding resource hogs (top, htop, ps aux --sort=-%mem)
- Container processes visible in host /proc (container escape detection)
