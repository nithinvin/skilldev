#!/bin/bash
# Setup script for The Locked Room challenge
# Run this ONCE to create the challenge environment

echo "[*] Setting up The Locked Room..."

# Create the vault directory
mkdir -p vault/inner

# Flag 1: Inside a directory you can't enter
echo "FLAG{execute_permission_on_directories_means_traverse}" > vault/flag1.txt

# Flag 2: File you can see but can't read
echo "FLAG{read_permission_is_separate_from_list_permission}" > vault/inner/flag2.txt

# A red herring
echo "This is not the flag. But the permission on this file is a clue." > vault/inner/readme.txt
echo "The octal permission of this file, when converted to ASCII, gives you a bonus word." >> vault/inner/readme.txt

# Set permissions to create the puzzle
# Remove execute from vault/ — can't cd into it!
chmod 644 vault/
# vault/inner gets no read for others
chmod 711 vault/inner
# flag1 is readable but vault blocks access
chmod 644 vault/flag1.txt
# flag2 needs you to figure out the path
chmod 600 vault/inner/flag2.txt
# readme is world-readable
chmod 604 vault/inner/readme.txt

echo "[*] Challenge ready!"
echo "[*] Start with: ls -la vault/"
echo ""
echo "HINT: Why can't you 'cd vault/' even though you can see it?"
echo "HINT: What does the 'x' permission mean on a DIRECTORY?"
echo ""
echo "Reminder: chmod can ADD permissions. chmod +x adds execute."
echo "But think about WHAT you're adding and to WHOM."
