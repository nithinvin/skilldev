# Layer 8: Advanced — Containers & Isolation

> **Goal**: Understand what Docker *really* does — namespaces, cgroups, layered filesystems.

---

## What You'll Do

| Exercise | Skill |
|----------|-------|
| `01_namespaces.sh` | unshare, PID/NET/MNT/UTS namespaces — isolation primitives |
| `02_cgroups.sh` | cgroups v2, memory/CPU limits, reading cgroup fs |
| `03_chroot.sh` | chroot jails, building a minimal root filesystem |
| `04_overlay_fs.sh` | overlayfs — how container layers work |
| `05_build_container.sh` | Combine all of the above into a mini container runtime |

---

## Key Ideas (Discovered Through Practice)

- **Containers are NOT VMs** — they share the host kernel, just isolated by namespaces
- **Namespaces** = what a process can *see* (its own PID tree, network, filesystem)
- **Cgroups** = what a process can *use* (memory limit, CPU shares)
- **overlayfs** = layered filesystem — base layer + changes on top (how images work)
- **Docker = namespaces + cgroups + overlayfs + a nice CLI**

---

## Checkpoint

1. What's the difference between a container and a VM? When would you pick each?
2. What does `unshare --pid --fork bash` do? Why `--fork`?
3. How do you limit a process to 100MB of RAM without Docker?
4. What happens if a containerized process tries to access the host filesystem?
5. Build a container from scratch using only `unshare`, `cgroups`, and `chroot`.

---

## What's Next

After this layer, you deeply understand what production systems run on. You can:
- Debug any Linux server
- Write efficient shell automation
- Understand containers at the kernel level
- Read and contribute to systems software

Go back to `web_dev_helper_copilot` Layer 4 (Containers & DevOps) — it will feel trivial now.
