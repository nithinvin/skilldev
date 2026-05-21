#!/bin/bash
# =============================================================================
# Layer 3, Exercise 3: JOB CONTROL
# =============================================================================
# THEORY-IN-ACTION: Job control lets you run multiple programs in one terminal,
# switch between them, pause and resume them. Before tmux/screen, this was
# how people multitasked in a terminal.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 3: Job Control — Multitask in One Terminal"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: Background and Foreground
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: & (BACKGROUND) AND fg/bg ────

    # Run in foreground (default — blocks your terminal):
    sleep 30                    # Your terminal is stuck for 30s. Press Ctrl+C.

    # Run in background (add &):
    sleep 30 &                  # Returns immediately! Shows [job_num] PID
    echo "I can type other things!"
    jobs                        # See background jobs

    # Foreground/Background workflow:
    sleep 100                   # Running in foreground...
    # Press Ctrl+Z              # SIGTSTP → Stopped!
    jobs                        # Shows: [1]+  Stopped  sleep 100
    bg %1                       # Resume it in background
    jobs                        # Shows: [1]+  Running  sleep 100 &
    fg %1                       # Bring it back to foreground
    # Press Ctrl+C              # Kill it

    # Multiple jobs:
    sleep 100 &                 # Job 1
    sleep 200 &                 # Job 2
    sleep 300 &                 # Job 3
    jobs                        # See all three
    # [1]   Running  sleep 100 &
    # [2]-  Running  sleep 200 &
    # [3]+  Running  sleep 300 &

    # + means "current job" (fg/bg with no argument affects this one)
    # - means "previous job"

    fg %2                       # Bring job 2 to foreground
    # Ctrl+C to kill it
    kill %1 %3                  # Kill jobs 1 and 3

EXPERIMENT:
    # Run a command, realize it'll take long, background it:
    find / -name "*.py" 2>/dev/null    # Started... taking too long
    # Press Ctrl+Z (stop it)
    bg                          # Resume in background
    # Now do other things while it finishes!

    # Wait for all background jobs:
    sleep 2 & sleep 3 & sleep 1 &
    wait                        # Blocks until ALL background jobs finish
    echo "All done!"

    # Wait for a specific job:
    sleep 5 &
    wait $!                     # Wait for just that one
    echo "Exit code: $?"

KEY INSIGHT: Ctrl+Z stops (pauses) a process, bg resumes it in background.
This is the "oops I forgot the &" recovery: Ctrl+Z then bg.
`jobs` shows your background/stopped jobs, %N references them.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: nohup and disown
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: KEEP PROCESSES ALIVE AFTER LOGOUT ────

    # Problem: You start a long process, then need to close your laptop.
    # When you close the terminal → SIGHUP → all jobs die!

    # Solution 1: nohup (ignore SIGHUP)
    nohup sleep 1000 &
    jobs                        # It's running
    # If you close this terminal, it keeps running!
    # Output goes to nohup.out by default
    cat nohup.out 2>/dev/null

    # Solution 2: disown (remove from job table)
    sleep 1000 &
    PID=$!
    disown $PID                 # Shell "forgets" about it
    jobs                        # Not listed anymore!
    ps -p $PID                  # But still running!
    kill $PID                   # Clean up

    # Solution 3: disown -h (keep in job table but don't send SIGHUP)
    sleep 1000 &
    disown -h %1
    jobs                        # Still listed
    # But won't get SIGHUP when terminal closes

    # The BEST solution: tmux or screen (persistent terminal sessions)
    # tmux new -s mysession     # Create named session
    # (run your long command)
    # Ctrl+B, D                 # Detach (session keeps running!)
    # tmux attach -t mysession  # Reattach later, even from another machine

EXPERIMENT:
    # Verify nohup survives terminal close:
    nohup bash -c 'echo "alive at $(date)" >> /tmp/nohup_test.txt; sleep 5; echo "still alive at $(date)" >> /tmp/nohup_test.txt' &
    cat /tmp/nohup_test.txt
    sleep 6
    cat /tmp/nohup_test.txt     # Should have both lines

    # Clean up:
    killall sleep 2>/dev/null
    rm -f /tmp/nohup_test.txt nohup.out

KEY INSIGHT: Terminal close → SIGHUP to all jobs → they die.
Prevent with: nohup (before starting), disown (after starting), or tmux (best).
For any long-running task: use tmux/screen.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Process Priority (nice and renice)
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: PRIORITY — WHO GETS CPU FIRST ────

    # Nice values: -20 (highest priority) to 19 (lowest priority)
    # Default: 0
    # Higher nice = "nicer to others" = lower priority

    # See current nice values:
    ps -eo pid,ni,comm | head -20       # NI column
    top                                  # NI column visible

    # Start a process with low priority:
    nice -n 10 sleep 100 &
    ps -o pid,ni,comm -p $!             # NI shows 10

    # Start with high priority (needs root):
    sudo nice -n -5 sleep 100 &
    ps -o pid,ni,comm -p $!             # NI shows -5
    sudo kill $!

    # Change priority of running process:
    sleep 1000 &
    PID=$!
    renice 15 -p $PID                   # Lower priority
    ps -o pid,ni,comm -p $PID
    sudo renice -10 -p $PID            # Higher priority (needs root)
    ps -o pid,ni,comm -p $PID
    kill $PID

    # Practical: compile in background without slowing other work
    # nice -n 19 make -j$(nproc)       # Compile with lowest priority

