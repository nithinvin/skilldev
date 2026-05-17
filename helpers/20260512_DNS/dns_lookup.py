#!/usr/bin/env python3
"""
dns_lookup.py — DNS experiments using Python's standard library and dnspython.

Install dnspython first:
    pip install dnspython

Run:
    python3 dns_lookup.py
"""

import socket
import struct
import time
import sys

# ─────────────────────────────────────────────────────────────
# PART 1: Using Python's standard `socket` module (built-in)
# ─────────────────────────────────────────────────────────────

def demo_socket_basics():
    """Basic DNS lookups using the socket module."""
    print("=" * 60)
    print("PART 1: socket module (built-in)")
    print("=" * 60)

    domains = ["github.com", "google.com", "cloudflare.com"]

    for domain in domains:
        # gethostbyname: A record lookup
        try:
            ip = socket.gethostbyname(domain)
            print(f"  gethostbyname({domain!r}) → {ip}")
        except socket.gaierror as e:
            print(f"  ERROR: {e}")

    print()

    # gethostbyname_ex: returns (hostname, aliases, addresses)
    hostname, aliases, ips = socket.gethostbyname_ex("google.com")
    print(f"  gethostbyname_ex('google.com'):")
    print(f"    hostname : {hostname}")
    print(f"    aliases  : {aliases}")
    print(f"    IPs      : {ips}")
    print()

    # getaddrinfo: full resolution including IPv6, ports, socket type
    print("  getaddrinfo('github.com', 443):")
    results = socket.getaddrinfo("github.com", 443, proto=socket.IPPROTO_TCP)
    for family, stype, proto, canonname, sockaddr in results:
        family_name = "IPv4" if family == socket.AF_INET else "IPv6"
        print(f"    [{family_name}] {sockaddr[0]}:{sockaddr[1]}")
    print()

    # Reverse DNS: gethostbyaddr
    try:
        host, aliases, addresses = socket.gethostbyaddr("8.8.8.8")
        print(f"  Reverse lookup 8.8.8.8 → {host}")
    except socket.herror as e:
        print(f"  Reverse lookup error: {e}")
    print()

    # getfqdn: fully qualified domain name
    fqdn = socket.getfqdn("github.com")
    print(f"  FQDN of github.com: {fqdn}")

    # Your machine's hostname and IP
    my_hostname = socket.gethostname()
    my_ip = socket.gethostbyname(my_hostname)
    print(f"\n  This machine: hostname={my_hostname}, IP={my_ip}")


# ─────────────────────────────────────────────────────────────
# PART 2: Measure DNS lookup latency
# ─────────────────────────────────────────────────────────────

def measure_dns_latency():
    """Measure how long DNS resolution takes."""
    print("\n" + "=" * 60)
    print("PART 2: DNS Lookup Latency")
    print("=" * 60)

    domains = ["github.com", "google.com", "stackoverflow.com", "python.org"]

    for domain in domains:
        start = time.perf_counter()
        try:
            ip = socket.gethostbyname(domain)
            elapsed_ms = (time.perf_counter() - start) * 1000
            print(f"  {domain:<30} → {ip:<18} ({elapsed_ms:.2f} ms)")
        except socket.gaierror as e:
            elapsed_ms = (time.perf_counter() - start) * 1000
            print(f"  {domain:<30} → ERROR: {e} ({elapsed_ms:.2f} ms)")


# ─────────────────────────────────────────────────────────────
# PART 3: DNS over HTTPS (DoH) using urllib — no extra libs!
# ─────────────────────────────────────────────────────────────

def demo_doh():
    """Query DNS over HTTPS using Cloudflare's DoH API."""
    import urllib.request
    import json

    print("\n" + "=" * 60)
    print("PART 3: DNS over HTTPS (DoH) — Cloudflare JSON API")
    print("=" * 60)

    queries = [
        ("github.com", "A"),
        ("gmail.com",  "MX"),
        ("github.com", "NS"),
        ("google.com", "AAAA"),
    ]

    for domain, rtype in queries:
        url = f"https://cloudflare-dns.com/dns-query?name={domain}&type={rtype}"
        req = urllib.request.Request(url, headers={"Accept": "application/dns-json"})
        try:
            with urllib.request.urlopen(req, timeout=5) as resp:
                data = json.loads(resp.read())
            answers = data.get("Answer", [])
            print(f"\n  {domain} {rtype}:")
            for ans in answers:
                print(f"    TTL={ans['TTL']:<6} → {ans['data']}")
        except Exception as e:
            print(f"\n  {domain} {rtype}: ERROR — {e}")


