# DNS — Domain Name System: A Complete Learning Guide

> **Goal**: Go from zero to hands-on confident with DNS — theory, tools, experiments, and code.

---

## Table of Contents
1. [What is DNS?](#1-what-is-dns)
2. [DNS Hierarchy](#2-dns-hierarchy)
3. [How DNS Resolution Works](#3-how-dns-resolution-works)
4. [DNS Record Types](#4-dns-record-types)
5. [DNS Caching & TTL](#5-dns-caching--ttl)
6. [Command-Line Tools](#6-command-line-tools)
7. [Browser DevTools for DNS](#7-browser-devtools-for-dns)
8. [Hands-On Experiments](#8-hands-on-experiments)
9. [Programs: Python, C, C++](#9-programs-python-c-c)
10. [Security: DNSSEC, DNS over HTTPS](#10-security-dnssec-dns-over-https)
11. [Common DNS Issues & Debugging](#11-common-dns-issues--debugging)
12. [Public DNS Servers Cheat Sheet](#12-public-dns-servers-cheat-sheet)

---

## 1. What is DNS?

**DNS (Domain Name System)** is the internet's phone book. It translates human-readable domain names like `www.google.com` into machine-readable IP addresses like `142.250.194.4`.

Without DNS, you'd have to memorize IP addresses for every site you visit.

```
User types: www.github.com
   ↓
DNS resolves it to: 140.82.114.4
   ↓
Browser connects to: 140.82.114.4:443
```

**Key insight**: DNS is a *distributed*, *hierarchical*, *cached* database — no single server knows everything.

---

## 2. DNS Hierarchy

```
                        . (Root)
                        |
          ┌─────────────┼─────────────┐
         com           org           net        ← Top-Level Domains (TLDs)
          |             |
        github        wikipedia
          |             |
         www           en                       ← Subdomains
```

**Levels explained:**

| Level | Name | Example | Who manages it |
|-------|------|---------|----------------|
| 0 | Root | `.` | IANA (13 root server clusters) |
| 1 | TLD | `.com`, `.org`, `.in` | ICANN / registries |
| 2 | SLD (Second-level domain) | `github.com` | Domain owner |
| 3+ | Subdomain | `api.github.com` | Domain owner |

**Root Servers**: There are 13 root server *identities* (A through M), operated by organizations like NASA, ICANN, Verisign. Each is actually a cluster of hundreds of servers worldwide via **anycast routing**.

```
Root servers:
  a.root-servers.net — Verisign
  b.root-servers.net — USC-ISI
  c.root-servers.net — Cogent Communications
  d.root-servers.net — University of Maryland
  ... up to m.root-servers.net
```

---

## 3. How DNS Resolution Works

This is the **full recursive resolution** process — what happens the very first time you visit a new site:

```
┌─────────┐    1. Query        ┌──────────────────┐
│ Browser │ ─────────────────► │ Recursive Resolver│
│         │ ◄───────────────── │ (your ISP / 8.8.8)│
└─────────┘    8. Answer       └──────────────────┘
                                   │          ▲
                             2.Ask │          │ 3.Answer: TLD server
                             Root  │          │
                                   ▼          │
                              ┌─────────────────┐
                              │  Root Server    │
                              └─────────────────┘
                                   │          ▲
                             4.Ask │          │ 5.Answer: Auth server
                             TLD   │          │
                                   ▼          │
                              ┌─────────────────┐
                              │   TLD Server    │
                              │  (.com server)  │
                              └─────────────────┘
                                   │          ▲
                             6.Ask │          │ 7.Answer: IP address
                             Auth  │          │
                                   ▼          │
                              ┌─────────────────┐
                              │ Authoritative   │
                              │ Name Server     │
                              │(ns1.github.com) │
                              └─────────────────┘
```

**Step-by-step**:
1. Browser checks its own cache → not found
2. OS checks `/etc/hosts` → not found
3. OS asks the **recursive resolver** (configured via DHCP or manually)
4. Resolver checks its cache → not found
5. Resolver asks a **root server**: "Who handles `.com`?"
6. Root replies: "Ask `a.gtld-servers.net`" (the .com TLD server)
7. Resolver asks the TLD server: "Who handles `github.com`?"
8. TLD replies: "Ask `ns1.p16.dynect.net`" (GitHub's authoritative NS)
9. Resolver asks the authoritative NS: "What's the IP for `www.github.com`?"
10. Authoritative NS replies: `140.82.114.4`
11. Resolver caches it and returns the answer to your browser

> **Iterative vs Recursive**: The resolver does *iterative* queries (follows referrals). Your client makes one *recursive* query to the resolver (asks for the final answer).

---

## 4. DNS Record Types

### Core Records

| Type | Full Name | Purpose | Example |
|------|-----------|---------|---------|
| **A** | Address | IPv4 address | `github.com → 140.82.114.4` |
| **AAAA** | Quad-A | IPv6 address | `github.com → 2606:50c0:8000::153` |
| **CNAME** | Canonical Name | Alias to another name | `www.example.com → example.com` |
| **MX** | Mail Exchange | Mail servers for domain | `example.com → mail.example.com (priority 10)` |
| **NS** | Name Server | Authoritative name servers | `github.com → ns1.p16.dynect.net` |
| **TXT** | Text | Arbitrary text (SPF, DKIM, verification) | `"v=spf1 include:..."` |
| **PTR** | Pointer | Reverse DNS (IP → name) | `4.114.82.140.in-addr.arpa → github.com` |
| **SOA** | Start of Authority | Zone metadata (primary NS, serial, refresh) | — |
| **SRV** | Service | Port + host for services | `_http._tcp.example.com → 10 5 80 web.example.com` |
| **CAA** | Cert Authority Auth | Which CAs can issue SSL certs | `0 issue "letsencrypt.org"` |

### CNAME Rules (Important!)
- A CNAME **cannot** coexist with other records at the same name
- You **cannot** CNAME the root (`@` / `example.com`) — use ALIAS/ANAME records (provider-specific)
- CNAME chains are valid but add latency

### MX Record Priority
Lower number = higher priority. Multiple MX records = fallback chain.
```
10 mail1.example.com  ← tried first
20 mail2.example.com  ← fallback
```

---

## 5. DNS Caching & TTL

**TTL (Time To Live)**: How many seconds a resolver/client caches a record.

```
github.com.  60  IN  A  140.82.114.4
              ↑
         TTL: 60 seconds
```

| TTL | Use case |
|-----|---------|
| 60s | Fast failover, active changes |
| 300s | Default, balanced |
| 3600s | Stable records (reduce query load) |
| 86400s | Very stable (rarely changes) |

**Cache flush locations**:
- OS cache: `sudo systemd-resolve --flush-caches` (Linux) or `ipconfig /flushdns` (Windows)
- Browser cache: `chrome://net-internals/#dns` → Clear host cache
- Resolver cache: Depends on resolver (Unbound, BIND, etc.)

---

## 6. Command-Line Tools

### `dig` — The Gold Standard DNS Tool

```bash
# Basic A record lookup
dig github.com

# Specific record type
dig github.com MX
dig github.com AAAA
dig github.com NS
dig github.com TXT
dig github.com SOA
dig github.com CAA

# Ask a specific DNS server (bypass your default resolver)
dig @8.8.8.8 github.com
dig @1.1.1.1 github.com
dig @9.9.9.9 github.com

# Short output (just the answer)
dig github.com +short

# Trace the full resolution path step by step
dig github.com +trace

# Reverse DNS (PTR lookup)
dig -x 140.82.114.4

# Check DNSSEC
dig github.com +dnssec

# Query all record types
dig github.com ANY

# Disable recursion (ask authoritative server directly)
dig @ns1.p16.dynect.net github.com +norec

# Show only the answer section
dig github.com +noall +answer

# Batch queries from a file
dig -f domains.txt +short
```

**Understanding `dig` output**:
```
; <<>> DiG 9.16 <<>> github.com
;; QUESTION SECTION:         ← What we asked
;github.com.    IN  A

;; ANSWER SECTION:           ← The answer
github.com.  60  IN  A  140.82.114.4
             ↑           ↑
            TTL          IP address

;; Query time: 12 msec      ← Latency
;; SERVER: 192.168.1.1      ← Which resolver answered
;; WHEN: ...
;; MSG SIZE rcvd: 55        ← Response packet size
```

---

### `nslookup` — Simpler Interactive Tool

```bash
# Basic lookup
nslookup github.com

# Specify record type
nslookup -type=MX gmail.com
nslookup -type=NS github.com
nslookup -type=TXT google.com

# Use specific DNS server
nslookup github.com 8.8.8.8

# Interactive mode
nslookup
> server 8.8.8.8
> set type=MX
> gmail.com
> exit
```

---

### `host` — Quick and Clean

```bash
host github.com
host -t MX gmail.com
host -t NS github.com
host -t AAAA google.com
host 140.82.114.4          # Reverse lookup
host -a github.com         # All records
host -v github.com         # Verbose
```

---

### `ping` — Connectivity + DNS Check

```bash
# Resolves hostname and pings — confirms DNS works
ping github.com
ping -c 4 google.com       # 4 packets only

# Ping IPv6
ping6 github.com

# Ping with resolved IP shown
ping -n github.com
```

> `ping` confirms DNS resolved correctly AND network is reachable. If ping by name fails but ping by IP works → DNS problem.

---

### `traceroute` / `tracepath` — Path to Server

```bash
traceroute github.com
tracepath github.com
traceroute -n github.com   # No DNS reverse lookup (faster)
```

---

### `whois` — Domain Registration Info

```bash
whois github.com
whois google.com
whois 140.82.114.4         # IP WHOIS (who owns this IP block)
```

---

### `systemd-resolve` (Linux systemd)

```bash
# Lookup
systemd-resolve github.com

# Show DNS statistics
systemd-resolve --statistics

# Flush cache
sudo systemd-resolve --flush-caches

# Show current DNS config
systemd-resolve --status

# Reverse lookup
systemd-resolve --type=PTR 140.82.114.4
```

---

### `resolvectl` (Modern Linux)

```bash
resolvectl query github.com
resolvectl status
resolvectl statistics
resolvectl flush-caches
```

---

### `curl` with DNS options

```bash
# Force specific DNS resolver
curl --dns-servers 8.8.8.8 https://github.com -I

# Show DNS resolve time
curl -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\n" -o /dev/null -s https://github.com

# Override DNS resolution (like /etc/hosts for curl)
curl --resolve github.com:443:140.82.114.4 https://github.com -I
```

---

### `/etc/hosts` — Local Override

```
# View current hosts file
cat /etc/hosts

# Add a local override (edit as root)
sudo nano /etc/hosts
# Add: 127.0.0.1  myapp.local
```

---

### `/etc/resolv.conf` — System DNS Config

```bash
cat /etc/resolv.conf
# Shows: nameserver 192.168.1.1
#        search example.com
#        options ndots:5
```

---

## 7. Browser DevTools for DNS

### Chrome / Chromium

1. **`chrome://net-internals/#dns`** — View DNS cache, clear it, see all resolved entries
2. **`chrome://net-internals/#sockets`** — Socket pool (see active connections)
3. **DevTools → Network tab**:
   - Click any request → "Timing" tab → see `DNS Lookup` time
   - Filter by "Img", "XHR" etc. and check DNS time per request
4. **`chrome://flags/#enable-async-dns`** — Chrome's own async DNS resolver

### Firefox

1. **`about:networking#dns`** — Firefox DNS cache viewer
2. **DevTools → Network → click request → Timings** — DNS lookup time
3. **`about:config`** → search `network.trr` → DNS over HTTPS settings

### DNS over HTTPS (DoH) in browsers
- Chrome: Settings → Privacy → Security → Use secure DNS
- Firefox: Settings → Network Settings → Enable DNS over HTTPS

---

## 8. Hands-On Experiments

### Experiment 1: Trace a Full DNS Resolution
```bash
dig github.com +trace
# Watch it: Root → TLD → Authoritative NS → Answer
```

### Experiment 2: Compare Response Times
```bash
# Your ISP resolver
dig github.com | grep "Query time"

# Google DNS
dig @8.8.8.8 github.com | grep "Query time"

# Cloudflare DNS
dig @1.1.1.1 github.com | grep "Query time"

# Quad9 (security-focused)
dig @9.9.9.9 github.com | grep "Query time"
```

### Experiment 3: Observe TTL Countdown
```bash
# Run multiple times — watch TTL decrease
for i in {1..5}; do dig github.com +short +ttlid; sleep 5; done
```

### Experiment 4: Reverse DNS Lookup
```bash
dig -x 8.8.8.8 +short          # Google DNS → dns.google
dig -x 1.1.1.1 +short          # Cloudflare → one.one.one.one
dig -x 140.82.114.4 +short     # GitHub IP
```

### Experiment 5: Check Email DNS (MX + SPF + DKIM)
```bash
dig gmail.com MX +short
dig google.com TXT +short | grep spf
dig google._domainkey.google.com TXT +short   # DKIM
```

### Experiment 6: Find All Nameservers for a Domain
```bash
dig github.com NS +short
# Then query each NS directly:
dig @ns1.p16.dynect.net github.com A
```

### Experiment 7: DNS Propagation Check
After changing a DNS record, check if it's propagated globally:
```bash
for ns in 8.8.8.8 1.1.1.1 9.9.9.9 208.67.222.222; do
    echo -n "$ns: "
    dig @$ns yourdomain.com +short
done
```

### Experiment 8: Check for CNAME Chain
```bash
dig www.github.com CNAME +short
dig docs.github.com CNAME +short
```

### Experiment 9: SOA Record — Zone Info
```bash
dig github.com SOA +short
# Shows: primary NS, admin email, serial, refresh, retry, expire, min TTL
```

### Experiment 10: Local DNS via `/etc/hosts`
```bash
# Add to /etc/hosts:  127.0.0.1 testsite.local
# Then:
ping testsite.local        # resolves locally!
curl http://testsite.local
```

---

## 9. Programs: Python, C, C++

See the companion source files in this directory:
- `dns_lookup.py` — Python: multiple DNS experiments using `socket` and `dnspython`
- `dns_resolver.c` — C: DNS resolution using `getaddrinfo()`
- `dns_query.cpp` — C++: DNS resolver with multiple record type queries

---

## 10. Security: DNSSEC, DNS over HTTPS

### DNSSEC (DNS Security Extensions)
DNS responses can be forged (cache poisoning). DNSSEC adds cryptographic signatures.

```bash
# Check if a domain is DNSSEC-signed
dig github.com +dnssec
dig . DNSKEY                  # Root zone keys
dig github.com DS             # Delegation Signer record

# Validate DNSSEC
dig sigok.verteiltesysteme.net A +dnssec   # Should show AD flag
dig sigfail.verteiltesysteme.net A +dnssec # Should fail
```

Look for `ad` (Authenticated Data) flag in dig output: `;; flags: qr rd ra ad;`

### DNS over HTTPS (DoH)
```bash
# Query Cloudflare DoH with curl
curl -s "https://cloudflare-dns.com/dns-query?name=github.com&type=A" \
     -H "Accept: application/dns-json" | python3 -m json.tool

# Query Google DoH
curl -s "https://dns.google/resolve?name=github.com&type=A" | python3 -m json.tool
```

### DNS over TLS (DoT)
```bash
# Using kdig (from knot-dnsutils)
kdig -d @1.1.1.1 +tls-ca +tls-hostname=cloudflare-dns.com github.com

# Using openssl
openssl s_client -connect 1.1.1.1:853 -servername cloudflare-dns.com
```

### DNS Cache Poisoning (Kaminsky Attack — conceptual)
- Attacker floods resolver with forged responses for a domain
- Mitigation: Source port randomization, DNSSEC, 0x20 encoding

---

## 11. Common DNS Issues & Debugging

| Symptom | Likely Cause | Debug Command |
|---------|-------------|---------------|
| Site not loading | DNS not resolving | `ping sitename.com` |
| Works on some DNS, not others | Propagation delay | `dig @8.8.8.8 site.com` vs `dig @1.1.1.1 site.com` |
| Slow page loads | High DNS lookup time | `curl -w "%{time_namelookup}" ...` |
| Email bouncing | Wrong MX records | `dig domain.com MX` |
| SSL cert error | CAA record mismatch | `dig domain.com CAA` |
| Subdomain not resolving | Missing A/CNAME record | `dig sub.domain.com` |
| NXDOMAIN | Name doesn't exist | Check spelling, zone file |
| SERVFAIL | Resolver or auth server error | Try different resolver |
| REFUSED | Server won't answer | Server policy or firewall |

**DNS Response Codes (RCODE)**:
```
NOERROR  (0) — Success
FORMERR  (1) — Format error
SERVFAIL (2) — Server failure
NXDOMAIN (3) — Name doesn't exist
NOTIMP   (4) — Not implemented
REFUSED  (5) — Query refused
```

---

## 12. Public DNS Servers Cheat Sheet

| Provider | IPv4 Primary | IPv4 Secondary | Features |
|----------|-------------|----------------|---------|
| Google | `8.8.8.8` | `8.8.4.4` | Fast, global |
| Cloudflare | `1.1.1.1` | `1.0.0.1` | Fastest, privacy |
| Quad9 | `9.9.9.9` | `149.112.112.112` | Blocks malware |
| OpenDNS | `208.67.222.222` | `208.67.220.220` | Filtering options |
| Comodo | `8.26.56.26` | `8.20.247.20` | Security focused |

**Set DNS on Linux (temporary)**:
```bash
sudo resolvectl dns eth0 1.1.1.1 8.8.8.8
```

**Set DNS permanently** (edit `/etc/systemd/resolved.conf`):
```ini
[Resolve]
DNS=1.1.1.1 8.8.8.8
FallbackDNS=9.9.9.9
```

---

## Quick Reference Card

```
# Most used dig commands
dig domain.com                    # A record
dig domain.com MX                 # Mail servers
dig domain.com NS                 # Name servers
dig domain.com TXT                # TXT records
dig domain.com AAAA               # IPv6
dig -x IP                         # Reverse lookup
dig domain.com +trace             # Full resolution path
dig domain.com +short             # Just the answer
dig @8.8.8.8 domain.com          # Use specific resolver

# Flush caches
sudo systemd-resolve --flush-caches

# Check your DNS server
cat /etc/resolv.conf

# Local overrides
cat /etc/hosts
```

---

*Happy digging! DNS is one of those fundamentals that, once you understand it deeply, makes everything on the internet click into place.*
