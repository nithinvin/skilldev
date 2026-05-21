# Layer 3: Processes & Job Control

## What You'll Learn
- What processes are and how they're created (fork/exec)
- Process states, /proc filesystem, and monitoring tools
- Signals — how to communicate with and control processes
- Job control — multitasking in one terminal
- System monitoring — CPU, memory, disk bottleneck diagnosis

## File Structure

```
layer3/
├── README.md              ← You are here
├── checkpoint_quiz.py     ← Test yourself
└── exercises/
    ├── 01_process_basics.sh   ← ps, /proc, top, fork/exec
    ├── 02_signals.sh          ← kill, SIGTERM/SIGKILL, trap
    ├── 03_job_control.sh      ← &, bg, fg, nohup, cron
    └── 04_monitoring.sh       ← load, memory, disk I/O, watch
```

## Prerequisites
- Complete Layers 0-2
- Comfortable with pipes and basic commands

## Why This Matters
When your program is slow, hangs, or crashes — you need to understand processes:
- "Why is my computer slow?" → check load average, find the process eating CPU
- "How do I keep my server running after logout?" → nohup/tmux
- "How do I schedule backups?" → cron
- "Why did my process crash?" → signals, segfaults, OOM killer

## Time Estimate
~4 hours (processes are a deep topic — take your time with strace experiments)
