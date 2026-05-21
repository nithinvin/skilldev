#!/bin/bash
# =============================================================================
# Layer 0, Exercise 3: ENVIRONMENT VARIABLES
# =============================================================================
# THEORY-IN-ACTION: Every process inherits a key-value store from its parent.
# This is how configuration flows through the system without config files.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 3: Environment — The Invisible Configuration Layer"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: See Your Environment
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: THE ENVIRONMENT ────

    env                         # ALL environment variables (a lot!)
    env | wc -l                 # How many?
    env | sort                  # Sorted (easier to scan)

    # The important ones:
    echo $HOME                  # Your home directory
    echo $USER                  # Your username
    echo $SHELL                 # Your default shell
    echo $PATH                  # Command search path
    echo $PWD                   # Current directory (updated by cd)
    echo $OLDPWD               # Previous directory (used by cd -)
    echo $LANG                  # Language/locale setting
    echo $EDITOR                # Your preferred text editor
    echo $TERM                  # Terminal type

    # See a specific variable's value:
    printenv HOME
    printenv PATH

EXPERIMENT:
    # What's the difference between env and set?
    env | wc -l                 # Fewer — just exported (environment) variables
    set | wc -l                 # Many more — includes shell variables too!

KEY INSIGHT: "Environment variables" are inherited by child processes.
"Shell variables" are local to the current shell. `export` promotes a
shell variable to an environment variable.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Setting Variables
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: SHELL VARIABLES vs ENVIRONMENT VARIABLES ────

    # Shell variable (local to this shell only)
    MY_NAME="Nithin"
    echo $MY_NAME               # Works here

    # Does a child process see it?
    bash -c 'echo "Child sees: $MY_NAME"'     # Empty! Not inherited.

    # Export it (make it an environment variable)
    export MY_NAME
    bash -c 'echo "Child sees: $MY_NAME"'     # Now it works!

    # Create and export in one step:
    export MY_AGE=19
    bash -c 'echo "Age: $MY_AGE"'

    # Unset (remove):
    unset MY_NAME
    echo $MY_NAME               # Gone

EXPERIMENT:
    # Set a variable for just ONE command (without export):
    GREETING="Howdy" bash -c 'echo $GREETING'
    echo $GREETING              # Empty! Only existed for that one command.

    # This is why you see things like:
    # DEBUG=1 ./myprogram
    # EDITOR=vim crontab -e

KEY INSIGHT: Environment = key-value pairs inherited by child processes.
`export` = "pass this down to my children."
Prefix syntax (VAR=val cmd) = "pass this to just this ONE child."

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: .bashrc, .profile, and Startup Files
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: WHERE VARIABLES ARE SET AT STARTUP ────

    # These files run automatically when you open a shell:
    cat ~/.bashrc | head -20        # Interactive non-login shells
    cat ~/.profile 2>/dev/null      # Login shells
    cat ~/.bash_profile 2>/dev/null # Login shells (alternative)

    # Order for LOGIN shells (ssh, first terminal):
    # 1. /etc/profile
    # 2. ~/.bash_profile OR ~/.bash_login OR ~/.profile (first found)

    # Order for INTERACTIVE NON-LOGIN shells (new terminal tab):
    # 1. /etc/bash.bashrc (system-wide)
    # 2. ~/.bashrc (your personal settings)

    # See what's in yours:
    grep "^export" ~/.bashrc        # Exported variables
    grep "^alias" ~/.bashrc         # Your aliases

EXPERIMENT:
    # Add something to .bashrc and reload:
    echo 'export LINUX_STUDENT="yes"' >> ~/.bashrc
    source ~/.bashrc                # Reload without opening new terminal
    echo $LINUX_STUDENT             # Should show "yes"

    # Open a NEW terminal — does it have LINUX_STUDENT?
    # Yes! Because new terminals source .bashrc

KEY INSIGHT: .bashrc = your shell's config file. Anything you want every
shell to have (aliases, PATH additions, variables) goes here.
`source ~/.bashrc` or `. ~/.bashrc` reloads it.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: Aliases
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: ALIASES — CUSTOM SHORTCUTS ────

    # See current aliases:
    alias

    # Create useful ones:
    alias ll='ls -lah'
    alias la='ls -A'
    alias ..='cd ..'
    alias ...='cd ../..'
    alias grep='grep --color=auto'
    alias ports='ss -tlnp'
    alias myip='curl -s ifconfig.me'

    # Test them:
    ll
    ..
    ports

    # Remove an alias:
    unalias ll

    # Make aliases permanent (add to ~/.bashrc):
    echo "alias ll='ls -lah'" >> ~/.bashrc

EXPERIMENT:
    # What happens if you alias a command to itself?
    alias ls='ls --color=auto'      # This is common and SAFE
    # Bash expands aliases only once, then looks up the real command

    # Dangerous (DON'T DO):
    # alias rm='rm -i'             # Why might this be dangerous?
    # Because you get used to the safety net, then on another machine
    # without the alias, you rm without thinking...

KEY INSIGHT: Aliases are typing shortcuts. They're expanded before the
command runs. Use them for common flag combinations you always want.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 5: The PS1 Prompt
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 5: CUSTOMIZE YOUR PROMPT ────

    echo $PS1                   # Your current prompt format

    # PS1 escape sequences:
    # \u = username
    # \h = hostname
    # \w = working directory (full)
    # \W = working directory (basename only)
    # \$ = $ for normal user, # for root
    # \n = newline
    # \t = time (HH:MM:SS)

    # Try these:
    PS1="\u@\h:\w\$ "          # Classic: user@host:/path$
    PS1="[\t] \W \$ "          # [14:30:22] dirname $
    PS1="\[\e[32m\]\u\[\e[0m\]:\[\e[34m\]\w\[\e[0m\]\$ "  # Colored!

    # To reset, source bashrc or open new terminal

EXPERIMENT:
    # Create a minimal prompt for screenshots:
    PS1="$ "

    # Create an informative prompt:
    PS1='[\t] \u@\h:\w\n\$ '   # Time, user@host:path on first line, $ on second

KEY INSIGHT: PS1 is just a variable. You can change it anytime.
A good prompt tells you where you are without being noisy.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. HOME=/tmp
       cd
       pwd                      # Where are you now? Can you get back?
       # Fix: HOME=/home/$USER  (or open new terminal)

    2. export PATH=""
       ls                       # Broken! But you can still use:
       /usr/bin/ls              # Full path works
       # Fix: export PATH="/usr/local/bin:/usr/bin:/bin"
       # Or: source ~/.bashrc

    3. PS1=""                   # Your prompt disappears! Can you still type?
       # Yes — you just can't see the prompt. Type: PS1='\$ '

    4. LANG=C man ls            # English regardless of system language
       LANG=fr_FR.UTF-8 man ls  # French (if locale installed)

    5. # What's the difference between these?
       MY_VAR=hello bash -c 'echo $MY_VAR'
       MY_VAR=hello; echo $MY_VAR
       export MY_VAR=hello; bash -c 'echo $MY_VAR'

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You understand environment variables, aliases, and shell config."
echo "  Next: 04_io_redirection.sh"
echo "═══════════════════════════════════════════════════════════════"
