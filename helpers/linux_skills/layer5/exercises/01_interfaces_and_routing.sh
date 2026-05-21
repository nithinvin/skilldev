#!/bin/bash
# =============================================================================
# Layer 5, Exercise 1: NETWORK INTERFACES AND ROUTING
# =============================================================================
# THEORY-IN-ACTION: Your machine connects to networks through interfaces.
# Each interface has an IP address. Packets reach remote machines by following
# routes. Understanding this = understanding how the internet works at the
# machine level.
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 1: Interfaces & Routing — How Your Machine Connects"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: SEE YOUR NETWORK INTERFACES ────

    # Modern tool (ip):
    ip addr                         # All interfaces with addresses
    ip addr show                    # Same thing
    ip -br addr                     # Brief format (cleaner)

    # Key interfaces:
    # lo       = loopback (127.0.0.1 — talking to yourself)
    # eth0     = Ethernet (wired, or first interface)
    # wlan0    = Wireless
    # docker0  = Docker bridge (if Docker is installed)
    # veth*    = Virtual Ethernet (container connections)

    # What you see:
    # - Interface name
    # - State: UP or DOWN
    # - MAC address (link/ether)
    # - IPv4 address (inet) with subnet mask (/24 = 255.255.255.0)
    # - IPv6 address (inet6)

    # Legacy tool (still common):
    ifconfig 2>/dev/null || echo "Install: sudo apt install net-tools"

    # Just your IP:
    hostname -I                     # All local IPs (quick!)
    ip route get 8.8.8.8 | awk '{print $7; exit}'  # Your "main" IP

    # Your public IP (requires internet):
    curl -s ifconfig.me             # External IP (what the world sees)
    curl -s ipinfo.io               # More details (location, ISP)

EXPERIMENT:
    # Interface details:
    ip -s link                      # Statistics (TX/RX bytes, errors)
    ip link show                    # MAC addresses, MTU

    # What's your MAC address?
    ip link show | grep ether

    # Is your interface up?
    ip link show eth0 2>/dev/null || ip link show | head -10
    # state UP = connected, state DOWN = disconnected

──── PART 2: ROUTING — HOW PACKETS FIND THEIR WAY ────

    # See your routing table:
    ip route                        # All routes
    ip route show                   # Same

    # Output explained:
    # default via 192.168.1.1 dev eth0   ← Default gateway (packets go here if no better match)
    # 192.168.1.0/24 dev eth0            ← Local network (directly reachable)
    # 172.17.0.0/16 dev docker0          ← Docker network

    # Where does a packet to google.com go?
    ip route get 8.8.8.8           # Shows which interface and gateway

    # Trace the full path to a destination:
    traceroute 8.8.8.8 2>/dev/null || tracepath 8.8.8.8
    # Each line = one router hop between you and the destination
    # * * * = router doesn't respond to probes (common)

    # Ping — test basic connectivity:
    ping -c 3 8.8.8.8              # 3 packets to Google DNS
    ping -c 3 127.0.0.1            # Loopback (always works)
    ping -c 1 -W 2 192.168.1.1    # Gateway (2 sec timeout)

    # Useful ping patterns:
    ping -c 5 google.com | tail -1  # Just the summary line
    # "5 packets transmitted, 5 received, 0% packet loss, time 4008ms"

EXPERIMENT:
    # Can you reach your gateway?
    GATEWAY=$(ip route | awk '/default/ {print $3}')
    echo "Gateway: $GATEWAY"
    ping -c 2 "$GATEWAY"

    # MTU — Maximum Transmission Unit:
    ip link show | grep mtu         # Usually 1500 bytes
    # Packets larger than MTU get fragmented or dropped

    # ARP table (who is on your local network):
    ip neigh                        # ARP cache (IP → MAC mappings)

KEY INSIGHT: Your machine has a routing TABLE that says "for this network,
use this interface/gateway." The default route = "everything else goes here."
This is how your machine knows to send google.com traffic to your router.

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You understand network interfaces and routing."
echo "  Next: 02_connections.sh"
echo "═══════════════════════════════════════════════════════════════"
