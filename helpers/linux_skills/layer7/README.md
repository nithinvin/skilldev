# Layer 7: Linux Internals & Debugging

## What You'll Learn
- The /proc filesystem — reading live kernel data
- strace — tracing system calls to debug any program
- Memory management, performance analysis, and bottleneck identification

## File Structure

```
layer7/
├── README.md              ← You are here
└── exercises/
    ├── 01_proc_filesystem.sh          ← /proc, process directories, kernel info
    ├── 02_strace.sh                   ← System call tracing, debugging patterns
    └── 03_memory_and_performance.sh   ← Memory, CPU, disk I/O, bottlenecks
```

## Prerequisites
- Complete Layers 0-6
- You should understand processes, files, and basic sysadmin

## Why This Matters
This layer gives you the DEPTH that separates casual users from systems programmers:
- /proc = direct kernel access (every tool reads from here)
- strace = universal debugger (works when everything else fails)
- Performance analysis = "why is it slow?" answered definitively

## The Debugging Philosophy
```
1. Observe    → top, free, iostat (what's the system doing?)
2. Hypothesize → "I think it's disk-bound because..."
3. Prove      → strace, /proc, perf (get definitive evidence)
4. Fix        → change config, optimize, add resources
```

## Time Estimate
~4-5 hours (take your time — this is deep material)
