#!/bin/bash
# =============================================================================
# Layer 8, Exercise 1: NAMESPACES — ISOLATION BUILDING BLOCKS
# =============================================================================
# THEORY-IN-ACTION: Containers are NOT VMs. They're just Linux processes with
# ISOLATION provided by namespaces. A namespace gives a process its own private
# view of system resources: its own PID tree, network, mounts, etc.
# This is the fundamental mechanism Docker uses.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 1: Namespaces — How Containers Actually Work"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: WHAT ARE NAMESPACES? ────

    # Linux has 8 types of namespaces:
    # 1. PID    — process IDs (container sees its own PID 1)
    # 2. NET    — network interfaces (container has its own IP)
    # 3. MNT    — mount points (container has its own filesystem)
    # 4. UTS    — hostname (container has its own hostname)
    # 5. IPC    — inter-process communication
    # 6. USER   — user IDs (root inside container ≠ root outside)
    # 7. CGROUP — cgroup visibility
    # 8. TIME   — system clocks (newer kernel)

    # See YOUR namespaces:
    ls -la /proc/$$/ns/
    # Each file is a symlink to a namespace ID
    # Processes in the SAME namespace share the same ID

    # See all namespaces on the system:
    lsns 2>/dev/null || sudo lsns
    # Shows: NS ID, TYPE, NPROCS, PID, USER, COMMAND

    # Compare two processes:
    readlink /proc/1/ns/pid             # init's PID namespace
    readlink /proc/$$/ns/pid            # Your shell's PID namespace
    # Same ID? You're in the same namespace!

──── PART 2: unshare — CREATE NAMESPACES ────

    # unshare = run a command in new namespace(s)

    # New UTS namespace (own hostname):
    sudo unshare --uts bash -c '
        hostname container-test
        hostname                         # Shows "container-test"
        echo "Inside UTS namespace: $(hostname)"
    '
    hostname                             # Still your original hostname!

    # New PID namespace (own process tree):
    sudo unshare --pid --fork --mount-proc bash -c '
        echo "PID 1 inside namespace:"
        ps aux
        echo "Only MY processes visible!"
    '
    # Inside: only sees processes started in this namespace
    # PID 1 = the bash we started (like init inside a container!)

    # New network namespace (isolated network):
    sudo unshare --net bash -c '
        ip addr                          # Only loopback! No eth0!
        echo "Completely isolated network"
    '

    # Combine namespaces (this is what Docker does!):
    sudo unshare --pid --net --uts --mount --fork --mount-proc bash -c '
        hostname my-container
        echo "Hostname: $(hostname)"
        echo "PIDs:"
        ps aux
        echo "Network:"
        ip addr
        echo "This is essentially a container!"
    '

EXPERIMENT:
    # Watch namespace creation:
    lsns | wc -l                        # Count before
    sudo unshare --uts sleep 30 &
    sleep 1
    lsns | wc -l                        # Count after (one more UTS ns!)
    sudo kill %1 2>/dev/null

    # Docker uses namespaces — prove it:
    # If Docker is installed:
    # docker run --rm -d --name test alpine sleep 60
    # DOCKER_PID=$(docker inspect test --format '{{.State.Pid}}')
    # sudo ls -la /proc/$DOCKER_PID/ns/  # Different from your ns!
    # readlink /proc/$DOCKER_PID/ns/pid  # Different PID namespace
    # docker stop test

KEY INSIGHT: A "container" is just a process with its own namespaces.
unshare creates new namespaces. Docker is essentially:
unshare + cgroups + overlay filesystem + image management + nice API.
There's NO VM, NO hypervisor. Just isolated Linux processes.

──── PART 3: nsenter — ENTER EXISTING NAMESPACES ────

    # nsenter = join an existing namespace (like "docker exec"):
    # sudo nsenter --target PID --pid --net --mount bash

    # Practical: If Docker is installed, enter a container's namespaces:
    # CPID=$(docker inspect container_name --format '{{.State.Pid}}')
    # sudo nsenter --target $CPID --all  # Join ALL namespaces

    # Or enter just the network namespace:
    # sudo nsenter --target $CPID --net ip addr

    # Create a persistent network namespace:
    sudo ip netns add testns
    sudo ip netns list
    sudo ip netns exec testns ip addr    # Run command in that ns
    sudo ip netns exec testns bash -c 'hostname -I'  # No IP!
    sudo ip netns delete testns

EXPERIMENT:
    # Create two network namespaces and connect them with a virtual cable:
    sudo ip netns add ns1
    sudo ip netns add ns2
    # Create a virtual ethernet pair (like a cable between them):
    sudo ip link add veth1 type veth peer name veth2
    # Put each end in a different namespace:
    sudo ip link set veth1 netns ns1
    sudo ip link set veth2 netns ns2
    # Assign IPs:
    sudo ip netns exec ns1 ip addr add 10.0.0.1/24 dev veth1
    sudo ip netns exec ns1 ip link set veth1 up
    sudo ip netns exec ns2 ip addr add 10.0.0.2/24 dev veth2
    sudo ip netns exec ns2 ip link set veth2 up
    # Ping between namespaces!
    sudo ip netns exec ns1 ping -c 2 10.0.0.2
    # Clean up:
    sudo ip netns delete ns1
    sudo ip netns delete ns2

KEY INSIGHT: nsenter joins existing namespaces (= docker exec).
ip netns creates persistent network namespaces.
Virtual ethernet pairs (veth) connect namespaces — this is how Docker
networking works: veth pairs between container ns and bridge.

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You understand the isolation mechanism behind containers."
echo "  Next: 02_cgroups.sh"
echo "═══════════════════════════════════════════════════════════════"
