# Layer 5: Networking from the CLI

> **Goal**: Debug network problems, transfer data, understand connections — all from the terminal.

---

## What You'll Do

| Exercise | Skill |
|----------|-------|
| `01_interfaces_and_ip.sh` | ip addr, ip route, ifconfig (legacy), ping, traceroute |
| `02_connections.sh` | ss, netstat, lsof -i, who's listening on which port |
| `03_dns.sh` | dig, nslookup, host, /etc/resolv.conf, /etc/hosts |
| `04_transfer.sh` | curl, wget, scp, rsync, nc (netcat) |
| `05_firewall.sh` | iptables/nftables basics, ufw, port forwarding |

---

## Key Ideas (Discovered Through Practice)

- **Every connection is a 5-tuple**: (src_ip, src_port, dst_ip, dst_port, protocol)
- **`ss -tlnp`** = the single most useful networking command (listening TCP, numeric, with process)
- **DNS is just a distributed phone book** — dig shows you the full lookup chain
- **curl is a Swiss army knife** — HTTP, headers, cookies, POST, file upload, all in one command
- **Firewalls work on packet rules** — match by src/dst/port/protocol, then ACCEPT/DROP/REJECT

---

## Checkpoint

1. How do you find which process is listening on port 8080?
2. What's the difference between `curl` and `wget`?
3. Explain what `traceroute` shows you. Why do some hops show `* * *`?
4. How do you test if a remote port is open without a browser?
5. What does `rsync` do that `scp` can't?
