"""
=============================================================================
Level 0 Checkpoint — Answer These Before Moving to Layer 1
=============================================================================

These are NOT multiple choice. Write your answers in your own words.
Run this file to see the questions, then answer them.

After answering, uncomment the ANSWERS section at the bottom
to compare with the expected answers.

=============================================================================
"""


def ask(number: int, question: str):
    print(f"\n{'='*60}")
    print(f"  Question {number}")
    print(f"{'='*60}")
    print(f"  {question}")
    print()


def main():
    print("\n" + "=" * 60)
    print("  LAYER 0 CHECKPOINT QUIZ")
    print("  Answer these before moving to Layer 1")
    print("=" * 60)

    ask(1,
        "Draw from memory: what happens step-by-step when you type\n"
        "  http://example.com in a browser and press Enter?\n"
        "  (Include: DNS, TCP, HTTP request, HTTP response, rendering)")

    ask(2,
        "Explain the difference between:\n"
        "  - A process\n"
        "  - A thread\n"
        "  - A socket\n"
        "  Give an analogy for each.")

    ask(3,
        "Why is HTTP called 'stateless'?\n"
        "  What does this mean for web applications that need login?")

    ask(4,
        "If you run 'python3 03_http_server.py' on your Hetzner VM,\n"
        "  can you access it from your laptop browser?\n"
        "  What do you need to configure? List all steps.")

    ask(5,
        "What's the role of each:\n"
        "  - socket()\n"
        "  - bind()\n"
        "  - listen()\n"
        "  - accept()\n"
        "  - recv() / send()\n"
        "  - close()")

    ask(6,
        "What is the difference between a hard link and a symbolic link?\n"
        "  What happens to each when you delete the original file?")

    ask(7,
        "You wrote two versions of the echo server:\n"
        "  - Single-threaded (01_echo_server.py)\n"
        "  - Multi-threaded (02_echo_server_threaded.py)\n"
        "  What breaks in the single-threaded version when two clients\n"
        "  connect at the same time? Why does threading fix it?")

    ask(8,
        "In 04_http_file_server.py, we check for path traversal.\n"
        "  What is a path traversal attack?\n"
        "  Give an example request that would exploit a vulnerable server.")

    print("\n" + "=" * 60)
    print("  Write your answers, then check below.")
    print("  To see expected answers: uncomment the ANSWERS section in this file.")
    print("=" * 60 + "\n")


# =============================================================================
# ANSWERS (uncomment after attempting)
# =============================================================================
#
# def show_answers():
#     print("\n" + "=" * 60)
#     print("  EXPECTED ANSWERS")
#     print("=" * 60)
#
#     print("""
# 1. URL → Page (step by step):
#    a) Browser extracts hostname "example.com" from URL
#    b) DNS lookup: OS asks DNS server to resolve "example.com" → 93.184.216.34
#    c) TCP 3-way handshake: SYN → SYN-ACK → ACK (establishes reliable connection)
#    d) HTTP request: Browser sends "GET / HTTP/1.1\r\nHost: example.com\r\n\r\n"
#    e) Server processes request, finds the resource
#    f) HTTP response: Server sends "HTTP/1.1 200 OK\r\n..." + HTML body
#    g) Browser receives HTML, parses it into a DOM tree
#    h) Browser finds <link>, <script>, <img> tags → makes MORE HTTP requests
#    i) Browser combines DOM + CSS → render tree → layout → paint → pixels
#
# 2. Process vs Thread vs Socket:
#    - Process: an independent running program with its own memory space
#      (analogy: a separate apartment with its own kitchen, bathroom)
#    - Thread: a lightweight execution unit WITHIN a process, shares memory
#      (analogy: roommates in the same apartment sharing the kitchen)
#    - Socket: an endpoint for network communication (IP + port + protocol)
#      (analogy: a phone — you can call others and receive calls)
#
# 3. HTTP is stateless:
#    - Each request is independent. The server doesn't "remember" previous requests.
#    - After responding, the server forgets about you completely.
#    - For login: you need cookies or tokens to carry "state" across requests.
#      The server sets a cookie on login, browser sends it with every request.
#      Server checks the cookie to know who you are. (This is Layer 3 material.)
#
# 4. Accessing Hetzner VM from laptop:
#    a) Run the server: python3 03_http_server.py (binds to 0.0.0.0:8080)
#    b) Check firewall allows port 8080: sudo ufw allow 8080 (or iptables)
#    c) Check Hetzner's firewall rules in their dashboard
#    d) Find the VM's public IP: curl ifconfig.me
#    e) From laptop: http://<vm-public-ip>:8080
#    f) If using a domain: set DNS A record pointing to the VM's IP
#
# 5. Socket API roles:
#    - socket()  → Create the endpoint (like getting a phone)
#    - bind()    → Assign an address (like getting a phone number)
#    - listen()  → Start accepting calls (turn on the ringer)
#    - accept()  → Pick up the phone (blocks until someone calls)
#    - recv()    → Listen to what the caller says
#    - send()    → Talk to the caller
#    - close()   → Hang up
#
# 6. Hard link vs Symbolic link:
#    - Hard link: another name (directory entry) pointing to the SAME inode
#      Delete original → hard link still works (data still has a reference)
#    - Symbolic link: a file containing a PATH to another file
#      Delete original → symlink is broken (dangling — path doesn't exist)
#
# 7. Threading fix:
#    - Single-threaded: accept → handle client A → close → accept → handle B
#      If A takes 10 seconds, B waits 10 seconds before being served.
#    - Multi-threaded: accept A → spawn thread for A → immediately accept B
#      Both are handled concurrently. The main thread only does accept().
#
# 8. Path traversal:
#    - Attack: GET /../../../etc/passwd HTTP/1.1
#    - Vulnerable server joins document_root + path:
#      /var/www/ + /../../../etc/passwd → /etc/passwd
#    - Server reads /etc/passwd and returns it to attacker!
#    - Defense: resolve the full path and check it starts with document_root
# """)
#
# show_answers()


if __name__ == '__main__':
    main()
