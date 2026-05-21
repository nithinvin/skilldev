#!/bin/bash
# =============================================================================
# Layer 1, Exercise 1: FILESYSTEM TOUR
# =============================================================================
# THEORY-IN-ACTION: Linux has a single filesystem tree rooted at /. Every
# directory at the top level has a specific purpose. Understanding the layout
# means you always know WHERE to look for things.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 1: The Filesystem Tour — Every Directory Has a Purpose"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: The Root Directory
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: THE / (ROOT) ────

    ls /                        # Everything starts here
    tree -L 1 /                 # Visual layout

The top-level directories follow the Filesystem Hierarchy Standard (FHS):

    /bin        → Essential user commands (ls, cp, cat) — needed for boot
    /sbin       → System admin commands (fdisk, iptables) — usually need root
    /etc        → Configuration files (text files you edit to configure the system)
    /home       → User home directories (/home/nithin)
    /root       → Root user's home directory (separate from /home)
    /tmp        → Temporary files (cleared on reboot)
    /var        → Variable data (logs, databases, mail, cache)
    /usr        → User programs and data (the BIG one)
    /opt        → Optional/third-party software (Chrome, VS Code, etc.)
    /dev        → Device files (disks, terminals, random)
    /proc       → Virtual filesystem — live kernel/process info
    /sys        → Virtual filesystem — hardware/driver info
    /lib        → Shared libraries (like DLLs on Windows)
    /mnt        → Mount point for temporary mounts
    /media      → Mount point for removable media (USB, CD)
    /boot       → Kernel and bootloader files
    /srv        → Data for services (web server files, FTP, etc.)

