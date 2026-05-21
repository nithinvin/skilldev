#!/bin/bash
# =============================================================================
# Layer 5, Exercise 2: CONNECTIONS AND PORTS
# =============================================================================
# THEORY-IN-ACTION: Every network connection is identified by a 5-tuple:
# (source_ip, source_port, dest_ip, dest_port, protocol). Understanding
# connections = understanding what services are running and who's talking to whom.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 2: Connections & Ports — Who's Talking to Whom"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: ss — THE #1 NETWORK DIAGNOSTIC TOOL ────

    # ss = Socket Statistics (replacement for netstat)

    # The most useful command you'll ever learn:
    ss -tlnp
    # -t = TCP only
    # -l = listening (servers waiting for connections)
    # -n = numeric (don't resolve names — faster)
    # -p = show process (which program is listening)

    # What this tells you:
    # State  Recv-Q Send-Q  Local Address:Port  Peer Address:Port  Process
    # LISTEN 0      128     0.0.0.0:22          0.0.0.0:*          sshd
    # LISTEN 0      128     127.0.0.1:5432      0.0.0.0:*          postgres

    # Reading it:
    # 0.0.0.0:22    = listening on ALL interfaces, port 22
    # 127.0.0.1:5432 = listening ONLY on localhost (not accessible remotely!)
    # :::80          = listening on all interfaces, IPv6, port 80

    # Variations:
    ss -tlnp                # TCP listeners (most common)
    ss -ulnp                # UDP listeners
    ss -tnp                 # Active TCP connections (not just listening)
    ss -s                   # Summary statistics
    ss -tn state established  # Only established connections

    # Filter by port:
    ss -tlnp | grep ":22"           # What's on port 22?
    ss -tlnp sport = :80            # Listening on port 80
    ss -tn dst 8.8.8.8              # Connections to Google DNS

EXPERIMENT:
    # Start a listener and find it:
    python3 -c "
import socket, time
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind(('0.0.0.0', 9999))
s.listen(1)
print('Listening on port 9999...')
time.sleep(15)
s.close()
" &
    sleep 1
    ss -tlnp | grep 9999           # There it is!
    kill %1 2>/dev/null

    # See all connections from your browser:
    ss -tnp | grep -i firefox | head -10 2>/dev/null || \
    ss -tnp | grep -i chrom | head -10 2>/dev/null || \
    ss -tnp | head -20

KEY INSIGHT: `ss -tlnp` answers "what services are running on my machine?"
This is your first diagnostic when something doesn't connect.
"Connection refused" = nothing listening on that port.

──── PART 2: COMMON PORTS AND lsof ────

    # Well-known ports (memorize these):
    # 22   = SSH
    # 80   = HTTP
    # 443  = HTTPS
    # 25   = SMTP (email sending)
    # 53   = DNS
    # 3306 = MySQL
    # 5432 = PostgreSQL
    # 6379 = Redis
    # 8080 = HTTP alt (development servers)
    # 3000 = Node.js (common dev port)

    # lsof — who's using a port:
    sudo lsof -i :22               # What process is on port 22?
    sudo lsof -i :80               # What's on port 80?
    sudo lsof -i -P -n             # All network connections (numeric)

    # Find what a process is connected to:
    PID=$$
    sudo lsof -p $PID -i           # Network connections of this process

    # Check if a port is available:
    ss -tlnp | grep -q ":8080 " && echo "Port 8080 in use!" || echo "Port 8080 free"

    # Connection states explained:
    ss -tn | awk '{print $1}' | sort | uniq -c | sort -rn
    # ESTAB     = Active connection
    # TIME-WAIT = Connection closed, waiting for stale packets
    # CLOSE-WAIT = Remote side closed, our side hasn't yet (potential bug!)
    # SYN-SENT  = Connecting...
    # SYN-RECV  = Someone is connecting to us

──── PART 3: TESTING CONNECTIVITY ────

    # Test if a remote port is open:
    # nc (netcat) — the Swiss army knife:
    nc -zv google.com 80            # Is port 80 open? (-z = just check, -v = verbose)
    nc -zv google.com 443
    nc -zv google.com 12345         # Probably closed/filtered

    # Timeout for slow connections:
    nc -zv -w 3 google.com 80      # 3 second timeout

    # Scan a range of ports:
    for port in 22 80 443 8080 3000; do
        nc -zv -w 1 localhost $port 2>&1 | grep -E "succeeded|refused"
    done

    # Or check with bash builtins:
    (echo > /dev/tcp/google.com/80) 2>/dev/null && echo "Port 80 open" || echo "closed"
    # /dev/tcp is a bash pseudo-device that opens TCP connections!

    # telnet (old school):
    # telnet google.com 80
    # (type "GET / HTTP/1.0" and press Enter twice to get a response)

EXPERIMENT:
    # Create a simple chat between two terminals:
    # Terminal 1 (server):
    nc -l 12345                     # Listen on port 12345
    # Terminal 2 (client):
    nc localhost 12345              # Connect
    # Now type in either terminal — text appears in the other!
    # Ctrl+C to close

KEY INSIGHT: nc (netcat) is your go-to for testing connectivity.
`nc -zv host port` = "is this port reachable?"
If it's not: either nothing is listening, or a firewall is blocking.

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can diagnose network connections."
echo "  Next: 03_dns.sh"
echo "═══════════════════════════════════════════════════════════════"
