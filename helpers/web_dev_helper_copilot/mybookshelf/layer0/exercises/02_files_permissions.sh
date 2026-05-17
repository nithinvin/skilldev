#!/bin/bash
# =============================================================================
# Level 0.2 — Files, Permissions, Users
# =============================================================================
#
# QUESTIONS (answer these BEFORE running):
#
#   1. What do the permission bits rwxr-xr-- mean?
#      rwx = owner can read, write, execute
#      r-x = group can read and execute (not write)
#      r-- = others can only read
#      Numerically: 7 (rwx) 5 (r-x) 4 (r--) = 754
#
#   2. Why does Linux have users and groups?
#      - Isolation: your files are yours, not mine
#      - Least privilege: web server runs as www-data, can't read /root
#      - Collaboration: group members share access without giving it to everyone
#
#   3. What is an inode?
#      - A data structure on disk that stores file METADATA
#        (size, permissions, timestamps, location of data blocks)
#      - A filename is just a directory entry pointing to an inode
#      - One inode can have MULTIPLE names (hard links)
#
#   4. Hard link vs symbolic link?
#      - Hard link = another name pointing to the SAME inode
#        (deleting original doesn't break it — data still has a reference)
#      - Symbolic link = a file that contains a PATH to another file
#        (deleting original BREAKS it — the path becomes dangling)
#
#   5. Why can't a normal user listen on port 80?
#      - Ports < 1024 are "privileged ports" — need root or CAP_NET_BIND_SERVICE
#      - Historical Unix security: prevents non-root from impersonating system services
#      - That's why nginx runs as root (to bind port 80) then drops to www-data
#
# =============================================================================

set -e

WORK_DIR="/tmp/layer0_files"

echo "============================================"
echo "  Level 0.2 — Files, Permissions, Users"
echo "============================================"
echo ""

# Clean up from previous runs
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

# --- Exercise 1: Create files and examine permissions ---
echo ">>> Exercise 1: File permissions"
touch "$WORK_DIR/public.txt"
touch "$WORK_DIR/private.txt"
touch "$WORK_DIR/script.sh"

chmod 644 "$WORK_DIR/public.txt"    # rw-r--r-- (everyone can read, owner can write)
chmod 600 "$WORK_DIR/private.txt"   # rw------- (only owner can read/write)
chmod 755 "$WORK_DIR/script.sh"     # rwxr-xr-x (owner: all, others: read+execute)

echo "  File permissions:"
ls -la "$WORK_DIR/"
echo ""
echo "  KEY: First char is file type (- = file, d = dir, l = symlink)"
echo "  Then 3 groups of 3: owner | group | other"
echo ""

# --- Exercise 2: Numeric permissions ---
echo ">>> Exercise 2: Understanding numeric permissions"
echo "  r=4, w=2, x=1"
echo "  chmod 644 = rw-r--r-- = (4+2)(4)(4)"
echo "  chmod 755 = rwxr-xr-x = (4+2+1)(4+1)(4+1)"
echo "  chmod 600 = rw------- = (4+2)(0)(0)"
echo ""
echo "  Current file permissions (stat shows octal):"
stat -c "  %n: %a (%A)" "$WORK_DIR/public.txt"
stat -c "  %n: %a (%A)" "$WORK_DIR/private.txt"
stat -c "  %n: %a (%A)" "$WORK_DIR/script.sh"
echo ""

# --- Exercise 3: Inodes ---
echo ">>> Exercise 3: Inodes — the REAL file identity"
echo "some secret data" > "$WORK_DIR/original.txt"
echo ""
echo "  File with inode number (the -i flag):"
ls -li "$WORK_DIR/original.txt"
echo ""
echo "  Full inode info via stat:"
stat "$WORK_DIR/original.txt"
echo ""
echo "  KEY: The inode number is the TRUE identity of the file."
echo "  The filename is just a label (directory entry) pointing to it."
echo ""

# --- Exercise 4: Hard links vs Symbolic links ---
echo ">>> Exercise 4: Hard links vs Symbolic links"
echo ""

# Create both types
ln "$WORK_DIR/original.txt" "$WORK_DIR/hardlink.txt"
ln -s "$WORK_DIR/original.txt" "$WORK_DIR/symlink.txt"

