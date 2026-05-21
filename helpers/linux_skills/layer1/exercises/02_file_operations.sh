#!/bin/bash
# =============================================================================
# Layer 1, Exercise 2: FILE OPERATIONS
# =============================================================================
# THEORY-IN-ACTION: Creating, copying, moving, finding, and destroying files.
# These are your daily-driver commands. Master them and the terminal becomes
# faster than any file manager.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 2: File Operations — Create, Copy, Move, Find, Destroy"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ---------------------------------------------------------------------------
# PART 1: Creating Files and Directories
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 1: CREATING ────

    # Setup a playground:
    mkdir -p /tmp/linux_lab/playground
    cd /tmp/linux_lab/playground

    # Create empty files:
    touch file1.txt file2.txt file3.txt
    ls -la                      # All have 0 bytes

    # touch on existing file = update timestamp (doesn't change content):
    sleep 2 && touch file1.txt
    ls -lt                      # file1.txt is now "newest"

    # Create with content:
    echo "Hello" > greeting.txt
    printf "Line1\nLine2\nLine3\n" > lines.txt
    cat > multi.txt << 'EOF'
This is line 1
This is line 2
This is line 3
EOF

    # Create directory trees in one shot:
    mkdir -p project/{src,tests,docs}/{v1,v2}
    tree project/               # 6 directories created!

    # Brace expansion is powerful:
    touch project/src/{main,utils,config}.py
    touch project/tests/test_{main,utils}.py
    tree project/

EXPERIMENT:
    # Create 100 files quickly:
    touch file_{001..100}.txt
    ls | wc -l                  # 100+ files!
    rm file_{001..100}.txt      # Clean up

    # Create a deep directory:
    mkdir -p a/b/c/d/e/f/g
    tree a/

KEY INSIGHT: `mkdir -p` creates parent directories. Brace expansion {}
generates combinations. These two together let you scaffold projects instantly.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 2: Copying
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 2: COPYING (cp) ────

    cd /tmp/linux_lab/playground

    # Basic copy:
    cp greeting.txt greeting_backup.txt
    cat greeting_backup.txt     # Same content

    # Copy multiple files to a directory:
    mkdir backups/
    cp file1.txt file2.txt file3.txt backups/
    ls backups/

    # Copy directory (MUST use -r for recursive):
    cp project/ project_backup/     # ERROR! (without -r)
    cp -r project/ project_backup/  # Works!

    # Preserve permissions and timestamps:
    cp -a project/ project_archive/  # -a = archive (preserves everything)

    # Interactive (ask before overwriting):
    cp -i greeting.txt greeting_backup.txt   # Prompts if exists

    # Verbose (show what's being copied):
    cp -rv project/ project_copy/

EXPERIMENT:
    # Copy and rename in one step:
    cp greeting.txt /tmp/hello_copy.txt

    # What happens when you cp a symlink?
    ln -s greeting.txt link_to_greeting
    cp link_to_greeting copied_link         # Copies the TARGET file!
    cp -P link_to_greeting preserved_link   # Copies the LINK itself

    # Difference?
    ls -la copied_link preserved_link link_to_greeting

KEY INSIGHT: cp copies DATA by default. For directories use -r.
For "exact clone" use -a (preserves permissions, timestamps, links).
cp FOLLOWS symlinks unless you use -P.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 3: Moving and Renaming
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 3: MOVING & RENAMING (mv) ────

    cd /tmp/linux_lab/playground

    # Rename (mv within same directory = rename):
    mv greeting.txt hello.txt
    ls hello.txt                # Renamed!

    # Move to another directory:
    mv hello.txt backups/
    ls backups/hello.txt        # Moved!

    # Move multiple files:
    mv file1.txt file2.txt backups/

    # Move a directory (no -r needed, unlike cp!):
    mv project_copy/ backups/project_copy/

    # Rename with backup:
    echo "old content" > data.txt
    echo "new content" > data_new.txt
    mv --backup=numbered data_new.txt data.txt
    ls data.txt*                # data.txt and data.txt.~1~ (backup!)

EXPERIMENT:
    # What happens when you mv across filesystems?
    # (if /tmp and /home are different mounts)
    # mv copies + deletes in that case (slower than same-filesystem mv)

    # mv is atomic on same filesystem — great for safe file updates:
    echo "new config" > /tmp/config.new
    mv /tmp/config.new /tmp/config.txt   # Instant, no partial writes!

KEY INSIGHT: mv on same filesystem = instant (just updates directory entry).
mv across filesystems = copy + delete (slower, but same result).
mv is how you do SAFE file updates — write new file, then mv over old one.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 4: Deleting
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 4: DELETING (rm, rmdir) ────

    cd /tmp/linux_lab/playground

    # Delete a file:
    touch deleteme.txt
    rm deleteme.txt             # Gone. No trash can. No undo.

    # Delete with confirmation:
    touch careful.txt
    rm -i careful.txt           # Asks "are you sure?"

    # Delete empty directory:
    mkdir empty_dir/
    rmdir empty_dir/            # Only works if EMPTY
    # rm -d empty_dir/          # Alternative

    # Delete directory with contents:
    rm -r project_backup/       # Recursive delete

    # DANGEROUS COMMANDS (understand but be careful):
    # rm -rf /tmp/linux_lab/    # Force recursive, no questions asked
    # NEVER run: rm -rf /       # This would destroy your system
    # NEVER run: rm -rf ~       # This destroys your home directory

    # Safer alternative: move to trash
    mkdir -p ~/.trash
    mv file3.txt ~/.trash/      # "Deleted" but recoverable