EXPERIMENT:
    # Race two processes with different priorities:
    nice -n 19 bash -c 'for i in $(seq 1 100000); do :; done; echo "LOW done"' &
    nice -n -0 bash -c 'for i in $(seq 1 100000); do :; done; echo "NORMAL done"' &
    wait
    # NORMAL should finish first (on a loaded system the difference is visible)

    # ionice: I/O priority (less commonly needed)
    # ionice -c 3 cp largefile /backup/  # "Idle" class — only uses I/O when nothing else needs it

KEY INSIGHT: nice values control CPU scheduling priority.
Use `nice -n 19` for background tasks that shouldn't slow your work.
Regular users can only LOWER priority (make it nicer).
Root can RAISE priority (make it mean).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: cron — Scheduled Tasks
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: cron — RUN THINGS ON A SCHEDULE ────

    # cron runs commands at specified times. Each user has a crontab:
    crontab -l                  # List your cron jobs (probably empty)

    # Crontab format:
    # ┌───────── minute (0-59)
    # │ ┌─────── hour (0-23)
    # │ │ ┌───── day of month (1-31)
    # │ │ │ ┌─── month (1-12)
    # │ │ │ │ ┌─ day of week (0-7, 0 and 7 = Sunday)
    # │ │ │ │ │
    # * * * * * command

    # Examples:
    # 0 * * * *     = every hour (at minute 0)
    # */5 * * * *   = every 5 minutes
    # 0 9 * * 1-5   = 9am every weekday
    # 0 0 1 * *     = midnight on the 1st of every month
    # @reboot       = once at system startup

    # Add a cron job:
    # crontab -e              # Opens editor

    # Test: add a job that logs every minute
    (crontab -l 2>/dev/null; echo "* * * * * echo 'cron ran at $(date)' >> /tmp/cron_test.log") | crontab -
    crontab -l                  # Verify it's there

    # Wait 1-2 minutes then:
    cat /tmp/cron_test.log

    # Remove it:
    crontab -l | grep -v "cron_test" | crontab -
    crontab -l                  # Should be gone
    rm -f /tmp/cron_test.log

    # System-wide cron:
    ls /etc/cron.d/             # System cron jobs
    ls /etc/cron.daily/         # Scripts run daily
    ls /etc/cron.hourly/        # Scripts run hourly

EXPERIMENT:
    # Common gotcha: cron has minimal PATH!
    # Your cron job might fail because it can't find commands.
    # Fix: use full paths in cron, or set PATH at the top of crontab:
    # PATH=/usr/local/bin:/usr/bin:/bin
    # * * * * * /usr/bin/python3 /home/user/script.py

    # Another gotcha: cron has no terminal!
    # Commands that need a terminal (like interactive prompts) won't work.

    # at: one-time scheduled task (alternative to cron):
    # echo "echo 'hello' >> /tmp/at_test.txt" | at now + 2 minutes
    # atq                       # List pending at jobs

KEY INSIGHT: cron = recurring scheduled tasks. Use for:
- Backups, log rotation, monitoring checks, data cleanup
- PATH in cron is minimal — use full paths!
- Output goes to mail by default — redirect to a file or /dev/null.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # What happens if you bg a process that needs stdin?
       cat                      # Waiting for input...
       # Ctrl+Z (stop it)
       bg                       # Resume in background
       # It immediately stops again with "Stopped (tty input)"
       # Background processes can't read from terminal!
       kill %1

    2. # Multiple foreground processes:
       # Can you have two foreground processes? No!
       # There's only ONE foreground process group per terminal.
       # Everything else is background.

    3. # Priority inversion:
       # High-priority process waiting for low-priority process → deadlock-like
       # This is why nice values alone don't guarantee behavior.

    4. # Cron environment is EMPTY:
       # Add: * * * * * env > /tmp/cron_env.txt
       # Wait, then compare:
       # diff <(env | sort) <(sort /tmp/cron_env.txt)
       # Cron has almost nothing! That's why scripts "work in terminal but not in cron"

    5. # What's the maximum number of background jobs?
       for i in $(seq 1 100); do sleep 1000 & done
       jobs | wc -l             # 100 jobs!
       kill $(jobs -p)          # Kill them all

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can multitask, schedule, and prioritize processes."
echo "  Next: 04_monitoring.sh"
echo "═══════════════════════════════════════════════════════════════"
