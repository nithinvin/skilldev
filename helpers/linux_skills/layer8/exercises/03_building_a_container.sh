#!/bin/bash
# =============================================================================
# Layer 8, Exercise 3: BUILD A CONTAINER FROM SCRATCH
# =============================================================================
# THEORY-IN-ACTION: Now you put it all together. A container is:
# 1. A filesystem (rootfs) — the "image"
# 2. Namespaces — isolation (PID, net, mount, UTS)
# 3. Cgroups — resource limits
# 4. That's it. There's no magic.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 3: Building a Container — From First Principles"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: CREATE A ROOT FILESYSTEM ────

    # A container needs a filesystem. Let's build a minimal one.

    # Method 1: Use debootstrap (Debian/Ubuntu minimal root):
    # sudo apt install debootstrap
    # sudo debootstrap --variant=minbase focal /tmp/mycontainer http://archive.ubuntu.com/ubuntu
    # (This downloads ~200MB of a minimal Ubuntu)

    # Method 2: Use Alpine (tiny! ~5MB):
    mkdir -p /tmp/mycontainer
    cd /tmp/mycontainer
    # Download Alpine mini root filesystem:
    curl -sL https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-minirootfs-3.19.0-x86_64.tar.gz | sudo tar xz -C /tmp/mycontainer 2>/dev/null
    # OR create a truly minimal rootfs with busybox:
    mkdir -p /tmp/mycontainer/{bin,proc,sys,dev,etc,tmp}
    # Copy busybox (provides basic commands):
    if command -v busybox &> /dev/null; then
        cp $(which busybox) /tmp/mycontainer/bin/
        # Create symlinks for common commands:
        for cmd in sh ls cat echo ps mount; do
            ln -sf busybox /tmp/mycontainer/bin/$cmd
        done
    fi

    # What's in our "image"?
    ls /tmp/mycontainer/
    du -sh /tmp/mycontainer/            # How big is it?

──── PART 2: RUN IT AS A CONTAINER ────

    # The container recipe:
    # 1. New namespaces (PID, mount, UTS, net)
    # 2. Mount proc inside
    # 3. chroot into the new rootfs
    # 4. Run a shell

    # Simple container (using unshare + chroot):
    sudo unshare --pid --fork --mount --uts --net \
        chroot /tmp/mycontainer /bin/sh -c '
            # Inside the container!
            mount -t proc proc /proc 2>/dev/null
            hostname my-container 2>/dev/null

            echo "=== INSIDE CONTAINER ==="
            echo "Hostname: $(hostname 2>/dev/null || echo unknown)"
            echo "PID: $$"
            echo "Processes:"
            ps aux 2>/dev/null || echo "(ps not available)"
            echo "Network:"
            ip addr 2>/dev/null || echo "(no network tools)"
            echo "Files:"
            ls /
            echo "========================"

            umount /proc 2>/dev/null
        '

    echo ""
    echo "Back on the host. Hostname: $(hostname)"
    echo "That was a real container. No Docker needed."

──── PART 3: OVERLAY FILESYSTEM — LAYERED IMAGES ────

    # Docker images use overlay filesystems (layers!):
    # Base layer: Ubuntu
    # Layer 2: + Python installed
    # Layer 3: + your app code
    # Each layer = just the DIFFERENCES from the layer below

    # Create a layered filesystem:
    mkdir -p /tmp/overlay/{lower,upper,work,merged}

    # Lower layer (read-only "base image"):
    echo "I am from the base image" > /tmp/overlay/lower/base_file.txt
    echo "original content" > /tmp/overlay/lower/shared_file.txt

    # Mount overlay (upper = writable layer, lower = read-only):
    sudo mount -t overlay overlay \
        -o lowerdir=/tmp/overlay/lower,upperdir=/tmp/overlay/upper,workdir=/tmp/overlay/work \
        /tmp/overlay/merged 2>/dev/null

    # Now the merged view has everything:
    ls /tmp/overlay/merged/
    cat /tmp/overlay/merged/base_file.txt    # From lower layer

    # Write a new file (goes to upper layer only!):
    echo "new content" > /tmp/overlay/merged/new_file.txt
    # Modify existing file (copy-on-write to upper layer!):
    echo "modified" > /tmp/overlay/merged/shared_file.txt

    # Check: lower is UNCHANGED:
    cat /tmp/overlay/lower/shared_file.txt   # Still "original content"
    # Changes went to upper:
    cat /tmp/overlay/upper/shared_file.txt   # "modified"
    ls /tmp/overlay/upper/                    # new_file.txt is here

    # Clean up:
    sudo umount /tmp/overlay/merged 2>/dev/null
    rm -rf /tmp/overlay

    # This is EXACTLY how Docker works:
    # - Each image layer = a "lower" directory (read-only)
    # - Container's writable layer = "upper" directory
    # - What you see = "merged" view
    # - When container is deleted, only upper is removed!

EXPERIMENT:
    # See Docker's overlay in action (if Docker installed):
    # docker image inspect alpine --format '{{.GraphDriver.Data}}'
    # Shows LowerDir, UpperDir, MergedDir, WorkDir paths

    # Docker container layers:
    # docker run --rm -it alpine sh
    # Inside: create a file, exit
    # The file existed only in the container's upper layer — now it's gone!

──── PART 4: PUTTING IT ALL TOGETHER ────

    # What Docker does when you run `docker run -it --memory=512m alpine sh`:
    #
    # 1. Pull image layers (overlay filesystem layers)
    # 2. Set up overlay mount (merged view of all layers)
    # 3. Create new namespaces: PID, NET, MNT, UTS, IPC
    # 4. Create a veth pair (container eth0 ↔ docker bridge)
    # 5. Assign IP address to container's interface
    # 6. Create cgroup with memory.max = 512MB
    # 7. Put the process in that cgroup
    # 8. chroot (actually pivot_root) into the merged filesystem
    # 9. Mount /proc, /sys, /dev inside
    # 10. Set hostname
    # 11. Drop capabilities (security)
    # 12. exec the shell as PID 1

    # That's ALL a container is. No VM. No hypervisor.
    # Just a Linux process with:
    # - Its own view of the world (namespaces)
    # - Limited resources (cgroups)
    # - Its own filesystem (overlayfs)

    # Clean up our container rootfs:
    sudo rm -rf /tmp/mycontainer 2>/dev/null

KEY INSIGHT: You now understand containers at the DEEPEST level.
Docker is a user-friendly wrapper around: namespaces + cgroups + overlayfs.
Kubernetes is an orchestrator that manages thousands of these containers.
There is no magic — just clever use of Linux kernel features.

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  CONGRATULATIONS: You've built a container from scratch!"
echo "  Layer 8 — and the entire Linux Skills path — complete!"
echo "═══════════════════════════════════════════════════════════════"
