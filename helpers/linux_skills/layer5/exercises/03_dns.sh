#!/bin/bash
# =============================================================================
# Layer 5, Exercise 3: DNS
# =============================================================================
# THEORY-IN-ACTION: DNS translates human-readable names (google.com) to
# IP addresses (142.250.x.x). Without DNS, you'd need to memorize numbers.
# Understanding DNS = understanding why "the internet is slow" or "site not found."
# =============================================================================

echo "═══════════════════════════════════════════════════════════════"
echo "  EXERCISE 3: DNS — The Internet's Phone Book"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat << 'INSTRUCTIONS'

──── PART 1: DNS LOOKUPS ────

    # dig — the definitive DNS tool:
    dig google.com                  # Full query (A record by default)
    dig google.com +short           # Just the IP
    dig google.com A                # IPv4 address (A record)
    dig google.com AAAA             # IPv6 address (AAAA record)
    dig google.com MX               # Mail servers
    dig google.com NS               # Name servers
    dig google.com TXT              # Text records (SPF, verification, etc.)
    dig google.com ANY              # All records

    # Read the dig output:
    # ;; QUESTION SECTION: → what you asked
    # ;; ANSWER SECTION:   → the actual DNS response
    # ;; AUTHORITY SECTION: → which nameserver is authoritative
    # ;; Query time: 23 msec → how long it took

    # nslookup (simpler, works everywhere):
    nslookup google.com
    nslookup -type=MX google.com

    # host (simplest):
    host google.com
    host -t MX google.com

    # Reverse lookup (IP → name):
    dig -x 8.8.8.8                  # What hostname has this IP?
    host 8.8.8.8                    # Same, simpler output

EXPERIMENT:
    # Query a specific DNS server:
    dig @8.8.8.8 google.com        # Ask Google's DNS
    dig @1.1.1.1 google.com        # Ask Cloudflare's DNS

    # Trace the full DNS resolution path:
    dig +trace google.com
    # Shows: root servers → .com servers → google.com servers → answer

    # Measure DNS speed:
    time dig @8.8.8.8 google.com +short
    time dig @1.1.1.1 google.com +short
    # Which DNS server is faster for you?

KEY INSIGHT: DNS is hierarchical: root → TLD (.com) → domain (google.com).
Your resolver (usually your router or ISP) caches results.
`dig +short` is the fastest way to check DNS resolution.

──── PART 2: LOCAL DNS CONFIGURATION ────

    # Where does your system look for DNS servers?
    cat /etc/resolv.conf            # DNS servers your system uses
    # nameserver 8.8.8.8
    # nameserver 8.8.4.4

    # /etc/hosts — LOCAL DNS overrides (checked before DNS servers!):
    cat /etc/hosts
    # 127.0.0.1    localhost
    # Custom entries override DNS for your machine only:
    # 192.168.1.50  myserver.local

    # Resolution order:
    cat /etc/nsswitch.conf | grep hosts
    # hosts: files dns
    # "files" = check /etc/hosts first, then "dns" = query DNS server

    # systemd-resolved (modern systems):
    resolvectl status 2>/dev/null || systemd-resolve --status 2>/dev/null || echo "Not using systemd-resolved"
    # Shows current DNS servers and search domains

EXPERIMENT:
    # Add a custom DNS entry:
    echo "127.0.0.1 mytest.local" | sudo tee -a /etc/hosts
    ping -c 1 mytest.local          # Resolves to 127.0.0.1!
    # Clean up:
    sudo sed -i '/mytest.local/d' /etc/hosts

    # DNS caching — same query is faster second time:
    time dig google.com +short > /dev/null
    time dig google.com +short > /dev/null  # Cached! Much faster.

    # Flush DNS cache (if using systemd-resolved):
    sudo resolvectl flush-caches 2>/dev/null || echo "Manual flush not needed"

──── PART 3: DNS TROUBLESHOOTING ────

    # "DNS not working" checklist:
    # 1. Can you reach the DNS server?
    ping -c 1 8.8.8.8              # If this fails, network is down (not DNS)

    # 2. Can the DNS server resolve?
    dig @8.8.8.8 google.com +short # If this works, your DNS config is wrong

    # 3. What DNS server are you using?
    cat /etc/resolv.conf

    # 4. Is it a specific domain?
    dig problematic-domain.com      # Check the response code
    # NOERROR = working
    # NXDOMAIN = domain doesn't exist
    # SERVFAIL = DNS server error
    # REFUSED = DNS server refused query

    # 5. TTL — how long results are cached:
    dig google.com | grep -A1 "ANSWER SECTION"
    # The number (e.g., 300) is TTL in seconds

    # Common DNS issues:
    # - Wrong nameserver in resolv.conf → fix it
    # - DNS server down → use 8.8.8.8 or 1.1.1.1 temporarily
    # - Domain expired → NXDOMAIN
    # - Propagation delay → new records take time (up to TTL of old record)

EXPERIMENT:
    # Compare DNS resolution across servers:
    for dns in 8.8.8.8 1.1.1.1 9.9.9.9; do
        echo -n "DNS $dns: "
        dig @$dns google.com +short | head -1
    done

    # Check if a domain exists:
    dig nonexistent-domain-xyz123.com
    # Look for: status: NXDOMAIN

KEY INSIGHT: DNS problems feel like "internet is down" but actually only
name resolution is broken. If `ping 8.8.8.8` works but `ping google.com`
doesn't, it's DNS. Fix: check /etc/resolv.conf or try `dig @8.8.8.8`.

INSTRUCTIONS

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  DONE: You can debug DNS issues."
echo "  Next: 04_curl_and_transfer.sh"
echo "═══════════════════════════════════════════════════════════════"
