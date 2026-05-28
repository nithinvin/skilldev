#!/bin/bash
# Spawns the ghost process for the CTF challenge

# The ghost — disguised as a system service name
python3 "$(dirname "$0")/ghost_payload.py" &
GHOST_PID=$!
disown $GHOST_PID

echo "[*] Ghost spawned. It's hiding somewhere in your process list."
echo "[*] Its name won't be 'ghost_payload.py' in the process list..."
echo "[*] Use your Linux skills to hunt it down."
echo ""
echo "[*] Remember: the flag exists ONLY while the ghost is alive."
echo "[*] Read it first. THEN kill the ghost."
