# 👻 BRIEFING: The Ghost Process

**Difficulty:** [OPERATIVE]
**Skills:** Process management, ps, kill, signals, /proc, background jobs
**Time estimate:** 30-45 minutes

---

## SITUATION

A rogue process has been spawned on this system. It's eating resources,
and it's writing the flag to a location that disappears when the process dies.

Your mission:
1. Find the ghost process
2. Figure out what it's doing
3. Extract the flag BEFORE killing it
4. Kill it cleanly

## SETUP

```bash
bash spawn_ghost.sh
```

This launches the ghost. It's running in the background. It's hiding.

## OBJECTIVES

1. Find the process (it's disguised — its name is misleading)
2. Find what file it's writing to (check /proc or use lsof)
3. Read the flag from its output
4. Send it signal 15 (SIGTERM) — clean shutdown
5. Verify it's dead

## CONSTRAINTS

- Do NOT use `killall` or `pkill` blindly — you might kill something else
- You need the exact PID
- The process writes the flag to a TEMPORARY file that's deleted on exit
- You must read the flag WHILE the process is alive

## INTEL

- The process masquerades as something innocent
- `ps aux` shows all processes
- `/proc/<PID>/` contains everything about a running process
- `lsof` shows open files by a process
- Signals: SIGTERM (15) = polite shutdown, SIGKILL (9) = violent death

---

*After solving, check DEBRIEF.md*
