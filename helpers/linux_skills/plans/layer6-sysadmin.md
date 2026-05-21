# Layer 6: System Administration

> **Goal**: Manage a Linux system like a professional — packages, services, logs, disks.

---

## What You'll Do

| Exercise | Skill |
|----------|-------|
| `01_package_management.sh` | apt, dpkg, snap, adding repos, pinning versions |
| `02_systemd.sh` | systemctl, journalctl, writing unit files, targets |
| `03_logs.sh` | /var/log, journald, syslog, log rotation, dmesg |
| `04_users_and_groups.sh` | useradd, usermod, /etc/passwd, /etc/shadow, sudo |
| `05_disk_management.sh` | fdisk, mkfs, mount, LVM basics, RAID concepts |

---

## Key Ideas (Discovered Through Practice)

- **systemd is the init system** — it starts everything, manages dependencies, restarts crashed services
- **journalctl** = one command to search all system and service logs
- **Package managers solve dependency hell** — apt tracks what depends on what
- **`/etc/passwd` is readable, `/etc/shadow` is not** — password hashes need protection
- **LVM** = flexible partitioning — resize, snapshot, move without downtime

---

## Checkpoint

1. How do you see why a service failed to start?
2. What's the difference between `apt install` and `dpkg -i`?
3. How do you add a user to the `docker` group? Why does this grant root-equivalent access?
4. Where do you look first when something breaks after a reboot?
5. Write a systemd unit file for a simple Python HTTP server.
