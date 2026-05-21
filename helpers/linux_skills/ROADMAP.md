# Linux Skills — Hands-On Learning Path

> **Student**: Nithin | **Background**: B.Tech CSE Year 1 (VIT Chennai)
> **Known**: C, C++, Python, basic shell usage
> **Style**: Learn by doing — theory emerges from practice
> **Environment**: Ubuntu (WSL local) + Ubuntu VM (Hetzner)

---

## Philosophy

Every exercise follows this pattern:

```
1. DO     → Run the command, observe the output
2. BREAK  → Change something, see what fails
3. ASK    → Why did that happen? What's the OS actually doing?
4. BUILD  → Combine commands to solve a real problem
5. NOTE   → Write one sentence: what this taught you
```

Theory is embedded *inside* the exercises as short comments. You never read a page of theory without a terminal open.

---

## Layer Map

| Layer | Topic | What You'll Be Able To Do |
|-------|-------|---------------------------|
| **0** | [Terminal & Shell Basics](plans/layer0-terminal-basics.md) | Navigate like it's second nature, understand what the shell *is* |
| **1** | [Files & The Filesystem](plans/layer1-filesystem.md) | Understand everything-is-a-file, permissions, links, disk layout |
| **2** | [Text Processing Power](plans/layer2-text-processing.md) | grep/sed/awk/sort — slice any data from the command line |
| **3** | [Processes & Job Control](plans/layer3-processes.md) | See what's running, control it, understand scheduling |
| **4** | [Shell Scripting](plans/layer4-shell-scripting.md) | Automate repetitive tasks with bash scripts |
| **5** | [Networking from CLI](plans/layer5-networking.md) | Debug connections, transfer files, scan ports |
| **6** | [System Administration](plans/layer6-sysadmin.md) | Manage packages, services, logs, disks |
| **7** | [Internals & Debugging](plans/layer7-internals.md) | Peek inside the kernel via /proc, /sys, strace |
| **8** | [Advanced: Containers & Isolation](plans/layer8-advanced.md) | Understand namespaces, cgroups — what Docker really does |

---

## How Layers Build On Each Other

```
┌──────────────────────────────────────────────────────────┐
│         Layer 8: Containers & Isolation                    │
│     (namespaces, cgroups — build your own container)      │
├──────────────────────────────────────────────────────────┤
│         Layer 7: Internals & Debugging                    │
│     (/proc, /sys, strace, ltrace, perf)                   │
├──────────────────────────────────────────────────────────┤
│         Layer 6: System Administration                    │
│     (systemd, packages, logs, disk, cron)                 │
├──────────────────────────────────────────────────────────┤
│         Layer 5: Networking from CLI                      │
│     (ip, ss, curl, nc, DNS, firewall)                     │
├──────────────────────────────────────────────────────────┤
│         Layer 4: Shell Scripting                          │
│     (variables, loops, functions, real automation)         │
├──────────────────────────────────────────────────────────┤
│         Layer 3: Processes & Job Control                  │
│     (ps, top, kill, signals, bg/fg, cron)                 │
├──────────────────────────────────────────────────────────┤
│         Layer 2: Text Processing Power                   │
│     (grep, sed, awk, sort, uniq, xargs, pipes)            │
├──────────────────────────────────────────────────────────┤
│         Layer 1: Files & The Filesystem                   │
│     (tree, permissions, inodes, links, /dev, /proc)       │
├──────────────────────────────────────────────────────────┤
│         Layer 0: Terminal & Shell Basics                  │
│     (navigation, commands, man pages, environment)        │
└──────────────────────────────────────────────────────────┘
```

---

## Running Project: "Linux Lab Notebook"

Across all layers, you maintain a **lab notebook** — a directory of scripts, notes, and discoveries:

```
~/linux_lab/
├── notes/          ← one-line TILs (Today I Learned)
├── scripts/        ← scripts you build in Layer 4+
├── experiments/    ← things you broke and fixed
└── cheatsheets/    ← commands you want to remember
```

Create it now:
```bash
mkdir -p ~/linux_lab/{notes,scripts,experiments,cheatsheets}
echo "$(date): Started Linux learning path" > ~/linux_lab/notes/log.txt
```

---

## Prerequisite Check

Run these — if any fail, you're in the right place:
```bash
# Can you explain what each of these does?
echo $SHELL
echo $PATH | tr ':' '\n'
type ls
which python3
cat /etc/os-release
uname -a
```

If you can explain every line of output, skip to Layer 2.
