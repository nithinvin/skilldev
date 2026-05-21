#!/bin/bash
# =============================================================================
# Layer 3, Exercise 4: SYSTEM MONITORING
# =============================================================================
# THEORY-IN-ACTION: When something is slow or broken, you need to diagnose
# the bottleneck. Is it CPU? Memory? Disk? Network? These tools tell you.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 4: Monitoring — Diagnose What's Slow or Broken"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: CPU and Load
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: CPU USAGE AND LOAD AVERAGE ────

    # Load average — the #1 health indicator:
    uptime
    cat /proc/loadavg
    # Output: 0.52 0.48 0.41 1/234 5678
    #         1min 5min 15min  running/total  last_pid

    # Interpreting load average:
    # load = average number of processes in runnable state
    # If you have N CPU cores:
    #   load < N  = system has spare capacity
    #   load = N  = fully utilized
    #   load > N  = overloaded (processes waiting for CPU)

    nproc                       # How many CPU cores?
    # If nproc=4 and load=2.0 → 50% utilized
    # If nproc=4 and load=8.0 → overloaded! (4 processes always waiting)

    # CPU info:
    lscpu                       # Architecture, cores, threads, cache
    cat /proc/cpuinfo | grep "model name" | uniq
    cat /proc/cpuinfo | grep "^processor" | wc -l  # Core count

    # Per-CPU usage:
    mpstat 1 5                  # Per-CPU stats every 1 sec, 5 times (install: sysstat)
    # OR: top → press 1 to see individual cores

EXPERIMENT:
    # Generate CPU load and watch:
    # Terminal 1: watch -n 1 uptime
    # Terminal 2:
    stress --cpu 2 --timeout 10 2>/dev/null || \
        (for i in 1 2; do yes > /dev/null & done; sleep 10; killall yes)
    # Watch load average climb!

KEY INSIGHT: Load average tells you if your system needs more CPU.
Rising load + low %wa (I/O wait) = CPU-bound.
Rising load + high %wa = I/O-bound (disk is slow).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Memory
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: MEMORY USAGE ────

    # Overview:
    free -h                     # Human-readable memory summary
    # Key lines:
    #              total    used    free   shared  buff/cache   available
    # Mem:          16G     4G      2G     500M      10G         11G
    #
    # "available" is what matters — that's what NEW programs can use
    # "buff/cache" is memory used for disk cache — released when needed

    # Detailed:
    cat /proc/meminfo | head -20

    # Per-process memory:
    ps aux --sort=-%mem | head -10      # Top memory consumers
    smem -tk 2>/dev/null || echo "install: sudo apt install smem"

    # Watch memory over time:
    vmstat 1 10                 # 1-second intervals, 10 samples
    # Columns: r (runnable), b (blocked), swpd (swap used),
    #          free, buff, cache, si/so (swap in/out)

    # Swap usage:
    swapon --show               # What swap space exists
    free -h | grep Swap
    # High swap usage + si/so activity = system is thrashing (BAD)

EXPERIMENT:
    # Watch memory pressure:
    # Terminal 1: watch -n 1 free -h
    # Terminal 2:
    python3 -c "
import time
chunks = []
for i in range(50):
    chunks.append('X' * (10 * 1024 * 1024))  # 10MB per iteration
    time.sleep(0.2)
print(f'Allocated {len(chunks) * 10}MB')
time.sleep(5)
"
    # Watch 'available' drop, then recover when Python exits

