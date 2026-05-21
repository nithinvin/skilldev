#!/bin/bash
# =============================================================================
# Layer 0, Exercise 1: NAVIGATION
# =============================================================================
# THEORY-IN-ACTION: The filesystem is a tree. You are always "somewhere" in it.
# Your shell tracks your Current Working Directory (cwd). Every command you run
# executes relative to that location.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 1: Navigation — Know Where You Are, Go Where You Want"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "This is NOT a script you just run. Open it in your editor AND"
echo "type each command below into your terminal one by one."
echo "Observe. Experiment. Break things."
echo ""
echo "═══════════════════════════════════════════════════════════════"

# ---------------------------------------------------------------------------
# PART 1: Where Am I?
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: WHERE AM I? ────

Run these one at a time in your terminal:

    pwd                     # Print Working Directory — your current location
    echo $HOME              # Your home directory (usually /home/username)
    echo ~                  # Shorthand for $HOME

    # They should be the same. Are they?
    [[ "$HOME" == ~ ]] && echo "Same!" || echo "Different!"

TRY THIS:
    cd /tmp
    pwd                     # You moved!
    cd                      # No argument — where does it take you?
    pwd                     # Back home

KEY INSIGHT: `cd` with no argument = `cd $HOME`. Always.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Listing Files
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: LISTING FILES ────

    ls                      # Files in current directory
    ls -l                   # Long format (permissions, size, date)
    ls -la                  # Include hidden files (dotfiles start with .)
    ls -lah                 # Human-readable sizes (K, M, G instead of bytes)
    ls -lt                  # Sort by time (newest first)
    ls -lS                  # Sort by size (largest first)
    ls -R                   # Recursive (all subdirectories)

    # What are all those dotfiles?
    ls -la ~/               # Look at .bashrc, .profile, .config, etc.

EXPERIMENT:
    # Create a hidden file
    touch ~/.my_secret_file
    ls ~                    # Can you see it?
    ls -a ~                 # Now?

KEY INSIGHT: Files starting with . are "hidden" — but only from `ls` (not `ls -a`).
This is NOT security. It's just decluttering.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Moving Around
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: MOVING AROUND ────

    cd /                    # Root of the filesystem tree
    ls                      # What's at the root?

    cd /etc                 # System configuration files
    ls                      # Notice: lots of .conf files
    cd ..                   # Go UP one level (back to /)
    pwd

    cd /var/log             # System logs
    cd ../..                # Go up TWO levels
    pwd                     # Where are you?

    cd -                    # Go BACK to previous directory (like browser back button)
    pwd
    cd -                    # Toggle back again!
    pwd

EXPERIMENT:
    # Absolute vs Relative paths
    cd /home                # Absolute: starts from /
    cd ../tmp               # Relative: starts from where you ARE
    pwd

KEY INSIGHT:
  - Starts with / = absolute (from root)
  - No leading / = relative (from cwd)
  - ..  = parent directory
  - .   = current directory
  - -   = previous directory

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: pushd/popd (Directory Stack)
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: THE DIRECTORY STACK ────

`cd -` remembers ONE previous location. What if you need to jump between 3-4 places?

    pushd /etc              # Go to /etc AND push it onto the stack
    pushd /var/log          # Go to /var/log AND push it
    pushd /tmp              # Go to /tmp AND push it

    dirs -v                 # See the stack (numbered)

    popd                    # Pop top of stack, go to next one
    pwd
    popd
    pwd
    popd
    pwd                     # Back where you started

REAL USAGE:
    # You're deep in a project, need to check something in /etc, then come back:
    pushd /etc/nginx
    # ... look at configs ...
    popd                    # You're back!

KEY INSIGHT: pushd/popd = bookmarked navigation. Faster than remembering paths.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 5: Tab Completion
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 5: TAB COMPLETION (Your Best Friend) ────

This you can only practice live in the terminal:

    cd /e<TAB>              # Should complete to /etc/
    ls /etc/pass<TAB>       # Should complete to /etc/passwd
    cat /etc/hos<TAB><TAB>  # Two TABs = show all options (hosts, hosts.allow, etc.)

    # For commands too:
    sys<TAB><TAB>           # Shows all commands starting with 'sys'
    systemc<TAB>            # Completes to 'systemctl'

EXPERIMENT:
    # How many completions are there for 'ls /usr/bin/p'?
    ls /usr/bin/p<TAB><TAB>
    # That's a LOT of programs on your system!

KEY INSIGHT: NEVER type full paths manually. Let TAB do the work.
If TAB doesn't complete, the path doesn't exist (typo alert!).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 6: tree (Visual Overview)
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 6: TREE VIEW ────

    # Install tree if not present
    which tree || sudo apt install tree -y

    tree /etc/apt           # Visual directory structure
    tree -L 1 /             # Depth-limited (1 level deep)
    tree -L 2 /home         # 2 levels deep

    # Useful flags
    tree -d /usr            # Directories only
    tree -h /var/log        # With human-readable sizes
    tree --prune /etc       # Skip empty directories

KEY INSIGHT: `tree` gives you a mental map. Use `tree -L 2` when you enter
any new project to understand its structure.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

Try these and see what happens:

    1. cd /nonexistent           # What error do you get? What's the exit code? (echo $?)
    2. cd /etc/passwd            # Can you cd into a FILE?
    3. mkdir -p /tmp/a/b/c/d/e && cd /tmp/a/b/c/d/e
       rm -rf /tmp/a            # You deleted your current directory!
       pwd                      # What does it say?
       ls                       # What happens?
    4. cd ""                     # Empty string — where does it go?
    5. ln -s /tmp /tmp/loop     # Symlink loop! What does `cd /tmp/loop/loop/loop` do?

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You should now be comfortable navigating the filesystem."
echo "  Next: 02_commands_and_help.sh"
echo "═══════════════════════════════════════════════════════════════"
