#!/bin/bash
# =============================================================================
# Layer 7, Exercise 3: MEMORY AND PERFORMANCE
# =============================================================================
# THEORY-IN-ACTION: Your system's performance comes down to four resources:
# CPU, memory, disk I/O, and network I/O. Understanding how Linux manages
# memory and how to measure performance = understanding why things are slow.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 3: Memory & Performance — Why Is It Slow?"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: MEMORY — HOW LINUX USES RAM ────

    # Memory overview:
    free -h                             # Human-readable memory summary
    # Output:
    #        total   used   free   shared  buff/cache  available
    # Mem:    16G    4.2G   8.1G   200M      3.7G       11G
    # Swap:   2G      0B    2G

    # KEY CONCEPT: "free" is misleading!
    # Linux uses "unused" RAM for disk cache (buff/cache)
    # "available" = what programs CAN use (free + reclaimable cache)
    # Low "free" is NORMAL. Low "available" is a problem.

    # Detailed view:
    cat /proc/meminfo | head -20
    # MemTotal:     Total physical RAM
    # MemFree:      Completely unused (often low — that's OK!)
    # MemAvailable: Actually usable for new programs
    # Buffers:      Filesystem metadata cache
    # Cached:       File content cache (speeds up disk reads)
    # SwapTotal:    Swap space available
    # SwapFree:     Unused swap

    # Swap — when RAM overflows:
    swapon --show                       # Active swap devices
    cat /proc/swaps
    # Swap = slow (disk-backed memory). If swap is heavily used = need more RAM.
    vmstat 1 5                          # 5 samples, 1 sec apart
    # si/so columns = swap in/swap out (should be near 0!)

    # Per-process memory:
    ps aux --sort=-rss | head -10       # Top memory consumers
    # RSS = Resident Set Size (physical RAM actually used)
    # VSZ = Virtual Size (address space, includes shared libs)

    # More accurate per-process:
    # smem (if installed) shows PSS = Proportional Set Size
    # (accounts for shared memory properly)

EXPERIMENT:
    # Watch memory in real-time:
    watch -n 1 free -h                  # Ctrl+C to stop

    # What's in the disk cache?
    # Every file you read stays in cache until RAM is needed
    # That's why second reads are fast:
    time cat /etc/services > /dev/null  # First: reads from disk
    time cat /etc/services > /dev/null  # Second: from cache (faster!)

    # Clear caches (DON'T do this on production!):
    # sync; sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
    # free -h  # Now "free" is higher, but system is slower!

    # OOM killer — what happens when RAM runs out:
    # The kernel's Out-Of-Memory killer picks a process to kill
    # Check if anything was OOM-killed:
    dmesg | grep -i "oom\|out of memory" | tail -5 2>/dev/null || \
    journalctl -k | grep -i "oom\|out of memory" | tail -5

KEY INSIGHT: Linux memory management philosophy: unused RAM is wasted RAM.
The kernel caches everything in "free" RAM to speed up future disk reads.
"available" is the TRUE free memory. Swap usage = you need more RAM.

──── PART 2: CPU AND SYSTEM PERFORMANCE ────

    # CPU utilization:
    top -bn1 | head -5                  # Snapshot
    # %us = user space, %sy = kernel, %id = idle, %wa = waiting for disk
    # High %wa = disk is the bottleneck
    # High %sy = lots of syscalls (context switches, I/O)
    # High %us = programs using CPU (normal for compute tasks)

    # Load average explained:
    uptime
    cat /proc/loadavg
    # Three numbers: 1min, 5min, 15min averages
    # Load = number of processes wanting to run
    # Load < num_CPUs = system is fine
    # Load > num_CPUs = processes are waiting (overloaded)
    CPUS=$(nproc)
    LOAD=$(cat /proc/loadavg | awk '{print $1}')
    echo "CPUs: $CPUS, Load: $LOAD"

    # mpstat (per-CPU breakdown):
    mpstat 1 3 2>/dev/null || echo "Install: sudo apt install sysstat"

    # vmstat (virtual memory statistics):
    vmstat 1 5
    # r  = processes waiting for CPU
    # b  = processes in uninterruptible sleep (usually I/O)
    # si/so = swap in/out (should be 0)
    # bi/bo = block I/O (disk reads/writes)
    # cs = context switches per second

    # iostat (disk performance):
    iostat -x 1 3 2>/dev/null || echo "Install: sudo apt install sysstat"
    # %util = how busy the disk is (100% = saturated)
    # await = average I/O wait time (high = slow disk)

EXPERIMENT:
    # Create CPU load and observe:
    stress --cpu 2 --timeout 5 2>/dev/null || \
    (yes > /dev/null & YES_PID=$!; sleep 3; kill $YES_PID)
    # In another terminal: top or vmstat 1

    # Measure a command's resource usage:
    /usr/bin/time -v ls /tmp 2>&1 | grep -E "Maximum resident|wall clock|CPU"
    # Shows: wall time, CPU time, max memory used

    # Context switches (expensive!):
    grep "ctxt" /proc/stat              # Total context switches since boot
    cat /proc/$$/status | grep "ctxt"   # Per-process

KEY INSIGHT: The performance triad:
- High load + high %us = CPU-bound (need faster CPU or optimize code)
- High load + high %wa = I/O-bound (need faster disk or reduce I/O)
- Low available memory + swap in use = memory-bound (need more RAM)

──── PART 3: PRACTICAL PERFORMANCE DEBUGGING ────

    # The performance investigation checklist:
    # 1. Is it CPU?
    top -bn1 | head -5                  # Check load and %idle
    # 2. Is it memory?
    free -h                             # Check available and swap
    # 3. Is it disk?
    iostat -x 1 3 2>/dev/null | tail -5 # Check %util and await
    # 4. Is it network?
    ss -s                               # Connection count
    cat /proc/net/dev                   # Errors and drops?

    # Find the resource hog:
    # CPU hog:
    ps aux --sort=-%cpu | head -5
    # Memory hog:
    ps aux --sort=-rss | head -5
    # I/O hog:
    sudo iotop -bon1 2>/dev/null | head -10 || echo "Install: sudo apt install iotop"

    # Process-specific resource limits:
    ulimit -a                           # Your current limits
    # Important limits:
    # open files (-n): often 1024, raise for servers!
    # max user processes (-u): process limit
    # virtual memory (-v): memory limit

    # Quick benchmarking:
    # Disk speed:
    dd if=/dev/zero of=/tmp/test bs=1M count=100 oflag=direct 2>&1 | tail -1
    rm /tmp/test
    # Network speed:
    curl -o /dev/null -w "Speed: %{speed_download}\n" https://speed.hetzner.de/1MB.bin

EXPERIMENT:
    # Find what's using the most I/O:
    cat /proc/diskstats | head -10      # Raw disk stats

    # Check for memory leaks (growing RSS over time):
    PID=$$
    for i in 1 2 3; do
        grep VmRSS /proc/$PID/status
        sleep 1
    done

    # System-wide resource snapshot:
    echo "=== CPU ===" && uptime
    echo "=== MEM ===" && free -h | grep Mem
    echo "=== DISK ===" && df -h / | tail -1
    echo "=== LOAD ===" && cat /proc/loadavg

KEY INSIGHT: Performance debugging is elimination:
Is it CPU? Memory? Disk? Network? Use the checklist approach.
90% of "it's slow" problems are one of these four bottlenecks.
The tools exist to pinpoint EXACTLY which one.

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can diagnose and debug performance problems."
echo "  Layer 7 complete!"
echo "═══════════════════════════════════════════════════════════════"
