#!/bin/bash
# =============================================================================
# Layer 8, Exercise 2: CGROUPS — RESOURCE CONTROL
# =============================================================================
# THEORY-IN-ACTION: Namespaces provide ISOLATION (what you can SEE).
# Cgroups provide LIMITS (what you can USE). Together they make containers.
# Cgroups let you say "this process gets max 512MB RAM and 50% CPU."
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 2: cgroups — Limiting Resource Usage"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: UNDERSTANDING CGROUPS ────

    # cgroups v2 (modern systems):
    # A hierarchy of resource controllers
    mount | grep cgroup
    ls /sys/fs/cgroup/                  # The cgroup filesystem

    # Your shell's cgroup:
    cat /proc/$$/cgroup
    # 0::/user.slice/user-1000.slice/session-1.scope

    # Available controllers:
    cat /sys/fs/cgroup/cgroup.controllers
    # cpu cpuset io memory hugetlb pids rdma misc

    # Current resource usage of your cgroup:
    MYCGROUP=$(cat /proc/$$/cgroup | cut -d: -f3)
    echo "My cgroup: $MYCGROUP"
    cat /sys/fs/cgroup${MYCGROUP}/memory.current 2>/dev/null  # Memory in bytes
    cat /sys/fs/cgroup${MYCGROUP}/pids.current 2>/dev/null    # Number of processes

    # System-wide resource accounting:
    cat /sys/fs/cgroup/memory.stat 2>/dev/null | head -10
    cat /sys/fs/cgroup/cpu.stat 2>/dev/null

──── PART 2: CREATING RESOURCE LIMITS ────

    # Create a cgroup and limit it:
    # (Requires root and cgroups v2)

    # Step 1: Create a new cgroup:
    sudo mkdir -p /sys/fs/cgroup/demo
    # Enable controllers:
    echo "+memory +pids +cpu" | sudo tee /sys/fs/cgroup/cgroup.subtree_control > /dev/null 2>&1

    # Step 2: Set limits:
    # Memory limit: 50MB
    echo $((50 * 1024 * 1024)) | sudo tee /sys/fs/cgroup/demo/memory.max > /dev/null 2>&1
    # PID limit: max 20 processes
    echo 20 | sudo tee /sys/fs/cgroup/demo/pids.max > /dev/null 2>&1
    # CPU limit: 50% of one core (50000/100000 microseconds per period)
    echo "50000 100000" | sudo tee /sys/fs/cgroup/demo/cpu.max > /dev/null 2>&1

    # Step 3: Put a process in the cgroup:
    # echo PID | sudo tee /sys/fs/cgroup/demo/cgroup.procs

    # Step 4: Verify:
    cat /sys/fs/cgroup/demo/memory.max 2>/dev/null
    cat /sys/fs/cgroup/demo/pids.max 2>/dev/null
    cat /sys/fs/cgroup/demo/cpu.max 2>/dev/null

    # Clean up:
    sudo rmdir /sys/fs/cgroup/demo 2>/dev/null

    # Easier way with systemd-run:
    # Run a command with resource limits (no manual cgroup setup!):
    sudo systemd-run --scope -p MemoryMax=50M -p CPUQuota=50% bash -c '
        echo "Running with 50MB RAM limit and 50% CPU"
        cat /proc/self/cgroup
    ' 2>/dev/null || echo "systemd-run not available"

EXPERIMENT:
    # See Docker's cgroups (if Docker is installed):
    # docker run --rm -d --name test --memory=100m --cpus=0.5 alpine sleep 60
    # cat /sys/fs/cgroup/system.slice/docker-*/memory.max
    # docker stop test

    # OOM behavior — what happens when you exceed memory limit?
    # The process gets killed by the OOM killer!
    # In cgroups: memory.oom.group controls OOM behavior

    # Monitor cgroup resource usage:
    # cat /sys/fs/cgroup/demo/memory.current   # Current usage
    # cat /sys/fs/cgroup/demo/memory.events    # OOM events count

KEY INSIGHT: cgroups = resource LIMITS. Namespaces = resource ISOLATION.
Together: a process that can only see its own PIDs (namespace) AND
can only use 512MB RAM (cgroup) = a container.
Docker --memory=512m just sets memory.max in a cgroup.

──── PART 3: CGROUPS IN PRACTICE ────

    # systemd uses cgroups for ALL services automatically:
    systemd-cgls 2>/dev/null | head -30     # Cgroup tree
    systemd-cgtop 2>/dev/null               # Real-time resource by cgroup (like top)

    # See a service's resource usage:
    systemctl show sshd --property=MemoryCurrent 2>/dev/null
    systemctl show sshd --property=CPUUsageNSec 2>/dev/null

    # Set limits on a systemd service:
    # sudo systemctl set-property sshd MemoryMax=200M
    # Or in the unit file:
    # [Service]
    # MemoryMax=200M
    # CPUQuota=50%

    # Kubernetes/Docker limit mapping:
    # Docker --memory=512m     → memory.max = 536870912
    # Docker --cpus=1.5        → cpu.max = "150000 100000"
    # Docker --pids-limit=100  → pids.max = 100
    # K8s resources.limits.memory: 512Mi → same thing

    # How to find out what limits YOUR container has:
    # Inside a container:
    cat /sys/fs/cgroup/memory.max 2>/dev/null || echo "Not in a cgroup-limited env"
    cat /sys/fs/cgroup/cpu.max 2>/dev/null || echo "No CPU limit"

KEY INSIGHT: In production, every container has cgroup limits.
If your app crashes with OOM, check memory.max — you may need more.
If your app is slow, check cpu.max — you may be throttled.
`systemd-cgtop` shows resource usage per cgroup (= per service).

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You understand resource control with cgroups."
echo "  Next: 03_building_a_container.sh"
echo "═══════════════════════════════════════════════════════════════"
