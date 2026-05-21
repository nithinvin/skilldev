# Layer 5: Networking from the CLI

## What You'll Learn
- Network interfaces, IP addresses, and routing
- Connections, ports, and diagnosing network issues
- DNS — resolution, configuration, troubleshooting
- curl, wget, rsync — interacting with web services and transferring files

## File Structure

```
layer5/
├── README.md              ← You are here
└── exercises/
    ├── 01_interfaces_and_routing.sh   ← ip addr, ip route, ping, traceroute
    ├── 02_connections.sh              ← ss, lsof, nc, port scanning
    ├── 03_dns.sh                      ← dig, nslookup, /etc/resolv.conf
    └── 04_curl_and_transfer.sh        ← curl, wget, rsync, API interaction
```

## Prerequisites
- Complete Layers 0-4
- You should have a working internet connection for most exercises

## Why This Matters
Every developer needs to:
- Debug "why can't I connect to the database?" → ss, ping, nc
- Test APIs without a browser → curl
- Deploy code to servers → scp, rsync
- Understand "DNS not resolving" → dig, /etc/resolv.conf

## The Diagnostic Ladder
When something "doesn't connect":
```
1. ping host          → Is the host reachable at all?
2. dig host           → Does DNS resolve correctly?
3. nc -zv host port   → Is the specific port open?
4. ss -tlnp           → Is anything listening on my side?
5. curl -v url        → What's the HTTP-level problem?
```

## Time Estimate
~3-4 hours
