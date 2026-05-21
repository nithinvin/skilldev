#!/bin/bash
# =============================================================================
# Layer 7, Exercise 1: /proc — THE PROCESS FILESYSTEM
# =============================================================================
# THEORY-IN-ACTION: /proc is a virtual filesystem that exposes kernel data
# structures as files. Every running process gets a directory. Every piece of
# system info is a file. It's not on disk — it's generated live by the kernel.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 1: /proc — Reading the Kernel's Mind"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: SYSTEM INFORMATION IN /proc ────

    # /proc = window into the kernel's brain
    ls /proc | head -30                 # Numbers = PIDs, files = system info

    # CPU info:
    cat /proc/cpuinfo | head -30        # CPU model, cores, cache
    grep -c "processor" /proc/cpuinfo   # Number of logical CPUs
    grep "model name" /proc/cpuinfo | head -1

    # Memory:
    cat /proc/meminfo | head -10        # Total, free, available, buffers, cached
    grep MemTotal /proc/meminfo         # Total RAM
    grep MemAvailable /proc/meminfo     # Actually usable RAM

    # Kernel version:
    cat /proc/version                   # Full kernel version string
    uname -r                            # Short version (reads from /proc)

    # Uptime:
    cat /proc/uptime                    # seconds_up idle_seconds
    uptime                              # Human-readable (reads /proc/uptime)

    # Load average:
    cat /proc/loadavg                   # 1min 5min 15min running/total last_pid
    # Load > number of CPUs = system is overloaded

    # Filesystem info:
    cat /proc/mounts | head -10         # All mounted filesystems
    cat /proc/filesystems               # Supported filesystem types
    cat /proc/partitions                # Disk partitions

    # Network:
    cat /proc/net/dev                   # Network interface stats
    cat /proc/net/tcp | head -5         # Raw TCP connections (hex!)

EXPERIMENT:
    # Kernel parameters (live-tunable):
    ls /proc/sys/                       # Categories
    cat /proc/sys/kernel/hostname       # Your hostname (writable with sudo!)
    cat /proc/sys/net/ipv4/ip_forward   # IP forwarding enabled? (0 or 1)
    cat /proc/sys/vm/swappiness         # How aggressively to swap (0-100)

    # Change a kernel parameter at runtime:
    # sudo sysctl vm.swappiness=10      # Reduce swapping
    # sudo sysctl net.ipv4.ip_forward=1 # Enable routing

    # All kernel parameters:
    sysctl -a 2>/dev/null | wc -l      # Hundreds of tunable knobs!

KEY INSIGHT: /proc is not a real filesystem — it's a kernel API disguised
as files. Reading /proc/meminfo = asking the kernel "how much RAM is used?"
Every monitoring tool (top, htop, free) just reads /proc under the hood.

──── PART 2: PROCESS DIRECTORIES ────

    # Every process gets /proc/PID/:
    ls /proc/$$                         # $$ = current shell's PID
    # Or pick any PID:
    PID=1                               # init/systemd
    ls /proc/$PID/ 2>/dev/null || PID=$$; ls /proc/$PID/

    # Critical files per process:
    cat /proc/$$/status                 # Human-readable process info
    cat /proc/$$/cmdline | tr '\0' ' '; echo   # Command that started it
    readlink /proc/$$/exe               # Actual binary being run
    cat /proc/$$/environ | tr '\0' '\n' | head -10  # Environment variables
    ls -la /proc/$$/fd/                 # Open file descriptors!
    cat /proc/$$/maps | head -20        # Memory mappings (loaded libraries)

    # Process status fields:
    grep "Name\|State\|Pid\|PPid\|Threads\|VmRSS\|VmSize" /proc/$$/status

    # VmSize = virtual memory (address space reserved)
    # VmRSS  = resident set size (actual physical RAM used!)
    # This is the TRUE memory usage (not what ps shows)

    # Open file descriptors:
    ls -la /proc/$$/fd/
    # 0 → /dev/pts/0     stdin (terminal)
    # 1 → /dev/pts/0     stdout (terminal)
    # 2 → /dev/pts/0     stderr (terminal)
    # Higher numbers = opened files, sockets, pipes

    # How many files does a process have open?
    ls /proc/$$/fd/ | wc -l
    cat /proc/sys/fs/file-max           # System-wide limit

EXPERIMENT:
    # Watch a process in real-time:
    # Start a background process:
    sleep 300 &
    BGPID=$!
    echo "Background PID: $BGPID"

    cat /proc/$BGPID/status | grep -E "Name|State|VmRSS"
    readlink /proc/$BGPID/exe          # /usr/bin/sleep
    cat /proc/$BGPID/cmdline | tr '\0' ' '; echo  # sleep 300

    kill $BGPID
    ls /proc/$BGPID 2>/dev/null && echo "Still alive" || echo "Gone!"

    # Find all PIDs running a specific program:
    for pid in /proc/[0-9]*/exe; do
        readlink "$pid" 2>/dev/null
    done | sort | uniq -c | sort -rn | head -10

KEY INSIGHT: /proc/PID/ is THE definitive source for process info.
ps, top, htop all just read these files and format them nicely.
/proc/PID/fd shows open files — critical for debugging "too many open files."

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can read process internals via /proc."
echo "  Next: 02_strace.sh"
echo "═══════════════════════════════════════════════════════════════"
