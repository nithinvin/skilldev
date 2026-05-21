# Layer 3: Processes & Job Control

> **Goal**: Understand what's running on your machine and how to control it.

---

## What You'll Do

| Exercise | Skill |
|----------|-------|
| `01_process_basics.sh` | ps, top, htop, /proc/[pid]/, process states |
| `02_signals.sh` | kill, SIGTERM, SIGKILL, SIGSTOP, SIGHUP, trap |
| `03_job_control.sh` | &, bg, fg, jobs, Ctrl-Z, nohup, disown |
| `04_scheduling.sh` | cron, crontab, at, systemd timers |
| `05_monitoring.sh` | watch, vmstat, iostat, free, uptime, load average |

---

## Key Ideas (Discovered Through Practice)

- **Every process has a parent** — PID 1 (init/systemd) is the ancestor of all
- **Signals are interrupts for processes** — SIGTERM asks nicely, SIGKILL doesn't
- **Process states**: Running, Sleeping, Stopped, Zombie — each tells a story
- **Load average** = average number of processes in runnable state over 1/5/15 min
- **Zombie** = process finished but parent hasn't read its exit code yet

---

## Checkpoint

1. What's the difference between SIGTERM (15) and SIGKILL (9)? When would you use each?
2. How do you keep a process running after you close your terminal?
3. What is a zombie process? How do you find them? How do you fix them?
4. `load average: 4.2 1.8 0.9` on a 4-core machine — what does this tell you?
5. How does `cron` know when to run your scheduled commands?
