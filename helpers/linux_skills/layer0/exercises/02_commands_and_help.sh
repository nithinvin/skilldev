#!/bin/bash
# =============================================================================
# Layer 0, Exercise 2: COMMANDS & GETTING HELP
# =============================================================================
# THEORY-IN-ACTION: When you type a command, the shell has to FIND it.
# Understanding HOW it finds commands = understanding how Linux is organized.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 2: Commands — What Are They? Where Do They Live?"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Type each command into your terminal. Don't just read — DO."
echo ""

# ---------------------------------------------------------------------------
# PART 1: What IS a Command?
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: WHAT IS A COMMAND? ────

There are 4 types of "commands" in bash. Let's discover them:

    type cd                 # "cd is a shell builtin"
    type ls                 # "ls is /usr/bin/ls" (an external program)
    type ll                 # "ll is aliased to 'ls -la'" (or similar)
    type if                 # "if is a shell keyword"

So when you type something, bash checks in this order:
  1. Is it an alias?
  2. Is it a shell keyword (if, for, while)?
  3. Is it a shell builtin (cd, echo, export)?
  4. Is it an external program? → Search PATH

EXPERIMENT:
    # Make your own "command"
    alias hi='echo "Hello from alias!"'
    hi                      # Works!
    type hi                 # It's an alias

    # What if there's a conflict?
    alias ls='echo "I replaced ls!"'
    ls                      # Oops
    unalias ls              # Fix it
    ls                      # Back to normal

KEY INSIGHT: `type` tells you WHAT something is. Use it when confused.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: PATH — The Search List
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: PATH — HOW COMMANDS ARE FOUND ────

    echo $PATH              # A colon-separated list of directories
    echo $PATH | tr ':' '\n'  # One per line (easier to read)

    # When you type 'python3', bash searches these directories left to right
    which python3           # Shows which one it found first
    which -a python3        # Shows ALL matches in PATH

    # What if PATH is wrong?
    # DON'T DO THIS in your real shell (just understand it):
    # PATH=""
    # ls                    # "command not found" — even ls!
    # /usr/bin/ls           # Still works with FULL PATH

EXPERIMENT:
    # Create your own command
    mkdir -p ~/bin
    echo '#!/bin/bash
echo "I am a custom command! PID: $$"' > ~/bin/mycommand
    chmod +x ~/bin/mycommand

    # Is ~/bin in your PATH?
    echo $PATH | grep -q "$HOME/bin" && echo "Yes!" || echo "No — add it!"

    # If not in PATH:
    export PATH="$HOME/bin:$PATH"
    mycommand               # Now it works!
    which mycommand         # Found it!

KEY INSIGHT: PATH is just a search list. You can add any directory to it.
Programs don't need to be "installed" — just put them in PATH and make them executable.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Getting Help (man pages)
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: man PAGES — THE BUILT-IN MANUAL ────

    man ls                  # Full manual for ls
                            # Navigate: j/k or arrows, q to quit, /word to search

    # man page sections (the number in parentheses):
    # 1 = User commands       (ls, grep, etc.)
    # 2 = System calls        (open, read, fork — for C programmers)
    # 3 = Library functions   (printf, malloc — C library)
    # 5 = File formats        (/etc/passwd format)
    # 8 = Admin commands      (mount, iptables)

    man 1 printf            # The command-line printf
    man 3 printf            # The C library printf (different!)

    # Quick help (for when man is too much):
    ls --help               # Brief usage info
    ls --help | head -20    # Just the first 20 lines

    # Find commands you don't know the name of:
    apropos "copy files"    # Search man page descriptions
    apropos "disk usage"    # What command shows disk usage?
    man -k "network"        # Same as apropos

EXPERIMENT:
    # Read the man page for `cp`. Find out:
    # 1. How to copy a directory recursively
    # 2. How to preserve permissions
    # 3. How to show progress

    man cp
    # Search with /recursive then press n for next match

KEY INSIGHT: man pages ARE the documentation. They're always available, even offline.
Learn to read them fast: jump to EXAMPLES section (type /EXAMPLES in man).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: info and --help
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: OTHER HELP SOURCES ────

    # --help: Quick reference (almost every command has this)
    grep --help
    find --help 2>&1 | head -30

    # info: GNU's alternative to man (more detailed for GNU tools)
    info coreutils          # Overview of basic commands
    info grep               # More examples than man grep

    # tldr: Community-maintained examples (install first)
    # sudo apt install tldr (or: pip install tldr)
    # tldr tar              # Just the common use cases!
    # tldr find             # Way easier than man find

    # Built-in help for builtins:
    help cd                 # Works only for bash builtins
    help export
    help type

EXPERIMENT:
    # Challenge: Using ONLY man pages or --help, figure out:
    # 1. How to make `mkdir` create parent directories that don't exist
    # 2. How to make `rm` ask before deleting each file
    # 3. How to make `sort` sort numerically instead of alphabetically
    # 4. How to make `head` show the first 5 lines instead of 10

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 5: Command History
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 5: HISTORY — YOUR COMMAND MEMORY ────

    history                 # All commands you've ever typed (in this shell)
    history | tail -20      # Last 20 commands
    history | grep "apt"    # Find commands you've used before

    # Re-run commands:
    !!                      # Re-run the last command
    sudo !!                 # SUPER USEFUL: re-run last command with sudo
    !grep                   # Re-run last command starting with "grep"
    !42                     # Re-run command #42 from history

    # Ctrl+R: REVERSE SEARCH (the most powerful history feature)
    # Press Ctrl+R, start typing — it searches your history live!
    # Press Ctrl+R again to go to next match
    # Press Enter to run, Ctrl+G to cancel

    # History file:
    echo $HISTFILE          # Where history is saved
    echo $HISTSIZE          # How many commands to keep
    wc -l ~/.bash_history   # How many commands you have saved

EXPERIMENT:
    # Make history more useful (add to ~/.bashrc):
    # HISTSIZE=10000
    # HISTFILESIZE=20000
    # HISTCONTROL=ignoredups:erasedups   # No duplicates
    # shopt -s histappend                # Append, don't overwrite

KEY INSIGHT: Your history is searchable. Ctrl+R is faster than typing.
If you've typed it once, you never need to type it fully again.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. alias cd='echo "nice try"'   # What happens when you try to cd?
       # How do you fix this? (hint: unalias, or use builtin cd, or close terminal)

    2. PATH=/nonexistent
       ls                           # What happens?
       # Can you still run ls? (hint: full path)
       # How do you restore PATH? (hint: source ~/.bashrc or open new terminal)

    3. chmod -x /usr/bin/ls         # (DON'T DO THIS — but what WOULD happen?)
       # Removing execute permission from ls itself

    4. man doesnotexist             # What's the exit code?
       echo $?                      # 16 = no manual entry

    5. type type                    # What is `type` itself?
       type type type               # What about `type type`? Meta!

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You now understand what commands are and how to find help."
echo "  Next: 03_environment.sh"
echo "═══════════════════════════════════════════════════════════════"