echo "  Three entries, two types of links:"
ls -li "$WORK_DIR/original.txt" "$WORK_DIR/hardlink.txt" "$WORK_DIR/symlink.txt"
echo ""
echo "  NOTICE: original.txt and hardlink.txt have the SAME inode number!"
echo "  NOTICE: symlink.txt has a DIFFERENT inode and starts with 'l'"
echo "  NOTICE: original.txt now shows '2' for link count (2 names → 1 inode)"
echo ""

# Read through all three
echo "  Content via original:  $(cat "$WORK_DIR/original.txt")"
echo "  Content via hardlink:  $(cat "$WORK_DIR/hardlink.txt")"
echo "  Content via symlink:   $(cat "$WORK_DIR/symlink.txt")"
echo ""

# Now delete the original
echo "  --- Deleting original.txt ---"
rm "$WORK_DIR/original.txt"
echo ""

echo "  Does hardlink still work?"
if cat "$WORK_DIR/hardlink.txt" 2>/dev/null; then
    echo "  ✅ YES! Hard link still works (data still has a reference via this inode)"
fi
echo ""

echo "  Does symlink still work?"
if cat "$WORK_DIR/symlink.txt" 2>/dev/null; then
    echo "  ✅ Yes"
else
    echo "  ❌ NO! Symlink is BROKEN (it points to a path that no longer exists)"
    echo "  This is called a 'dangling symlink'"
    ls -la "$WORK_DIR/symlink.txt"
fi
echo ""

# --- Exercise 5: User and group info ---
echo ">>> Exercise 5: Users and Groups"
echo "  Your user ID info:"
id
echo ""
echo "  Your entry in /etc/passwd:"
grep "$(whoami)" /etc/passwd || echo "  (not found in /etc/passwd — might be in LDAP/NIS)"
echo ""
echo "  Your groups:"
groups
echo ""
echo "  /etc/passwd format: username:x:UID:GID:comment:home:shell"
echo "  The 'x' means password is in /etc/shadow (which only root can read)"
echo ""

# --- Exercise 6: Directory permissions ---
echo ">>> Exercise 6: Directory permissions are DIFFERENT"
mkdir -p "$WORK_DIR/testdir"
echo "data" > "$WORK_DIR/testdir/file.txt"
echo ""
echo "  For directories:"
echo "  r = can LIST contents (ls)"
echo "  w = can CREATE/DELETE files inside"
echo "  x = can ENTER the directory (cd) and access files by name"
echo ""
echo "  Remove execute permission from a directory:"
chmod 644 "$WORK_DIR/testdir"   # rw-r--r-- (no x!)
echo "  Permissions: $(stat -c '%A' "$WORK_DIR/testdir")"
echo ""
echo "  Can we list it? (r is set, so yes)"
ls "$WORK_DIR/testdir" 2>&1 || true
echo ""
echo "  Can we read a file inside? (x is not set, so no!)"
cat "$WORK_DIR/testdir/file.txt" 2>&1 || echo "  ❌ Permission denied! Need 'x' on directory to access files inside"
echo ""
# Restore so cleanup works
chmod 755 "$WORK_DIR/testdir"
echo ""

# --- Exercise 7: Special permissions ---
echo ">>> Exercise 7: Special bits (setuid, setgid, sticky)"
echo ""
echo "  setuid (s on owner): program runs as file OWNER, not the user"
echo "  Example: /usr/bin/passwd has setuid — runs as root so it can edit /etc/shadow"
ls -la /usr/bin/passwd 2>/dev/null || echo "  (passwd not found)"
echo ""
echo "  sticky bit (t on other): only file OWNER can delete files in this dir"
echo "  Example: /tmp has sticky bit — you can't delete other users' files"
ls -ld /tmp
echo ""

echo "============================================"
echo "  BREAK IT — Try these yourself:"
echo "============================================"
echo ""
echo "  1. chmod 000 somefile && cat somefile"
echo "     → Permission denied (even as owner!)"
echo "     → Fix: chmod 644 somefile"
echo ""
echo "  2. Create a file as your user, try to delete it as another user"
echo "     → Shows why /tmp has the sticky bit"
echo ""
echo "  3. Find all setuid binaries on your system:"
echo "     find / -perm -4000 -type f 2>/dev/null"
echo "     → These are security-sensitive! Any of them could be privilege escalation vectors"
echo ""
echo "============================================"
echo "  ✅ Level 0.2 Complete"
echo "  Next: Run 03_networking.sh"
echo "============================================"

# Cleanup
rm -rf "$WORK_DIR"
