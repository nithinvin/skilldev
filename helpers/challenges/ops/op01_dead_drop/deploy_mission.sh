#!/bin/bash
# Deploy Operation: Dead Drop
# Creates a multi-stage treasure hunt in /tmp/dead_drop_op/

set -e

BASE="/tmp/dead_drop_op"
rm -rf "$BASE"

echo "[*] Deploying Dead Drop operation..."

# ============================================================
# STAGE 1: The Entry Point
# A public notice with a Base64-encoded hint
# ============================================================
mkdir -p "$BASE/public"
cat > "$BASE/public/notice.txt" << 'EOF'
COMMUNITY NOTICE BOARD
======================
Lost: one orange tabby cat. Answers to "Whiskers".
For sale: slightly used keyboard. Keys still mostly work.
Found: USB drive in parking lot B. Contents unknown.

## MAINTENANCE NOTE (IGNORE) ##
System backup location: L3RtcC9kZWFkX2Ryb3Bfb3Avc3RhZ2UyLw==
Next rotation: 2024-03-15
Contact: ops@internal.local
EOF

# ============================================================
# STAGE 2: Hidden directory with a file requiring permissions fix
# The Base64 above decodes to: /tmp/dead_drop_op/stage2/
# ============================================================
mkdir -p "$BASE/stage2"
chmod 711 "$BASE/stage2"  # Can enter but can't list

cat > "$BASE/stage2/intel.gpg" << 'EOF'
-----BEGIN ENCRYPTED MESSAGE-----
This isn't real GPG. But it LOOKS like it.
The actual intel is in a hidden file in this directory.
Don't forget: files starting with . are hidden.
-----END ENCRYPTED MESSAGE-----
EOF

# The real clue is in a hidden file
cat > "$BASE/stage2/.actual_intel" << 'EOF'
STAGE 2 COMPLETE.

The next dead drop is protected by a passphrase.
File: /tmp/dead_drop_op/stage3/encrypted.txt
Passphrase hint: The XOR of each byte with 0x42

Encrypted next-stage path (XOR each byte with 0x42, result is ASCII):
36 2e 2b 72 24 27 23 24 72 26 30 2f 2b 72 13 16 11 19 17 72 11 2e 2d 2b 2c 27 36 27 24
EOF

# ============================================================
# STAGE 3: XOR "encryption" (the bytes above XOR 0x42 = /tmp/dead_drop_op/stage3/encrypted)
# Actually let's make it simpler — the path is given, just need the password
# ============================================================
mkdir -p "$BASE/stage3"

# Password is hidden in environment of a running process
# Create a script that holds the key in memory
cat > "$BASE/stage3/keyserver.sh" << 'SCRIPT'
#!/bin/bash
# This process holds the decryption key in its environment
export DEAD_DROP_KEY="nautilus"
while true; do sleep 3600; done
SCRIPT
chmod +x "$BASE/stage3/keyserver.sh"

# Start the keyserver in background
DEAD_DROP_KEY="nautilus" bash -c 'exec -a "[thermal_monitor]" sleep 86400' &
KEYSERVER_PID=$!
echo $KEYSERVER_PID > "$BASE/stage3/.keyserver_pid"

# The "encrypted" file (openssl enc simulation — actually just base64 of the flag path)
# Password is "nautilus" — find it in /proc/<pid>/environ
cat > "$BASE/stage3/encrypted.txt" << 'EOF'
This file is "encrypted" with a simple substitution.
The key is held by a running process (look for [thermal_monitor]).
Check its /proc/<PID>/environ for DEAD_DROP_KEY.

Once you have the key, the next stage is at:
/tmp/dead_drop_op/stage4/

But stage4 has a file that requires the key to decode:
echo "bmF1dGlsdXM=" | base64 -d  (this is just a verification)

The REAL puzzle in stage4: find the flag hidden in network data.
EOF

# ============================================================
# STAGE 4: Network forensics (simplified — a captured "packet" in text)
# ============================================================
mkdir -p "$BASE/stage4"

cat > "$BASE/stage4/capture.log" << 'EOF'
# Network capture log - suspicious traffic detected
# Timestamp: 2024-03-14T02:14:00Z

PACKET 001: SYN  192.168.1.100:44231 -> 10.0.0.5:443
PACKET 002: SYN-ACK 10.0.0.5:443 -> 192.168.1.100:44231
PACKET 003: ACK  192.168.1.100:44231 -> 10.0.0.5:443
PACKET 004: DATA 192.168.1.100:44231 -> 10.0.0.5:443 | GET /api/exfil?data=RkxBR3tuZXR3b3JrX2ZvcmVuc2ljc19maW5kX3RoZV9leGZpbHRyYXRpb259 HTTP/1.1
PACKET 005: DATA 10.0.0.5:443 -> 192.168.1.100:44231 | HTTP/1.1 200 OK
PACKET 006: FIN  192.168.1.100:44231 -> 10.0.0.5:443
PACKET 007: DATA 192.168.1.50:8080 -> 10.0.0.5:443 | POST /upload Content-Type: application/json {"status":"delivered"}
PACKET 008: RST  10.0.0.5:443 -> 192.168.1.50:8080

# Analyst note: one of these packets contains exfiltrated data.
# The data parameter is base64 encoded. Decode it for the stage flag.
# 
# After finding the flag, proceed to /tmp/dead_drop_op/stage5/
EOF

# ============================================================
# STAGE 5: Final — Assembly
# ============================================================
mkdir -p "$BASE/stage5"

# Split the final flag across multiple files using different techniques
echo "RkxBR3tkZWFk" > "$BASE/stage5/part1.b64"
echo "7072 6f70 5f6f 7065 7261 7469 6f6e" > "$BASE/stage5/part2.hex"  
echo "X2NvbXBsZXRlX3lvdV9hcmVfYV9naG9zdH0=" > "$BASE/stage5/part3.b64"

cat > "$BASE/stage5/README.txt" << 'EOF'
FINAL STAGE: Assembly Required

Three parts of the final flag are in this directory:
- part1.b64 (base64 fragment)
- part2.hex (hex-encoded fragment)  
- part3.b64 (base64 fragment)

Decode each and concatenate them in order: part1 + part2 + part3

The combined text is the final operation flag.

Congratulations, Agent. You've completed the Dead Drop.
EOF

# ============================================================
# BONUS: Hidden flag in the deploy script itself
# ============================================================
# FLAG{you_read_the_source_code_thats_called_recon}

echo "[+] Dead Drop deployed successfully!"
echo "[+] Start at: /tmp/dead_drop_op/public/notice.txt"
echo "[+] Good hunting, Agent."
echo ""
echo "[*] Note: A background process is running for Stage 3."
echo "    It will be cleaned up when you find and kill it (that's part of the challenge!)"