# ─────────────────────────────────────────────────────────────
# PART 4: dnspython — full-featured DNS library
# ─────────────────────────────────────────────────────────────

def demo_dnspython():
    """
    Rich DNS queries using the dnspython library.
    Install: pip install dnspython
    """
    try:
        import dns.resolver
        import dns.reversename
        import dns.rdatatype
    except ImportError:
        print("\n" + "=" * 60)
        print("PART 4: dnspython (SKIPPED — not installed)")
        print("  Install with: pip install dnspython")
        print("=" * 60)
        return

    print("\n" + "=" * 60)
    print("PART 4: dnspython — Full DNS Queries")
    print("=" * 60)

    resolver = dns.resolver.Resolver()

    # --- A Records ---
    print("\n  [A Records]")
    for domain in ["github.com", "cloudflare.com"]:
        try:
            answers = resolver.resolve(domain, "A")
            for rdata in answers:
                print(f"    {domain} → {rdata.address}  (TTL {answers.rrset.ttl}s)")
        except Exception as e:
            print(f"    {domain}: {e}")

    # --- AAAA Records (IPv6) ---
    print("\n  [AAAA Records — IPv6]")
    for domain in ["google.com", "cloudflare.com"]:
        try:
            answers = resolver.resolve(domain, "AAAA")
            for rdata in answers:
                print(f"    {domain} → {rdata.address}")
        except Exception as e:
            print(f"    {domain}: {e}")

    # --- MX Records ---
    print("\n  [MX Records]")
    for domain in ["gmail.com", "yahoo.com"]:
        try:
            answers = resolver.resolve(domain, "MX")
            for rdata in sorted(answers, key=lambda r: r.preference):
                print(f"    {domain} → priority={rdata.preference} {rdata.exchange}")
        except Exception as e:
            print(f"    {domain}: {e}")

    # --- NS Records ---
    print("\n  [NS Records]")
    try:
        answers = resolver.resolve("github.com", "NS")
        for rdata in answers:
            print(f"    github.com NS → {rdata.target}")
    except Exception as e:
        print(f"    github.com NS: {e}")

    # --- TXT Records ---
    print("\n  [TXT Records — SPF]")
    try:
        answers = resolver.resolve("google.com", "TXT")
        for rdata in answers:
            txt = b"".join(rdata.strings).decode()
            if "spf" in txt.lower():
                print(f"    google.com TXT (SPF) → {txt[:80]}...")
    except Exception as e:
        print(f"    google.com TXT: {e}")

    # --- SOA Record ---
    print("\n  [SOA Record]")
    try:
        answers = resolver.resolve("github.com", "SOA")
        for rdata in answers:
            print(f"    Primary NS  : {rdata.mname}")
            print(f"    Admin email : {rdata.rname}")
            print(f"    Serial      : {rdata.serial}")
            print(f"    Refresh     : {rdata.refresh}s")
            print(f"    Retry       : {rdata.retry}s")
            print(f"    Expire      : {rdata.expire}s")
            print(f"    Min TTL     : {rdata.minimum}s")
    except Exception as e:
        print(f"    github.com SOA: {e}")

    # --- Reverse DNS (PTR) ---
    print("\n  [Reverse DNS / PTR]")
    for ip in ["8.8.8.8", "1.1.1.1", "140.82.114.4"]:
        try:
            rev_name = dns.reversename.from_address(ip)
            answers = resolver.resolve(rev_name, "PTR")
            for rdata in answers:
                print(f"    {ip} → {rdata.target}")
        except Exception as e:
            print(f"    {ip}: {e}")

    # --- Use a specific resolver (e.g. Google DNS) ---
    print("\n  [Using Google DNS 8.8.8.8 explicitly]")
    custom_resolver = dns.resolver.Resolver(configure=False)
    custom_resolver.nameservers = ["8.8.8.8"]
    try:
        answers = custom_resolver.resolve("python.org", "A")
        for rdata in answers:
            print(f"    python.org (via 8.8.8.8) → {rdata.address}")
    except Exception as e:
        print(f"    python.org: {e}")

    # --- CNAME resolution ---
    print("\n  [CNAME Records]")
    for domain in ["www.github.com", "docs.github.com"]:
        try:
            answers = resolver.resolve(domain, "CNAME")
            for rdata in answers:
                print(f"    {domain} CNAME → {rdata.target}")
        except dns.resolver.NoAnswer:
            print(f"    {domain}: No CNAME (might be A directly)")
        except Exception as e:
            print(f"    {domain}: {e}")


