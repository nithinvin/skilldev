# Layer 6: System Administration

## What You'll Learn
- Package management (apt, dpkg, snap — installing and managing software)
- systemd (services, journalctl, writing unit files)
- User management, sudo, SSH keys, and system security

## File Structure

```
layer6/
├── README.md              ← You are here
└── exercises/
    ├── 01_package_management.sh   ← apt, dpkg, snap, repositories
    ├── 02_systemd.sh              ← systemctl, journalctl, unit files
    └── 03_users_and_security.sh   ← users, groups, sudo, SSH keys
```

## Prerequisites
- Complete Layers 0-5
- sudo access on your machine

## Why This Matters
Sysadmin skills are what separate "I code on my laptop" from
"I can deploy, maintain, and fix production servers":
- Install software reliably → package management
- Keep services running → systemd
- Control who has access → users + sudo + SSH
- Debug server problems → journalctl

## Time Estimate
~3-4 hours
