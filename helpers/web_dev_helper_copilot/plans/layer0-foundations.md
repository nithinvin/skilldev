# Layer 0: Linux & Networking Foundations

> **Goal**: Understand the ground your code runs on — the OS, the shell, the network.
> **Why this first?** Every server, container, and cloud instance is Linux. Every web request is a network packet. If you understand this layer, nothing above it is magic.

---

## Level 0.1 — The Shell Is Your IDE

### Questions to Answer First
1. What is a shell? How is it different from a terminal emulator?
2. When you type `ls` and press Enter, what actually happens? (hint: fork, exec, PATH)
3. What is a process? What's the difference between a process and a program?
4. What are file descriptors 0, 1, 2? Why do they matter?
5. What does `|` (pipe) actually do at the OS level?

### Theory (Concise)
- Shell = a program that reads commands, forks child processes, and manages I/O
- Everything in Linux is a file (or pretends to be) — devices, sockets, pipes
- Processes have: PID, parent PID, file descriptor table, environment variables
- stdin (fd 0), stdout (fd 1), stderr (fd 2) — the holy trinity of I/O

### Hands-On Exercises
```bash
# 1. Trace what happens when you run a command
strace -f -e trace=process ls 2>&1 | head -20

# 2. Explore file descriptors
ls -la /proc/$$/fd

# 3. Understand pipes — create two processes connected by a pipe
echo "hello" | cat    # How many processes? Use `ps` in another terminal

# 4. Redirect stderr separately from stdout
ls /nonexistent 2>/tmp/errors.txt 1>/tmp/output.txt
cat /tmp/errors.txt

# 5. Background processes
sleep 100 &
jobs
ps aux | grep sleep
kill %1
```

### Break It
- What happens if you `exec` a command? (hint: `exec ls` — your shell disappears)
- What if you close stdout? `exec 1>&-; echo "can you see this?"`

---

## Level 0.2 — Files, Permissions, Users

### Questions to Answer First
1. What do the permission bits `rwxr-xr--` actually mean? Who are owner/group/other?
2. Why does Linux have users and groups? What problem does this solve?
3. What is an inode? How is it different from a filename?
4. What's the difference between a hard link and a symbolic link?
5. Why can't a normal user listen on port 80?

### Hands-On Exercises
```bash
# 1. Create a file structure and examine permissions
mkdir -p /tmp/layer0/test
touch /tmp/layer0/test/secret.txt
chmod 600 /tmp/layer0/test/secret.txt
ls -la /tmp/layer0/test/

# 2. See the inode
ls -i /tmp/layer0/test/secret.txt
stat /tmp/layer0/test/secret.txt

# 3. Hard link vs soft link
ln /tmp/layer0/test/secret.txt /tmp/layer0/test/hardlink.txt
ln -s /tmp/layer0/test/secret.txt /tmp/layer0/test/symlink.txt
ls -li /tmp/layer0/test/
# Delete original — what happens to each link?
rm /tmp/layer0/test/secret.txt
cat /tmp/layer0/test/hardlink.txt   # works?
cat /tmp/layer0/test/symlink.txt    # works?

# 4. User and group info
id
cat /etc/passwd | grep $(whoami)
groups
```

---

## Level 0.3 — Networking: What Happens When You Type a URL

### Questions to Answer First
1. What is an IP address? Why do we need DNS?
2. What is a port? Why can a machine have 65535 of them?
3. What's the difference between TCP and UDP? Why does HTTP use TCP?
4. What happens step-by-step when your browser loads `http://example.com`?
   - DNS lookup → TCP handshake → HTTP request → response → rendering
5. What is a socket? How does it relate to file descriptors?

### Theory (Concise)
```
Browser types URL
    → DNS: "example.com" → 93.184.216.34
    → TCP 3-way handshake: SYN → SYN-ACK → ACK
    → HTTP Request: GET / HTTP/1.1\r\nHost: example.com\r\n\r\n
    → HTTP Response: 200 OK + HTML body
    → Browser renders HTML
```

### Hands-On Exercises
```bash
# 1. DNS lookup
dig example.com
nslookup example.com
host example.com

# 2. See the TCP handshake (run in separate terminal)
sudo tcpdump -i any -c 10 host example.com

# 3. Make an HTTP request by hand using netcat
echo -e "GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n" | nc example.com 80

# 4. Same thing with curl -v (verbose shows headers)
curl -v http://example.com

# 5. See open ports and sockets on your machine
ss -tlnp
# or
netstat -tlnp
```

