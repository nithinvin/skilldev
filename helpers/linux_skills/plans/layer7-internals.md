# Layer 7: Internals & Debugging

> **Goal**: Look under the hood. Understand what the kernel does and how to debug anything.

---

## What You'll Do

| Exercise | Skill |
|----------|-------|
| `01_proc_filesystem.sh` | /proc/cpuinfo, /proc/meminfo, /proc/[pid]/ |
| `02_sys_filesystem.sh` | /sys/class, /sys/block, sysfs as kernel API |
| `03_strace.sh` | strace, ltrace — see every syscall a program makes |
| `04_memory.sh` | virtual memory, page faults, OOM killer, /proc/meminfo |
| `05_performance.sh` | perf, time, /usr/bin/time -v, profiling basics |

---

## Key Ideas (Discovered Through Practice)

- **System calls are the kernel's API** — every file read, every network packet goes through a syscall
- **`/proc` is live kernel data** — read it to understand what the OS is doing right now
- **strace is your X-ray vision** — when a program fails mysteriously, strace shows *exactly* what happened
- **Virtual memory = indirection** — every process thinks it has all the RAM
- **The OOM killer is the kernel's last resort** — it picks a process to sacrifice when memory runs out

---

## Checkpoint

1. How do you find out what system calls `ls` makes? Which one opens the directory?
2. What does `/proc/[pid]/maps` show you?
3. A program crashes with "segmentation fault" — what does that actually mean at the hardware level?
4. How does the OOM killer choose which process to kill?
5. `strace -c` vs `strace -e trace=open` — when would you use each?
