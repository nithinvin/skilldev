#!/bin/bash
# =============================================================================
# Layer 1, Exercise 3: PERMISSIONS
# =============================================================================
# THEORY-IN-ACTION: Permissions answer three questions for every file:
# WHO can do WHAT to it? This is the foundation of Linux security.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 3: Permissions — Who Can Do What"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: Reading Permission Strings
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: DECODE THE PERMISSION STRING ────

    ls -la /etc/passwd
    # Output: -rw-r--r-- 1 root root 2887 Jan 15 10:30 /etc/passwd
    #         │├──┤├──┤├──┤
    #         │ │   │   └── Others: r-- (read only)
    #         │ │   └────── Group:  r-- (read only)
    #         │ └────────── Owner:  rw- (read + write)
    #         └──────────── Type:   - (regular file)

    # File types (first character):
    # -  = regular file
    # d  = directory
    # l  = symbolic link
    # c  = character device
    # b  = block device
    # p  = named pipe
    # s  = socket

    # Permission meanings for FILES:
    # r (read)    = can view contents (cat, less)
    # w (write)   = can modify contents (edit, truncate)
    # x (execute) = can run as a program

    # Permission meanings for DIRECTORIES:
    # r (read)    = can list contents (ls)
    # w (write)   = can create/delete files inside
    # x (execute) = can enter (cd) and access files inside

RUN:
    # Compare these:
    ls -la /etc/shadow          # -rw-r----- (only root and shadow group)
    ls -la /etc/passwd          # -rw-r--r-- (everyone can read)
    ls -la /usr/bin/passwd      # -rwsr-xr-x (notice the 's'!)
    ls -la /tmp                 # drwxrwxrwt (notice the 't'!)

EXPERIMENT:
    mkdir -p /tmp/perm_lab && cd /tmp/perm_lab

    # Create a file and examine:
    echo "secret" > myfile.txt
    ls -la myfile.txt
    stat myfile.txt             # Even more detail (octal permissions too)

KEY INSIGHT: Three WHO's (owner, group, others) × three WHAT's (read, write, execute)
= 9 permission bits. Plus special bits (setuid, setgid, sticky).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Changing Permissions (chmod)
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: chmod — CHANGE PERMISSIONS ────

    cd /tmp/perm_lab

    # SYMBOLIC MODE: chmod who+/-/=what file
    # who: u=user/owner, g=group, o=others, a=all
    echo "test" > testfile.txt

    chmod u+x testfile.txt          # Add execute for owner
    ls -la testfile.txt             # -rwxr--r--

    chmod g+w testfile.txt          # Add write for group
    ls -la testfile.txt             # -rwxrw-r--

    chmod o-r testfile.txt          # Remove read from others
    ls -la testfile.txt             # -rwxrw----

    chmod a=r testfile.txt          # SET all to read-only
    ls -la testfile.txt             # -r--r--r--

    chmod u+w testfile.txt          # Owner needs write back!

    # OCTAL MODE: chmod NNN file
    # Each digit = owner/group/others
    # 4=read, 2=write, 1=execute (add them up)
    # 7=rwx, 6=rw-, 5=r-x, 4=r--, 0=---

    chmod 755 testfile.txt          # rwxr-xr-x (common for executables)
    chmod 644 testfile.txt          # rw-r--r-- (common for regular files)
    chmod 600 testfile.txt          # rw------- (private file)
    chmod 700 testfile.txt          # rwx------ (private executable/directory)

    # Common patterns:
    # 755 = programs, scripts, directories
    # 644 = regular files
    # 600 = private files (SSH keys!)
    # 777 = AVOID (anyone can do anything)

EXPERIMENT:
    # What happens when you remove your own read permission?
    echo "can you read me?" > locked.txt
    chmod 000 locked.txt
    cat locked.txt              # Permission denied! (even as owner)
    chmod 644 locked.txt        # Fix it (owner can always chmod their files)

    # Recursive chmod:
    mkdir -p myproject/{src,tests}
    touch myproject/src/app.py myproject/tests/test.py
    chmod -R 755 myproject/     # All files AND dirs get 755
    # But wait — files probably shouldn't be executable...
    find myproject/ -type f -exec chmod 644 {} \;  # Fix files
    find myproject/ -type d -exec chmod 755 {} \;  # Keep dirs

KEY INSIGHT: Octal is faster to type: 644, 755, 600. Symbolic is easier to
understand: u+x, g-w. Use whichever you can remember.
For directories: x means "can enter". Without x, even ls won't work!

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Ownership (chown, chgrp)
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: WHO OWNS WHAT ────

    cd /tmp/perm_lab

    # See ownership:
    ls -la testfile.txt         # Shows owner and group

    # Every file has:
    # - An OWNER (a user) — default: whoever created it
    # - A GROUP — default: creator's primary group

    # See your user and groups:
    id                          # uid, gid, and all groups
    groups                      # Just group names
    whoami                      # Just username

    # Change owner (requires root):
    sudo chown root testfile.txt
    ls -la testfile.txt         # Owner is now root
    # Can you still edit it? (depends on group/other permissions)

    # Change group:
    sudo chgrp root testfile.txt
    ls -la testfile.txt

    # Change both at once:
    sudo chown $USER:$USER testfile.txt    # Back to you

    # Recursive:
    sudo chown -R $USER:$USER myproject/

EXPERIMENT:
    # Create a shared directory:
    sudo mkdir /tmp/shared_project
    sudo chown root:$USER /tmp/shared_project
    sudo chmod 775 /tmp/shared_project
    # Now: root owns it, but your group can write to it!
    touch /tmp/shared_project/myfile    # Should work (you're in the group)

