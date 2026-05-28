#!/usr/bin/env python3
"""Ghost process — disguises itself and writes flag to a temp file."""
import os
import sys
import time
import signal
import tempfile
import ctypes

# Disguise: change process name to look like a system daemon
try:
    # Try to rename process (Linux-specific)
    libc = ctypes.CDLL("libc.so.6")
    name = b"[kworker/u8:2]"  # Looks like a kernel worker thread
    libc.prctl(15, name, 0, 0, 0)  # PR_SET_NAME = 15
except Exception:
    pass

# Also rename in /proc/self/comm
try:
    with open("/proc/self/comm", "w") as f:
        f.write("[kworker/u8:2]")
except Exception:
    pass

# Modify sys.argv to hide the real script name
sys.argv[0] = "[kworker/u8:2]"

# Write flag to a temp file (deleted on exit)
flag_file = tempfile.NamedTemporaryFile(
    mode='w', prefix='.ghost_', suffix='.tmp',
    dir='/tmp', delete=False
)
flag_file.write("FLAG{proc_filesystem_reveals_all_secrets}\n")
flag_file.write(f"\nGhost PID: {os.getpid()}\n")
flag_file.write(f"Flag file: {flag_file.name}\n")
flag_file.write(f"\nTo verify your kill: this file will disappear after SIGTERM.\n")
flag_file.flush()

# Cleanup function — removes the flag when killed properly
def cleanup(signum, frame):
    try:
        os.unlink(flag_file.name)
    except Exception:
        pass
    sys.exit(0)

signal.signal(signal.SIGTERM, cleanup)
signal.signal(signal.SIGINT, cleanup)

# Keep running (pretend to do kernel work)
while True:
    time.sleep(5)
    # Periodically rewrite to keep the file fresh
    try:
        with open(flag_file.name, 'a') as f:
            f.write(f"heartbeat: {time.time()}\n")
    except Exception:
        pass
