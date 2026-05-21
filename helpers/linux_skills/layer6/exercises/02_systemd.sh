#!/bin/bash
# =============================================================================
# Layer 6, Exercise 2: SYSTEMD — The Init System
# =============================================================================
# THEORY-IN-ACTION: systemd starts your Linux system, manages all services
# (SSH, web servers, databases), handles logging, and much more. It's the
# most important system component after the kernel. Love it or hate it,
# you need to understand it.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 2: systemd — Managing Services and the Boot Process"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: SERVICE MANAGEMENT ────

    # List services:
    systemctl list-units --type=service              # Active services
    systemctl list-units --type=service --state=running  # Only running
    systemctl list-unit-files --type=service         # All services (enabled/disabled)

    # Service status (the most common command):
    systemctl status sshd                            # SSH server status
    systemctl status cron                            # Cron scheduler
    systemctl status systemd-resolved                # DNS resolver

    # What status shows:
    # ● sshd.service - OpenSSH server daemon
    #    Loaded: loaded (/lib/systemd/system/sshd.service; enabled)
    #    Active: active (running) since Mon 2025-03-15 10:00:00 IST
    #    Main PID: 1234 (sshd)
    #    Tasks: 1
    #    Memory: 3.2M
    #    CGroup: /system.slice/sshd.service
    #            └─1234 sshd: /usr/sbin/sshd -D

    # Start/stop/restart:
    # sudo systemctl start nginx
    # sudo systemctl stop nginx
    # sudo systemctl restart nginx     # Stop + start
    # sudo systemctl reload nginx      # Reload config without restart

    # Enable/disable (start on boot):
    # sudo systemctl enable nginx      # Start on boot
    # sudo systemctl disable nginx     # Don't start on boot
    # sudo systemctl enable --now nginx # Enable AND start immediately

    # Check if service is active:
    systemctl is-active sshd            # Outputs "active" or "inactive"
    systemctl is-enabled sshd           # Outputs "enabled" or "disabled"

EXPERIMENT:
    # Find failed services (common after updates):
    systemctl --failed
    # If any are failed: systemctl status <name> to see why

    # See the dependency tree:
    systemctl list-dependencies sshd.service

    # What started during boot?
    systemd-analyze                     # Total boot time
    systemd-analyze blame | head -10   # Slowest services
    systemd-analyze critical-chain     # Critical path

KEY INSIGHT: systemctl is your one command for all service management.
status = diagnose, start/stop = control, enable/disable = boot behavior.
When something "isn't working," check `systemctl status <service>` first.

──── PART 2: JOURNALCTL — READING LOGS ────

    # systemd collects ALL logs via journald:
    journalctl                          # ALL logs (press q to quit)
    journalctl -b                       # Logs from current boot only
    journalctl -b -1                    # Logs from previous boot

    # Filter by service:
    journalctl -u sshd                  # SSH logs
    journalctl -u cron                  # Cron logs
    journalctl -u nginx                 # Nginx logs (if installed)

    # Filter by time:
    journalctl --since "1 hour ago"
    journalctl --since "2025-03-15" --until "2025-03-16"
    journalctl --since today

    # Filter by priority:
    journalctl -p err                   # Only errors and above
    journalctl -p warning -b            # Warnings+ this boot
    # Priorities: emerg, alert, crit, err, warning, notice, info, debug

    # Follow (like tail -f):
    journalctl -f                       # Live log stream
    journalctl -fu sshd                 # Live SSH logs only

    # Output format:
    journalctl -u sshd -o json-pretty | head -30  # JSON format
    journalctl -u sshd --no-pager | tail -20       # Don't page

    # Disk usage:
    journalctl --disk-usage             # How much space logs use
    sudo journalctl --vacuum-time=7d    # Delete logs older than 7 days
    sudo journalctl --vacuum-size=100M  # Keep only 100MB of logs

EXPERIMENT:
    # What happened when the system last booted?
    journalctl -b --no-pager | head -50

    # Find errors in the last hour:
    journalctl -p err --since "1 hour ago"

    # Log something yourself:
    logger "Test message from Nithin"
    journalctl --since "1 minute ago" | grep "Nithin"

    # Kernel messages:
    journalctl -k                       # Same as dmesg
    dmesg | tail -20                    # Direct kernel ring buffer

KEY INSIGHT: journalctl replaces all the old /var/log/* files.
One command searches ALL logs. Filter by service (-u), priority (-p),
time (--since), or boot (-b). This is your FIRST stop when debugging.

──── PART 3: WRITING A SYSTEMD SERVICE ────

    # Create your own service:
    cat > /tmp/myservice.py << 'PYTHON'
#!/usr/bin/env python3
"""A simple service that logs every 5 seconds."""
import time, sys

print("MyService starting...", flush=True)
counter = 0
while True:
    counter += 1
    print(f"MyService heartbeat #{counter}", flush=True)
    time.sleep(5)
PYTHON
    chmod +x /tmp/myservice.py

    # The unit file:
    cat << 'UNIT'
# Save this as: /etc/systemd/system/myservice.service
[Unit]
Description=My Custom Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /tmp/myservice.py
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
UNIT

    # To actually install it (informational — requires sudo):
    # sudo cp myservice.service /etc/systemd/system/
    # sudo systemctl daemon-reload
    # sudo systemctl start myservice
    # sudo systemctl status myservice
    # journalctl -u myservice -f
    # sudo systemctl stop myservice
    # sudo systemctl disable myservice
    # sudo rm /etc/systemd/system/myservice.service

    # Unit file sections explained:
    # [Unit]    = metadata, dependencies, ordering
    # [Service] = how to run it (Type, ExecStart, Restart policy)
    # [Install] = what "target" enables it (multi-user.target = normal boot)

    # Restart policies:
    # no            = never restart
    # on-failure    = restart only if non-zero exit
    # always        = always restart (good for servers)
    # on-abnormal   = restart on signal/timeout (not clean exit)

EXPERIMENT:
    # Common service patterns:
    # 1. One-shot (run once):
    # Type=oneshot
    # ExecStart=/usr/local/bin/cleanup.sh

    # 2. Forking daemon (old-style):
    # Type=forking
    # PIDFile=/var/run/mydaemon.pid

    # 3. Timer (instead of cron):
    # myservice.timer file that triggers myservice.service

    # List all timers:
    systemctl list-timers

KEY INSIGHT: systemd services are declared in .service files with three sections.
Type=simple for modern programs (stay in foreground).
Restart=on-failure for resilient services.
journalctl -u name shows its logs. This is how ALL production services run.

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can manage services and read system logs."
echo "  Next: 03_users_and_security.sh"
echo "═══════════════════════════════════════════════════════════════"