RUN:
    # See how big each one is:
    du -sh /* 2>/dev/null | sort -rh | head -10

    # Which ones are real directories and which are special?
    mount | grep -E "^(proc|sys|dev)"   # These aren't on disk!

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: /etc — Configuration
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: /etc — THE BRAIN OF THE SYSTEM ────

Everything configurable lives here as plain text files:

    ls /etc/*.conf | head -10           # Config files
    cat /etc/hostname                   # Your machine's name
    cat /etc/os-release                 # Which Linux distribution
    cat /etc/passwd                     # User accounts (NOT passwords!)
    cat /etc/group                      # Group definitions
    cat /etc/shells                     # Available shells
    cat /etc/resolv.conf                # DNS servers
    cat /etc/hosts                      # Local DNS overrides

    # Subdirectories for services:
    ls /etc/apt/                        # Package manager config
    ls /etc/ssh/                        # SSH config
    ls /etc/systemd/                    # Service management

EXPERIMENT:
    # What user accounts exist?
    cat /etc/passwd | cut -d: -f1,7 | column -t -s:
    # Fields: username:password:uid:gid:comment:home:shell
    # Notice: most are system accounts (shell = /usr/sbin/nologin)

    # How many have a real login shell?
    grep -v "nologin\|false" /etc/passwd | cut -d: -f1

KEY INSIGHT: Linux is configured by TEXT FILES. No registry, no binary blobs.
If something is misconfigured, you edit a file in /etc. That's it.
This is why Linux is easier to automate than Windows.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: /proc — The Kernel's Window
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: /proc — LIVE SYSTEM INFORMATION ────

/proc is NOT on disk. The kernel creates it on-the-fly when you read it.

    ls /proc                            # Numbers = process PIDs!
    cat /proc/cpuinfo                   # CPU details
    cat /proc/meminfo                   # Memory details
    cat /proc/version                   # Kernel version
    cat /proc/uptime                    # Seconds since boot
    cat /proc/loadavg                   # Load average

    # Per-process info (replace $$ with any PID):
    echo "My shell PID: $$"
    ls /proc/$$/                        # Your shell's proc entry
    cat /proc/$$/status                 # Process status
    cat /proc/$$/cmdline | tr '\0' ' '  # Command that started it
    ls -la /proc/$$/fd                  # Open file descriptors
    cat /proc/$$/maps | head -10        # Memory map

EXPERIMENT:
    # Start a background process and explore its /proc entry:
    sleep 300 &
    SLEEP_PID=$!
    echo "Sleep PID: $SLEEP_PID"

    cat /proc/$SLEEP_PID/status
    cat /proc/$SLEEP_PID/cmdline | tr '\0' ' '
    ls -la /proc/$SLEEP_PID/fd

    kill $SLEEP_PID
    ls /proc/$SLEEP_PID 2>/dev/null && echo "Still there" || echo "Gone!"

KEY INSIGHT: /proc is how tools like `ps`, `top`, `free` get their data.
They just read from /proc and format it nicely. You can read the raw data
yourself!

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: /dev — Devices As Files
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: /dev — EVERYTHING IS A FILE (LITERALLY) ────

    ls /dev | head -30                  # Lots of devices!

    # Character devices (streams of bytes):
    ls -la /dev/null                    # Black hole
    ls -la /dev/zero                    # Infinite zeros
    ls -la /dev/urandom                 # Random bytes
    ls -la /dev/tty                     # Your terminal

    # Block devices (disks, partitions):
    ls -la /dev/sd*  2>/dev/null        # SCSI/SATA disks
    ls -la /dev/nvme* 2>/dev/null       # NVMe SSDs
    ls -la /dev/loop* | head -5         # Loop devices (file as disk)

    # Pseudo-terminals:
    ls /dev/pts/                        # Each open terminal gets one
    tty                                 # Which terminal are YOU using?

EXPERIMENT:
    # Write directly to your terminal:
    MY_TTY=$(tty)
    echo "Hello from echo!" > $MY_TTY

    # Talk to /dev/null:
    echo "Can you hear me?" > /dev/null
    cat /dev/null                       # Silence

    # Get random data:
    od -A x -t x1z /dev/urandom | head -3  # Random hex

    # What's the difference between /dev/random and /dev/urandom?
    # /dev/random blocks when entropy pool is low (old behavior)
    # /dev/urandom never blocks (use this for crypto in modern Linux)

KEY INSIGHT: In Linux, hardware devices are accessed through files in /dev.
Read from /dev/sda? You're reading raw disk bytes.
Write to /dev/null? Data disappears.
This uniformity is the "everything is a file" philosophy.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 5: /var — Variable/Runtime Data
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 5: /var — WHERE STUFF ACCUMULATES ────

    ls /var
    # Key subdirectories:
    # /var/log    — System and application logs
    # /var/cache  — Package manager cache, etc.
    # /var/tmp    — Temp files that survive reboot
    # /var/lib    — Application state (databases, docker images)
    # /var/spool  — Queues (print jobs, cron jobs, mail)
    # /var/run    — PID files, sockets (symlink to /run)

    # Explore logs:
    ls /var/log/
    sudo tail -20 /var/log/syslog 2>/dev/null || sudo journalctl --no-pager | tail -20
    sudo tail -20 /var/log/auth.log 2>/dev/null     # Login attempts

    # How much space do logs take?
    du -sh /var/log

    # Package cache:
    du -sh /var/cache/apt 2>/dev/null   # Downloaded .deb packages

EXPERIMENT:
    # Watch logs in real-time:
    sudo tail -f /var/log/syslog &      # Runs in background
    logger "Hello from my experiment"    # Write to syslog
    # You should see your message appear!
    kill %1                             # Stop the tail

    # /tmp vs /var/tmp:
    ls -la /tmp
    ls -la /var/tmp
    # /tmp is cleared on reboot
    # /var/tmp is for temp files that should survive reboot

KEY INSIGHT: /var is where your system "lives" — it grows over time.
If your disk fills up, check /var/log and /var/cache first.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # How much of /proc is "real" data?
       du -sh /proc 2>/dev/null         # What do you get?
       # /proc files report 0 size but contain data when you read them!
       wc -c /proc/cpuinfo             # Non-zero!

    2. # What happens if you write to /proc?
       echo "hello" > /proc/version     # Permission denied (read-only)
       # Some /proc entries ARE writable (kernel tuning):
       cat /proc/sys/net/ipv4/ip_forward    # 0 or 1

    3. # Explore a mystery device:
       cat /dev/stdin <<< "I'm reading my own stdin!"
       # /dev/stdin is a symlink to your terminal's input

    4. # Find the biggest things in /var:
       sudo du -sh /var/* 2>/dev/null | sort -rh

    5. # What filesystem type is /proc?
       mount | grep proc
       df -T /proc                      # Type: proc (virtual!)

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You know what's in every corner of the filesystem."
echo "  Next: 02_file_operations.sh"
echo "═══════════════════════════════════════════════════════════════"