### Break It
- What happens if DNS is unreachable? `sudo iptables -A OUTPUT -p udp --dport 53 -j DROP` then `curl example.com` (remember to flush: `sudo iptables -F`)
- What if you try to connect to a port nothing is listening on? `nc localhost 9999`

---

## Level 0.4 — Build a TCP Echo Server (Python)

### Questions to Answer First
1. What system call creates a socket?
2. What's the difference between `bind`, `listen`, and `accept`?
3. Why do servers call `accept` in a loop?
4. What happens if two clients connect at the same time to a single-threaded server?

### Hands-On: The Simplest Server
```python
# file: echo_server.py
import socket

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(('0.0.0.0', 8888))
server.listen(5)

print("Echo server listening on port 8888...")

while True:
    client_sock, addr = server.accept()
    print(f"Connection from {addr}")
    data = client_sock.recv(1024)
    print(f"Received: {data.decode()}")
    client_sock.sendall(data)  # echo it back
    client_sock.close()
```

```bash
# Terminal 1: Run server
python3 echo_server.py

# Terminal 2: Connect as client
echo "Hello from netcat" | nc localhost 8888

# Terminal 3: Watch the connection
ss -tnp | grep 8888
```

### Extend It
- Handle multiple clients (hint: `threading` or `select`)
- Add a simple protocol: client sends "UPPER hello" → server responds "HELLO"
- Log connections with timestamps

---

## Level 0.5 — Build a Minimal HTTP Server (From Scratch)

### Questions to Answer First
1. HTTP is just text over TCP. What does an HTTP request look like? An HTTP response?
2. What's the minimum valid HTTP response a server can send?
3. What is a `Content-Type` header? Why does it matter?
4. What's the difference between HTTP/1.0 and HTTP/1.1?

### Hands-On: HTTP Server in ~30 Lines
```python
# file: http_server.py
import socket

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server.bind(('0.0.0.0', 8080))
server.listen(5)

print("HTTP server on http://localhost:8080")

while True:
    client, addr = server.accept()
    request = client.recv(4096).decode()
    print(f"--- Request from {addr} ---")
    print(request[:200])  # Print first 200 chars of request

    # Parse the request line
    request_line = request.split('\r\n')[0]
    method, path, version = request_line.split(' ')

    # Build response
    if path == '/':
        body = "<html><body><h1>Hello from your own HTTP server!</h1></body></html>"
        status = "200 OK"
    else:
        body = "<html><body><h1>404 Not Found</h1></body></html>"
        status = "404 Not Found"

    response = (
        f"HTTP/1.1 {status}\r\n"
        f"Content-Type: text/html\r\n"
        f"Content-Length: {len(body)}\r\n"
        f"Connection: close\r\n"
        f"\r\n"
        f"{body}"
    )

    client.sendall(response.encode())
    client.close()
```

```bash
# Run it and open http://localhost:8080 in browser
python3 http_server.py

# Or use curl
curl -v http://localhost:8080/
curl -v http://localhost:8080/nonexistent
```

### Break It
- What if you don't send `Content-Length`?
- What if you send `Content-Type: application/json` but the body is HTML?
- What if a client sends a malformed request?

---

## Checkpoint Questions (Answer Before Moving to Layer 1)

1. Draw from memory: what happens from typing a URL to seeing a page?
2. Explain the difference between a process, a thread, and a socket.
3. Why is HTTP called "stateless"? What does that mean for web apps?
4. If you run `python3 http_server.py` on your Hetzner VM, can you access it from your laptop browser? What do you need to configure?
5. What's the role of `bind()` vs `listen()` vs `accept()`?

---

## Tools Installed Check

```bash
# Make sure these are available (install if not)
which python3 && python3 --version
which curl && curl --version
which dig || sudo apt install dnsutils
which nc || sudo apt install netcat-openbsd
which ss   # should be available by default
which strace || sudo apt install strace
which tcpdump || sudo apt install tcpdump
```

---

**Next**: [Layer 1 — Static Web: HTML, CSS, JavaScript](layer1-static-web.md)
