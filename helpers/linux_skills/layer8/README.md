# Layer 8: Advanced — Containers from First Principles

## What You'll Learn
- Linux namespaces — the isolation mechanism behind containers
- Cgroups — resource limiting and accounting
- Building a container from scratch (no Docker!) with overlayfs

## File Structure

```
layer8/
├── README.md              ← You are here
└── exercises/
    ├── 01_namespaces.sh               ← PID/NET/MNT/UTS namespaces, unshare, nsenter
    ├── 02_cgroups.sh                  ← Resource limits, memory.max, cpu.max, systemd
    └── 03_building_a_container.sh     ← rootfs, overlay, build your own container
```

## Prerequisites
- Complete Layers 0-7
- Root/sudo access
- Ideally: a VM (don't experiment with namespaces on a machine you can't reboot)

## Why This Matters
After this layer, when someone says "container" you'll think:
- "That's just a process in its own namespaces with cgroup limits on an overlayfs."

This understanding is essential for:
- Debugging container issues ("why is my container OOM-killed?" → cgroup memory.max)
- Container security ("can a container escape?" → namespace boundaries)
- Kubernetes troubleshooting (pods = cgroups + namespaces)
- Building custom runtimes or understanding Docker internals

## The Container Stack (bottom to top)
```
┌─────────────────────────────────────┐
│  Kubernetes / Docker Compose        │ ← Orchestration
├─────────────────────────────────────┤
│  Docker / containerd / podman       │ ← Container Runtime
├─────────────────────────────────────┤
│  OCI Images (layered tarballs)      │ ← Filesystem Layers
├─────────────────────────────────────┤
│  overlayfs                          │ ← Union Filesystem
├─────────────────────────────────────┤
│  cgroups v2                         │ ← Resource Limits
├─────────────────────────────────────┤
│  Namespaces (PID,NET,MNT,UTS,...)   │ ← Isolation
├─────────────────────────────────────┤
│  Linux Kernel                       │ ← Foundation
└─────────────────────────────────────┘
```

## Time Estimate
~4-5 hours (this is the most advanced layer — experiment carefully)