KEY INSIGHT: Ownership determines WHICH permission set applies to you.
If you're the owner → owner bits. If you're in the group → group bits.
Otherwise → other bits. The kernel checks in this order.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: umask — Default Permissions
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: umask — WHY NEW FILES GET SPECIFIC PERMISSIONS ────

    # When you create a file, what permissions does it get?
    touch /tmp/perm_lab/newfile
    ls -la /tmp/perm_lab/newfile    # Probably -rw-r--r-- (644)
    mkdir /tmp/perm_lab/newdir
    ls -ld /tmp/perm_lab/newdir     # Probably drwxr-xr-x (755)

    # umask SUBTRACTS from the maximum:
    # Maximum for files: 666 (never executable by default)
    # Maximum for dirs:  777
    # Your umask:
    umask                       # Probably 0022

    # 666 - 022 = 644 (that's why files get rw-r--r--)
    # 777 - 022 = 755 (that's why dirs get rwxr-xr-x)

    # Change umask (for this shell session):
    umask 077                   # Maximum privacy
    touch /tmp/perm_lab/private_file
    ls -la /tmp/perm_lab/private_file    # -rw------- (600!)
    mkdir /tmp/perm_lab/private_dir
    ls -ld /tmp/perm_lab/private_dir     # drwx------ (700!)

    # Reset:
    umask 022                   # Back to normal

EXPERIMENT:
    # What umask would give files 664 and dirs 775?
    # 666 - ??? = 664 → umask = 002
    # 777 - 002 = 775 ✓
    umask 002
    touch /tmp/perm_lab/test_umask
    ls -la /tmp/perm_lab/test_umask     # -rw-rw-r-- (664)

    umask 022   # Reset

KEY INSIGHT: umask controls DEFAULT permissions for new files/dirs.
It's a MASK (what to REMOVE), not what to SET.
Set in ~/.bashrc for permanent change.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 5: Special Permissions (setuid, setgid, sticky)
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 5: SPECIAL BITS — SETUID, SETGID, STICKY ────

    # SETUID (4): When a file is executed, it runs as the FILE OWNER (not the user)
    ls -la /usr/bin/passwd      # -rwsr-xr-x (notice the 's' in owner execute)
    # passwd needs to write to /etc/shadow (owned by root)
    # setuid makes it run AS ROOT even when you run it!
    # This is why normal users can change their own passwords.

    # SETGID (2) on file: runs as the file's group
    # SETGID (2) on directory: new files inherit the directory's group
    mkdir /tmp/perm_lab/team_dir
    chmod 2775 /tmp/perm_lab/team_dir
    ls -ld /tmp/perm_lab/team_dir       # drwxrwsr-x (notice 's' in group execute)
    # Any file created inside inherits the directory's group — useful for teams!

    # STICKY BIT (1): Only file owner can delete files in this directory
    ls -ld /tmp                 # drwxrwxrwt (notice 't' at the end)
    # /tmp is world-writable, but you can only delete YOUR files!
    # Without sticky bit, anyone could delete anyone's temp files.

    # Setting special bits:
    chmod 4755 myfile           # setuid + rwxr-xr-x
    chmod 2755 mydir            # setgid + rwxr-xr-x
    chmod 1777 shared_dir      # sticky + rwxrwxrwx

    # Or symbolic:
    chmod u+s myfile            # setuid
    chmod g+s mydir             # setgid
    chmod +t shared_dir         # sticky

    # SECURITY: Find all setuid binaries (potential privilege escalation):
    find / -perm -4000 -type f 2>/dev/null | head -20

EXPERIMENT:
    # Test sticky bit:
    sudo mkdir /tmp/perm_lab/sticky_test
    sudo chmod 1777 /tmp/perm_lab/sticky_test
    touch /tmp/perm_lab/sticky_test/my_file
    # If another user tried to delete my_file, they'd be denied!

KEY INSIGHT:
- setuid = "run as the file's owner" (security risk if misused!)
- setgid on dir = "new files inherit group" (great for team folders)
- sticky = "only owner can delete" (essential for /tmp)
These are SECURITY-CRITICAL. A rogue setuid binary = root compromise.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # Remove execute from a directory:
       mkdir /tmp/perm_lab/no_enter
       touch /tmp/perm_lab/no_enter/secret.txt
       chmod 644 /tmp/perm_lab/no_enter     # rw-r--r-- (no x!)
       ls /tmp/perm_lab/no_enter/           # Can you list it?
       cat /tmp/perm_lab/no_enter/secret.txt # Can you read files inside?
       cd /tmp/perm_lab/no_enter/           # Can you enter it?
       chmod 755 /tmp/perm_lab/no_enter     # Fix it

    2. # What if a file is writable but the directory isn't?
       mkdir /tmp/perm_lab/readonly_dir
       touch /tmp/perm_lab/readonly_dir/file.txt
       chmod 555 /tmp/perm_lab/readonly_dir  # r-xr-xr-x
       echo "new content" > /tmp/perm_lab/readonly_dir/file.txt  # Can you write?
       rm /tmp/perm_lab/readonly_dir/file.txt  # Can you delete?
       chmod 755 /tmp/perm_lab/readonly_dir  # Fix it

    3. # The root user ignores most permissions:
       chmod 000 /tmp/perm_lab/testfile.txt
       sudo cat /tmp/perm_lab/testfile.txt   # Works! Root bypasses permissions.
       # (except execute — root still needs +x to run scripts)

    4. # Numeric permission quiz:
       # What is: rwxr-x--- in octal?   Answer: 750
       # What is: 640 in symbolic?       Answer: rw-r-----
       # What is: rws--x--x in octal?   Answer: 4711

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You understand the Linux permission model completely."
echo "  Next: 04_links_and_inodes.sh"
echo "═══════════════════════════════════════════════════════════════"
