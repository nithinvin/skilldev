#!/bin/bash
# =============================================================================
# Level 0.3 — Networking: What Happens When You Type a URL
# =============================================================================
#
# QUESTIONS (answer these BEFORE running):
#
#   1. What is an IP address? Why do we need DNS?
#      - IP address = a number that identifies a machine on a network (like a phone number)
#      - IPv4: 4 bytes → 93.184.216.34 (max ~4.3 billion addresses)
#      - IPv6: 16 bytes → 2606:2800:220:1:248:1893:25c8:1946 (way more addresses)
#      - DNS = translates human names (example.com) to IP addresses
#      - You can't remember 93.184.216.34, but you can remember example.com
#
#   2. What is a port? Why 65535 of them?
#      - Port = a 16-bit number that identifies a SERVICE on a machine
#      - 16 bits → 2^16 = 65536 values (0-65535)
#      - IP address = which machine. Port = which program on that machine.
#      - Like an apartment building: IP = building address, port = apartment number
#      - Well-known ports: 80 (HTTP), 443 (HTTPS), 22 (SSH), 5432 (PostgreSQL)
#
#   3. TCP vs UDP?
#      - TCP = reliable, ordered, connection-oriented (3-way handshake)
#        → Used for: HTTP, SSH, email, databases — where losing data is bad
#      - UDP = unreliable, unordered, connectionless (just send packets)
#        → Used for: DNS queries, video streaming, games — where speed > reliability
#      - HTTP uses TCP because you need ALL the HTML bytes in order
#
#   4. What happens when browser loads http://example.com?
#      Step 1: DNS lookup → "example.com" → 93.184.216.34
#      Step 2: TCP 3-way handshake → SYN → SYN-ACK → ACK
#      Step 3: HTTP request → GET / HTTP/1.1\r\nHost: example.com\r\n\r\n
#      Step 4: HTTP response → 200 OK + HTML body
#      Step 5: Browser parses HTML → builds DOM → renders page
#
#   5. What is a socket?
#      - A socket is an ENDPOINT for communication (IP + port + protocol)
#      - In Unix, a socket is a file descriptor (everything is a file!)
#      - Server creates a socket, binds to an address, listens for connections
#      - Client creates a socket, connects to server's address
#      - After connection: both sides read/write to their socket fd
#
# =============================================================================

set -e

echo "============================================"
echo "  Level 0.3 — Networking Exercises"
echo "============================================"
echo ""

# --- Exercise 1: DNS Lookup ---
echo ">>> Exercise 1: DNS — Translating names to IP addresses"
echo ""
echo "  Using 'dig' (the most detailed DNS tool):"
echo "  -------"
dig +short example.com
echo "  -------"
echo ""
echo "  Using 'host' (simpler output):"
host example.com
echo ""
echo "  KEY: Your machine asked a DNS server (usually your ISP's or 8.8.8.8)"
echo "  to translate 'example.com' into an IP address."
echo "  This happens EVERY time you visit a website (unless cached)."
echo ""

# --- Exercise 2: DNS trace (follow the chain) ---
echo ">>> Exercise 2: DNS resolution chain"
echo "  DNS is hierarchical: root → .com → example.com"
echo "  The +trace flag shows every step:"
echo ""
dig +trace +short example.com | tail -10
echo ""

# --- Exercise 3: Make an HTTP request BY HAND ---
echo ">>> Exercise 3: HTTP is just TEXT over TCP"
echo ""
echo "  We're going to type an HTTP request manually using netcat."
echo "  This is what your browser does — but we do it raw."
echo ""
echo "  Sending:"
echo "    GET / HTTP/1.1"
echo "    Host: example.com"
echo "    Connection: close"
echo ""
echo "  Response:"
echo "  -------"
echo -e "GET / HTTP/1.1\r\nHost: example.com\r\nConnection: close\r\n\r\n" | nc -w 5 example.com 80 | head -30
echo "  -------"
echo ""
echo "  LOOK AT THAT! You just made an HTTP request without a browser!"
echo "  Line 1: HTTP/1.1 200 OK ← status line"
echo "  Then headers (Content-Type, Content-Length, etc.)"
echo "  Then a blank line (\\r\\n\\r\\n)"
echo "  Then the HTML body"
echo ""

# --- Exercise 4: curl verbose — see the full conversation ---
echo ">>> Exercise 4: curl -v shows EVERYTHING"
echo "  '>' lines = what we SENT"
echo "  '<' lines = what we RECEIVED"
echo "  '*' lines = curl's own notes (DNS, TLS, etc.)"
echo ""
curl -v --max-time 5 http://example.com 2>&1 | head -40
echo ""
echo "  -------"
echo ""

# --- Exercise 5: See what's listening on your machine ---
echo ">>> Exercise 5: Open ports and listening services"
echo ""
echo "  ss -tlnp shows TCP listening sockets:"
echo "  (t=TCP, l=listening, n=numeric, p=process)"
echo ""
ss -tlnp 2>/dev/null | head -20
echo ""
echo "  Each line = a program waiting for connections on a port."
echo "  If nothing is listed, no servers are running (that's okay for now!)."
echo ""

# --- Exercise 6: Your machine's network interfaces ---
echo ">>> Exercise 6: Network interfaces"
echo ""
echo "  ip addr show (what IP addresses does this machine have?):"
ip -4 addr show | grep -E 'inet |^[0-9]' | head -10
echo ""
echo "  lo = loopback (127.0.0.1 — talks to itself)"
echo "  eth0/ens3/wlan0 = actual network interface"
echo ""

# --- Exercise 7: Ping and traceroute ---
echo ">>> Exercise 7: Ping — is the remote machine reachable?"
echo ""
ping -c 3 example.com 2>/dev/null || echo "  (ping might be blocked by firewall)"
echo ""
echo "  Each line shows the round-trip time (RTT) in milliseconds."
echo "  Lower = closer/faster network path."
echo ""

echo "============================================"
echo "  BREAK IT — Try these yourself:"
echo "============================================"
echo ""
echo "  1. Connect to a port nothing is listening on:"
echo "     nc -w 2 localhost 9999"
echo "     → Connection refused! Nobody is home at port 9999."
echo ""
echo "  2. Send garbage to an HTTP server:"
echo "     echo 'BLAH BLAH' | nc -w 2 example.com 80"
echo "     → The server returns 400 Bad Request (it expected HTTP format)"
echo ""
echo "  3. Look up a non-existent domain:"
echo "     dig this-domain-definitely-does-not-exist-12345.com"
echo "     → NXDOMAIN (Non-Existent Domain)"
echo ""
echo "  4. Check your public IP:"
echo "     curl -s ifconfig.me"
echo "     → This is the IP the world sees (might be NAT/router IP)"
echo ""
echo "  5. See the route packets take to reach a server:"
echo "     traceroute example.com   (or tracepath if traceroute not installed)"
echo "     → Each hop is a router between you and the destination"
echo ""
echo "============================================"
echo "  ✅ Level 0.3 Complete"
echo "  Next: Run the TCP echo server (level 0.4)"
echo "  python3 ../servers/01_echo_server.py"
echo "============================================"