# ─────────────────────────────────────────────────────────────
# PART 5: Raw DNS packet — build a query by hand!
# ─────────────────────────────────────────────────────────────

def build_dns_query(domain: str, qtype: int = 1) -> bytes:
    """
    Manually build a raw DNS query packet.
    qtype: 1=A, 28=AAAA, 15=MX, 2=NS, 16=TXT
    """
    # Header: ID, Flags, QDCOUNT, ANCOUNT, NSCOUNT, ARCOUNT
    transaction_id = 0xABCD
    flags = 0x0100          # Standard query, recursion desired
    questions = 1
    answer_rrs = 0
    authority_rrs = 0
    additional_rrs = 0
    header = struct.pack(">HHHHHH",
                         transaction_id, flags,
                         questions, answer_rrs,
                         authority_rrs, additional_rrs)

    # Question: encode domain name in DNS wire format
    question = b""
    for part in domain.split("."):
        encoded = part.encode("ascii")
        question += bytes([len(encoded)]) + encoded
    question += b"\x00"          # null terminator
    question += struct.pack(">HH", qtype, 1)   # QTYPE, QCLASS (IN)

    return header + question


def demo_raw_dns():
    """Send a raw DNS UDP packet to 8.8.8.8:53 and print the response."""
    print("\n" + "=" * 60)
    print("PART 5: Raw DNS Packet over UDP (manual wire protocol)")
    print("=" * 60)

    domain = "github.com"
    query = build_dns_query(domain, qtype=1)  # A record

    print(f"\n  Querying A record for '{domain}' via 8.8.8.8:53")
    print(f"  Raw query ({len(query)} bytes): {query.hex()}")

    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.settimeout(5)

    try:
        sock.sendto(query, ("8.8.8.8", 53))
        response, _ = sock.recvfrom(512)

        # Parse transaction ID and flags from response header
        txid, flags_r, qdcount, ancount, nscount, arcount = struct.unpack(">HHHHHH", response[:12])
        rcode = flags_r & 0x000F

        print(f"  Response ({len(response)} bytes): {response[:20].hex()}...")
        print(f"  Transaction ID : 0x{txid:04X}")
        print(f"  RCODE          : {rcode} ({'NOERROR' if rcode==0 else 'ERROR'})")
        print(f"  Answer count   : {ancount}")

        # Skip question section to get to answers
        # (simple parser — works for basic responses)
        offset = 12
        # Skip question domain name
        while response[offset] != 0:
            if response[offset] >= 0xC0:  # compression pointer
                offset += 2
                break
            offset += response[offset] + 1
        else:
            offset += 1
        offset += 4  # skip QTYPE + QCLASS

        # Parse first answer
        if ancount > 0:
            # Skip name (might be a pointer)
            if response[offset] >= 0xC0:
                offset += 2
            else:
                while response[offset] != 0:
                    offset += response[offset] + 1
                offset += 1
            rtype, rclass, ttl, rdlength = struct.unpack(">HHIH", response[offset:offset+10])
            offset += 10
            if rtype == 1 and rdlength == 4:  # A record
                ip = ".".join(str(b) for b in response[offset:offset+4])
                print(f"  Resolved IP    : {ip}  (TTL={ttl}s)")

    except socket.timeout:
        print("  Timeout — no response from 8.8.8.8:53")
    except Exception as e:
        print(f"  Error: {e}")
    finally:
        sock.close()


# ─────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    demo_socket_basics()
    measure_dns_latency()
    demo_doh()
    demo_dnspython()
    demo_raw_dns()

    print("\n" + "=" * 60)
    print("Done! Try modifying the domain names and record types.")
    print("=" * 60)