EXPERIMENT:
    # What does rm actually do?
    echo "data" > /tmp/testfile
    ls -i /tmp/testfile         # Note the inode number
    rm /tmp/testfile            # Removes the directory entry (link)
    # If no more links point to the inode, the space is freed
    # But if the file is OPEN by a process, the space isn't freed yet!

    # Demonstrate:
    exec 3>/tmp/openfile        # Open fd 3 to a file
    rm /tmp/openfile            # Delete it
    ls /tmp/openfile            # Gone from directory!
    echo "ghost write" >&3      # But we can still write to it!
    ls -la /proc/$$/fd/3        # The fd still exists
    exec 3>&-                   # Close fd — NOW the space is freed

KEY INSIGHT: rm removes the LINK (name), not the data. Data is freed
only when the last link AND last file descriptor are gone. This is why
disk space sometimes doesn't free up until you restart a service.

INSTRUCTIONS

# ---------------------------------------------------------------------------
# PART 5: Finding Files
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── PART 5: find — THE MOST POWERFUL SEARCH TOOL ────

    # Find by name:
    find /etc -name "*.conf" 2>/dev/null | head -10
    find /usr -name "python*" 2>/dev/null | head -10

    # Find by type:
    find /tmp -type f               # Regular files only
    find /tmp -type d               # Directories only
    find /dev -type l | head -10    # Symbolic links

    # Find by size:
    find /var -size +10M 2>/dev/null | head -10     # Bigger than 10MB
    find /tmp -size -1k             # Smaller than 1KB
    find / -size +100M -type f 2>/dev/null | head   # Big files

    # Find by time:
    find /tmp -mtime -1             # Modified in last 24 hours
    find /var/log -mmin -60         # Modified in last 60 minutes
    find ~ -atime +30 -type f       # Not accessed in 30 days

    # Find by permissions:
    find /usr/bin -perm -4000       # SUID files (security important!)
    find / -perm -o+w -type f 2>/dev/null | head    # World-writable files

    # Combine with actions:
    find /tmp -name "*.tmp" -delete         # Delete matching files
    find . -name "*.py" -exec wc -l {} \;   # Count lines in each
    find . -name "*.py" -exec grep -l "import" {} \;  # Which import something?

    # -exec vs xargs:
    find . -name "*.txt" -exec cat {} \;        # One cat per file (slow)
    find . -name "*.txt" -print0 | xargs -0 cat # One cat for all (fast)
    # -print0 and -0 handle filenames with spaces/newlines safely

EXPERIMENT:
    # Create test files and find them:
    cd /tmp/linux_lab/playground
    touch old_file.txt && touch -d "2 months ago" old_file.txt
    find . -mtime +30 -name "*.txt"    # Should find old_file.txt

    # Find duplicate filenames:
    find / -name "python3" 2>/dev/null  # Multiple locations!

    # locate (faster but uses database, might not be installed):
    # sudo apt install mlocate && sudo updatedb
    # locate python3                     # Instant search!

KEY INSIGHT: find walks the directory tree and tests each entry against
your criteria. It's slow on huge trees but finds ANYTHING.
Use `locate` for instant filename search (pre-built index).

INSTRUCTIONS

# ---------------------------------------------------------------------------
# BREAK IT
# ---------------------------------------------------------------------------
cat << 'INSTRUCTIONS'

──── BREAK IT (Experiments) ────

    1. # Can you delete a file that's currently being read?
       cat /etc/passwd > /tmp/reading_test.txt
       tail -f /tmp/reading_test.txt &   # Reading it in background
       rm /tmp/reading_test.txt          # Delete it
       # Is tail still running? What's it reading?
       kill %1

    2. # What happens with circular symlinks?
       cd /tmp
       ln -s link_b link_a
       ln -s link_a link_b
       cat link_a                        # "Too many levels of symbolic links"

    3. # Hard link across filesystems:
       ln /tmp/some_file /home/crosslink  # Might fail! Why?
       # Hard links can't cross filesystem boundaries (different inode tables)

    4. # What's in a directory entry?
       # A directory is just a file containing: (inode_number, filename) pairs
       # You can't open it with cat (special file type), but:
       ls -lai /tmp | head -10          # -i shows inode numbers

    5. # Self-referential:
       cd /tmp/linux_lab/playground
       ln -s . self
       ls self/self/self/self/           # It works! How deep can you go?

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can create, copy, move, find, and destroy files efficiently."
echo "  Next: 03_permissions.sh"
echo "═══════════════════════════════════════════════════════════════"
