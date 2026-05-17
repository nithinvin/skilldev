# Layer 0: Linux & Networking Foundations

## What You'll Learn

- How the shell works (processes, file descriptors, pipes)
- Linux file permissions, users, groups, inodes
- Networking from first principles (DNS, TCP, HTTP)
- Building a TCP echo server from raw sockets
- Building an HTTP server from scratch (no frameworks!)

## File Structure

```
layer0/
├── README.md                  ← You are here
├── checkpoint_quiz.py         ← Answer these before moving to Layer 1
├── exercises/
│   ├── 01_shell_basics.sh     ← Level 0.1: Shell, processes, file descriptors
│   ├── 02_files_permissions.sh← Level 0.2: Files, permissions, inodes, links
│   └── 03_networking.sh       ← Level 0.3: DNS, TCP, HTTP by hand
├── servers/
│   ├── 01_echo_server.py      ← Level 0.4: Simple TCP echo server
│   ├── 02_echo_server_threaded.py ← Level 0.4+: Multi-threaded with protocol
│   ├── 03_http_server.py      ← Level 0.5: HTTP server (hardcoded pages)
│   └── 04_http_file_server.py ← Level 0.5+: HTTP server (serves files from disk)
└── www/                       ← Created automatically by 04_http_file_server.py
    ├── index.html
    ├── style.css
    └── app.js
```

## How to Work Through This

### Order matters — go sequentially:

```bash
cd ~/skilldev/mybookshelf/layer0

# Level 0.1: Shell basics
bash exercises/01_shell_basics.sh

# Level 0.2: Files and permissions
bash exercises/02_files_permissions.sh

# Level 0.3: Networking
bash exercises/03_networking.sh

# Level 0.4: TCP echo server
# Terminal 1:
python3 servers/01_echo_server.py
# Terminal 2:
echo "Hello!" | nc localhost 8888

# Level 0.4+: Threaded echo server with protocol
# Terminal 1:
python3 servers/02_echo_server_threaded.py
# Terminal 2:
echo "UPPER hello world" | nc localhost 8889
echo "REVERSE python" | nc localhost 8889
echo "HELP" | nc localhost 8889

# Level 0.5: HTTP server (open http://localhost:8080 in browser)
python3 servers/03_http_server.py

# Level 0.5+: File server (serves actual HTML/CSS/JS from disk)
python3 servers/04_http_file_server.py

# Checkpoint quiz
python3 checkpoint_quiz.py
```

### At each level:

1. **Read the QUESTIONS** at the top of each file FIRST
2. **Think about the answers** before running anything
3. **Run the exercises** and observe
4. **Try the "Break It" section** — intentionally break things
5. **Move to the next level** only when you can answer the questions

## Key Concepts Cheat Sheet

| Concept | One-line summary |
|---------|-----------------|
| Process | A running program with PID, memory, file descriptors |
| File descriptor | An integer handle to an open file/socket/pipe |
| Inode | Data structure on disk storing file metadata (the real identity) |
| Socket | An endpoint for network communication (IP + port) |
| TCP | Reliable, ordered, connection-oriented protocol |
| HTTP | Text-based protocol over TCP: request → response |
| DNS | Translates domain names to IP addresses |
| Port | 16-bit number identifying a service on a machine |