KEY INSIGHT: Linux aggressively caches disk data in "free" memory.
Don't panic when "free" is low — check "available" instead.
If "available" is low AND swap is active → you need more RAM.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Disk I/O
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: DISK PERFORMANCE ────

    # Disk usage:
    df -h                       # Filesystem usage (how full are your disks?)
    df -i                       # Inode usage (can run out even with free space!)

    # Directory sizes:
    du -sh /var/log             # Single directory
    du -sh /* 2>/dev/null | sort -rh | head -10  # Biggest top-level dirs
    du -sh ~/.cache/* 2>/dev/null | sort -rh | head -5  # Your cache

    # Disk I/O stats:
    iostat -xz 1 5 2>/dev/null || echo "install: sudo apt install sysstat"
    # Key columns:
    # %util = how busy the disk is (100% = saturated)
    # await = average time for I/O request (high = slow disk)
    # r/s, w/s = reads/writes per second

    # Watch for I/O bottleneck:
    # In top: look at %wa (I/O wait)
    # If %wa is high → disk is the bottleneck

    # What's doing I/O right now:
    sudo iotop 2>/dev/null || echo "install: sudo apt install iotop"
    # Shows per-process I/O usage

EXPERIMENT:
    # Test your disk speed:
    # Write test:
    dd if=/dev/zero of=/tmp/disktest bs=1M count=100 oflag=direct 2>&1 | tail -1
    # Read test:
    dd if=/tmp/disktest of=/dev/null bs=1M 2>&1 | tail -1
    rm /tmp/disktest

    # Find what's writing to disk:
    # sudo fatrace 2>/dev/null  # Shows real-time file access events

KEY INSIGHT: Disk is usually the slowest component.
%util near 100% = disk saturated = everything is slow.
SSD vs HDD: SSD ~100x faster random I/O, ~3x faster sequential.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: watch — Keep An Eye On Things
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: watch — REPEAT A COMMAND ────

    # watch runs a command repeatedly and shows updates:
    watch -n 2 "free -h"               # Every 2 seconds (Ctrl+C to stop)
    watch -n 1 "ps aux --sort=-%cpu | head -10"  # Top CPU users, updating
    watch -d "cat /proc/loadavg"       # -d highlights what changed

    # Practical monitoring commands to watch:
    watch -n 5 "df -h"                         # Disk filling up?
    watch -n 2 "ss -s"                         # Connection statistics
    watch -n 1 "cat /proc/net/dev"             # Network traffic counters
    watch -n 3 "systemctl --failed"            # Any failed services?

    # Combine with other tools:
    watch -n 1 "uptime; echo; free -h; echo; df -h /"  # Mini dashboard!

EXPERIMENT:
    # DIY monitoring dashboard:
    watch -n 2 '
        echo "=== SYSTEM STATUS $(date +%H:%M:%S) ==="
        echo ""
        echo "Load: $(cut -d" " -f1-3 /proc/loadavg) | CPUs: $(nproc)"
        echo ""
        echo "Memory:"
        free -h | grep -E "Mem|Swap"
        echo ""
        echo "Disk:"
        df -h / | tail -1
        echo ""
        echo "Top CPU:"
        ps aux --sort=-%cpu | head -4 | tail -3 | awk "{printf \"  %-8s %5s%% %s\n\", \$1, \$3, \$11}"
    '

KEY INSIGHT: `watch` is your poor-man's monitoring dashboard.
`watch -d` highlights changes (great for spotting drift).
For real monitoring: use htop, glances, or dstat.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # What's the "OOM Killer"?
       # When memory is exhausted, the kernel picks a process to kill.
       # Score: /proc/[pid]/oom_score (higher = more likely to be killed)
       cat /proc/$$/oom_score
       cat /proc/1/oom_score    # PID 1 usually has low score (protected)
       # You can adjust: echo -1000 > /proc/$$/oom_score_adj (protect yourself)

    2. # Fill up /tmp and watch df:
       # Terminal 1: watch -n 1 "df -h /tmp"
       # Terminal 2:
       dd if=/dev/zero of=/tmp/bigfile bs=1M count=500 2>/dev/null
       rm /tmp/bigfile

    3. # What happens when all file descriptors are used?
       ulimit -n               # Max open files (probably 1024)
       # A process that opens too many files gets "Too many open files"

    4. # Load average mystery:
       # Load can be high even with low CPU usage! How?
       # D-state processes (uninterruptible sleep) count toward load.
       # Lots of D-state = lots of I/O wait = high load + idle CPU

    5. # Monitor network connections changing:
       watch -d "ss -s"        # Total connection counts
       # Open a browser → watch numbers change!

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can diagnose performance problems."
echo "  Layer 3 complete! Move to Layer 4 (Shell Scripting)."
echo "═══════════════════════════════════════════════════════════════"
